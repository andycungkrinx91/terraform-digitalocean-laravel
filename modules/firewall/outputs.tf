output "firewall_id" {
  description = "The ID of the firewall."
  value       = digitalocean_firewall.main.id
}