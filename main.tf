terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Register your local public SSH key with DigitalOcean
resource "digitalocean_ssh_key" "main_ssh_key" {
  name       = "${var.project_name}-key"
  public_key = file(var.ssh_pub_key_path)
}

# Module to create the Virtual Private Cloud (VPC)
module "vpc" {
  source = "./modules/vpc"

  vpc_name = "${var.project_name}-vpc"
  region   = var.do_region
  ip_range = var.vpc_ip_range
}

# Module to create the Database Server
module "database" {
  source = "./modules/database"

  db_hostname         = var.database_hostname
  region              = var.do_region
  image               = var.droplet_os_image
  size                = var.database_droplet_size
  vpc_uuid            = module.vpc.vpc_id
  ssh_key_fingerprint = digitalocean_ssh_key.main_ssh_key.fingerprint
  db_root_password    = var.db_root_password
  db_name             = var.db_name
  db_user             = var.db_user
  db_password         = var.db_password
  disk_size           = var.database_disk_size
  disk_mount_path     = var.database_disk_mount_path
}

# Module to create the Web Server
module "webserver" {
  source = "./modules/webserver"

  web_hostname        = var.webserver_hostname
  region              = var.do_region
  image               = var.droplet_os_image
  size                = var.webserver_droplet_size
  vpc_uuid            = module.vpc.vpc_id
  ssh_key_fingerprint = digitalocean_ssh_key.main_ssh_key.fingerprint
  db_private_ip       = module.database.private_ip
  db_name             = var.db_name
  db_user             = var.db_user
  db_password         = var.db_password
}

# Module to create the Firewall
module "firewall" {
  source = "./modules/firewall"

  fw_name              = "${var.project_name}-fw"
  webserver_droplet_id = module.webserver.droplet_id
  database_droplet_id  = module.database.droplet_id
  allowed_ssh_ips      = var.allowed_ssh_ips
}

# Null resource to wait for webserver user_data script to complete
resource "null_resource" "webserver_provisioner_wait" {
  # This ensures the waiter runs after the droplet is created
  depends_on = [
    module.webserver,
    module.firewall
  ]

  # Connection details for the remote-exec provisioner
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = module.webserver.public_ip
    timeout     = "15m"
  }

  # This provisioner will wait until the user_data script creates a signal file
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for webserver cloud-init to finish...'",
      "while [ ! -f /var/log/user-data-finished ]; do echo '...still waiting...'; sleep 5; done",
      "echo 'Webserver provisioning complete!'"
    ]
  }
}

# Null resource to wait for database user_data script to complete
resource "null_resource" "database_provisioner_wait" {
  # This ensures the waiter runs after the droplet is created
  depends_on = [
    module.database,
    module.firewall
  ]

  # Connection details for the remote-exec provisioner
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = module.database.public_ip
    timeout     = "15m"
  }

  # This provisioner will wait until the user_data script creates a signal file
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for database cloud-init to finish...'",
      "while [ ! -f /var/log/user-data-finished ]; do echo '...still waiting...'; sleep 5; done",
      "echo 'Database provisioning complete!'"
    ]
  }
}