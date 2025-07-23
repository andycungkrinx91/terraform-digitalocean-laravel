#!/bin/bash
set -euxo pipefail

# Redirect stdout/stderr to a log file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- Starting Laravel Web Server Setup ---"

# Set DEBIAN_FRONTEND to noninteractive
export DEBIAN_FRONTEND=noninteractive

# --- Create and enable 8GB Swap File ---
if ! grep -q "/swapfile" /etc/fstab; then
  echo "--- Creating 8GB swap file ---"
  fallocate -l 8G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
  echo "--- Swap file created and enabled ---"
fi

# Update and install base packages
echo "--> Updating packages and installing base dependencies..."
apt-get update
apt-get install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https software-properties-common unzip

# Add PHP PPA from Ondřej Surý
add-apt-repository ppa:ondrej/php -y || { echo "!!! CRITICAL: Failed to add PHP PPA repository. It might be down or blocked. !!!"; exit 1; }
apt-get update

# Install Nginx, PHP 8.2, and extensions
echo "--> Installing Nginx and PHP 8.2..."
apt-get install -y nginx mysql-client \
php8.2-common \
php8.2-cli \
php8.2-mysql \
php8.2-soap \
php8.2-xml \
php8.2-mbstring \
php8.2-gd \
php8.2-curl \
php8.2-intl \
php8.2-zip \
php8.2-xsl \
php8.2-dev \
php8.2-fpm \
php8.2-bcmath \
php8.2-xmlrpc \
php8.2-pdo \
php8.2-iconv \
php8.2-opcache \
php8.2-ctype \
php8.2-dom \
php8.2-simplexml || { echo "!!! CRITICAL: Nginx/PHP installation failed. Check APT logs. !!!"; exit 1; }

# Install Composer
echo "--> Installing Composer..."
# Set HOME variable for Composer, which requires it for config/cache.
export HOME=/root
curl -sS https://getcomposer.org/installer | php -- --version=2.8.10 --install-dir=/usr/local/bin --filename=composer

# Create Laravel project
cd /var/www
echo "--> Creating Laravel project. This might take a while and be memory intensive..."
composer create-project --no-progress --no-interaction --prefer-dist laravel/laravel laravel || { echo "!!! CRITICAL: 'composer create-project' failed. Check for memory or network issues. !!!"; exit 1; }

# Set permissions for Laravel
echo "--> Setting permissions for Laravel..."
chown -R www-data:www-data /var/www/laravel
chmod -R 775 /var/www/laravel/storage
chmod -R 775 /var/www/laravel/bootstrap/cache

# Configure Nginx for Laravel
echo "--> Configuring Nginx server block for Laravel..."
cat > /etc/nginx/sites-available/laravel <<EOF
server {
    # Listen on port 80 for both IPv4 and IPv6, and make this the default server
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /var/www/laravel/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

echo "--> Enabling new Nginx site..."
# Enable the site
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Configure Laravel .env file
echo "--> Configuring Laravel .env file..."
cd /var/www/laravel
cp .env.example .env

echo "--> Generating application key..."
php artisan key:generate

echo "--> Setting database credentials in .env file..."
# Use sed with extended regex (-E) to find and replace database connection details.
# The pattern `^#?\s*` matches a line that optionally starts with '#' and whitespace.
sed -i -E "s|^#?\s*DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env
sed -i -E "s|^#?\s*DB_HOST=.*|DB_HOST=${db_private_ip}|" .env
sed -i -E "s|^#?\s*DB_PORT=.*|DB_PORT=3306|" .env
sed -i -E "s|^#?\s*DB_DATABASE=.*|DB_DATABASE=${db_name}|" .env
sed -i -E "s|^#?\s*DB_USERNAME=.*|DB_USERNAME=${db_user}|" .env
sed -i -E "s|^#?\s*DB_PASSWORD=.*|DB_PASSWORD=${db_password}|" .env

echo "--> Clearing Laravel's configuration cache and restarting services..."
php artisan migrate --force
php artisan db:seed
php artisan config:clear
php artisan cache:clear
systemctl restart nginx php8.2-fpm

touch /var/log/user-data-finished

echo "--- Laravel Web Server Setup Finished ---"
echo "You can access your Laravel site at http://$(curl -s ifconfig.me)"