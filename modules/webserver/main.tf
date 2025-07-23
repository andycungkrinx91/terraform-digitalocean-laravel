terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_droplet" "webserver" {
  image              = var.image
  name               = var.web_hostname
  region             = var.region
  size               = var.size
  vpc_uuid           = var.vpc_uuid
  ssh_keys           = [var.ssh_key_fingerprint]
  user_data          = templatefile("${path.module}/../../templates/webserver/setup-laravel.tpl.sh", {
    db_private_ip = var.db_private_ip
    db_name       = var.db_name
    db_user       = var.db_user
    db_password   = var.db_password
  })
}