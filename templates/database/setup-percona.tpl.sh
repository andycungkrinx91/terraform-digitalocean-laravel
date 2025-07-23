#!/bin/bash
set -e

# Redirect stdout/stderr to a log file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- Starting Percona Setup ---"

# Set DEBIAN_FRONTEND to noninteractive
export DEBIAN_FRONTEND=noninteractive

# Helper function to wait for apt locks to be released
apt_wait() {
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
        fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
        fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
        fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do
    echo "Waiting for other apt-get processes to finish..."
    sleep 10
  done
}

# Helper function to print a formatted step header, like a pager for logs
log_step() {
  echo ""
  echo "========================================================================"
  echo "== $1"
  echo "========================================================================"
  echo ""
}

# Helper function for logging sub-steps for clarity
log_sub_step() {
  echo "--> $1"
}

# Update and install dependencies
log_step "STEP 1: Updating packages and installing dependencies..."
apt_wait
apt-get update
apt-get install -y wget gnupg2 lsb-release

# Install Percona repository
log_step "STEP 2: Setting up Percona repository..."
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
percona-release setup ps80

# Install Percona Server
log_step "STEP 3: Installing Percona Server 8.0..."
apt_wait
apt-get update

# Pre-configure password for Percona Server
log_sub_step "Pre-configuring root password..."
debconf-set-selections <<< "percona-server-server percona-server-server/root_password password ${db_root_password}"
debconf-set-selections <<< "percona-server-server percona-server-server/root_password_again password ${db_root_password}"

apt_wait
apt-get install -y percona-server-server || { echo "!!! CRITICAL: Percona Server installation failed. Check OS compatibility and APT logs. !!!"; exit 1; }

log_step "STEP 4: Configuring external data volume..."

# Stop Percona to move data
systemctl stop mysql

# Create the mount point directory
mkdir -p ${db_disk_mount_path}

log_sub_step "Configuring fstab for auto-mounting..."
# Add the volume to fstab for automatic mounting on reboot
echo '${db_disk_device_path} ${db_disk_mount_path} ext4 defaults,nofail,discard 0 0' | tee -a /etc/fstab

log_sub_step "Waiting for volume to attach and mounting..."
# Wait for the volume to be attached and mount it
echo "--- Waiting for volume to attach at ${db_disk_device_path} ---"
i=0
while [ ! -e "${db_disk_device_path}" ] && [ $i -lt 60 ]; do
  echo "Waiting for device... ($i/60)"
  sleep 2
  i=$((i+1))
done
mount -a # Mount all filesystems in fstab

# Sync the original MySQL data to the new volume
log_sub_step "Moving MySQL data to new volume..."
rsync -av /var/lib/mysql/ ${db_disk_mount_path}

log_sub_step "Overriding default datadir configuration..."
# Create a new config file to override the datadir
# Ensure the configuration directory exists before writing to it.
mkdir -p /etc/mysql/percona-server.conf.d/
cat > /etc/mysql/percona-server.conf.d/z-datadir.cnf <<EOF
[mysqld]
datadir=${db_disk_mount_path}
EOF

log_sub_step "Configuring MySQL to listen for remote connections..."
# By default, MySQL only listens on 127.0.0.1. We need to change this
# to 0.0.0.0 to allow connections from the web server on the private network.
cat > /etc/mysql/percona-server.conf.d/y-bind-address.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
EOF

log_sub_step "Updating AppArmor permissions..."
# Update AppArmor to allow MySQL to access the new data directory
echo "alias /var/lib/mysql/ -> ${db_disk_mount_path}/," >> /etc/apparmor.d/tunables/alias
systemctl reload apparmor

log_sub_step "Setting ownership of new data directory..."
# Change ownership of the new data directory
chown -R mysql:mysql ${db_disk_mount_path}

# Start Percona again
log_step "STEP 5: Starting MySQL from new data directory..."
systemctl start mysql

log_step "STEP 6: Securing installation and creating application user..."
# Secure the installation and create dedicated application user
mysql -uroot -p"${db_root_password}" <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}';
    -- Create Application Database
    CREATE DATABASE IF NOT EXISTS \`${db_name}\`;
    -- Create Application User
    CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_password}';
    -- Grant Privileges
    GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'%';
    FLUSH PRIVILEGES;
EOSQL

log_step "STEP 7: Creating completion signal file..."
touch /var/log/user-data-finished

echo "--- Percona Setup Finished ---"