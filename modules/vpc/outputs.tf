output "vpc_id" {
  description = "The ID of the VPC."
  value       = digitalocean_vpc.main.id
}

output "vpc_urn" {
  description = "The URN of the VPC."
  value       = digitalocean_vpc.main.urn
}