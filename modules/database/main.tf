terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_volume" "database_disk" {
  name                    = "${var.db_hostname}-disk"
  region                  = var.region
  size                    = var.disk_size
  initial_filesystem_type = "ext4"
  description             = "Data volume for ${var.db_hostname}"
}

resource "digitalocean_droplet" "database" {
  image              = var.image
  name               = var.db_hostname
  region             = var.region
  size               = var.size
  vpc_uuid           = var.vpc_uuid
  ssh_keys           = [var.ssh_key_fingerprint]
  user_data          = templatefile("${path.module}/../../templates/database/setup-percona.tpl.sh", {
    db_root_password    = var.db_root_password
    db_name             = var.db_name
    db_user             = var.db_user
    db_password         = var.db_password
    db_disk_mount_path  = var.disk_mount_path
    db_disk_device_path = "/dev/disk/by-id/scsi-0DO_Volume_${digitalocean_volume.database_disk.name}"
  })
}

resource "digitalocean_volume_attachment" "database_disk_attach" {
  droplet_id = digitalocean_droplet.database.id
  volume_id  = digitalocean_volume.database_disk.id
}