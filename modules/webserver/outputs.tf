output "droplet_id" {
  description = "The ID of the web server Droplet."
  value       = digitalocean_droplet.webserver.id
}

output "public_ip" {
  description = "The public IP of the web server Droplet."
  value       = digitalocean_droplet.webserver.ipv4_address
}