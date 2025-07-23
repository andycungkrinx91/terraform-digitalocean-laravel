output "droplet_id" {
  description = "The ID of the database Droplet."
  value       = digitalocean_droplet.database.id
}

output "private_ip" {
  description = "The private IP of the database Droplet."
  value       = digitalocean_droplet.database.ipv4_address_private
}

output "public_ip" {
  description = "The public IP of the database Droplet."
  value       = digitalocean_droplet.database.ipv4_address
}