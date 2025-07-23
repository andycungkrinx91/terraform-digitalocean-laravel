variable "web_hostname" {
  description = "Hostname for the web server Droplet."
  type        = string
}

variable "region" {
  description = "The DigitalOcean region."
  type        = string
}

variable "size" {
  description = "The size slug for the Droplet."
  type        = string
  default     = "s-2vcpu-4gb" # 2 vCPU / 4GB RAM
}

variable "image" {
  description = "The image slug for the Droplet."
  type        = string
}

variable "vpc_uuid" {
  description = "The UUID of the VPC to attach the Droplet to."
  type        = string
}

variable "ssh_key_fingerprint" {
  description = "Fingerprint of the SSH key to add to the Droplet."
  type        = string
}

variable "db_private_ip" {
  description = "The private IP of the database server for the .env file."
  type        = string
}

variable "db_name" {
  description = "The name for the application database."
  type        = string
}

variable "db_user" {
  description = "The username for the application database user."
  type        = string
}

variable "db_password" {
  description = "The password for the application database user."
  type        = string
  sensitive   = true
}