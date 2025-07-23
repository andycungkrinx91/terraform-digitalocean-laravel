variable "fw_name" {
  description = "The name of the firewall."
  type        = string
}

variable "webserver_droplet_id" {
  description = "The ID of the webserver droplet to allow as a source for DB traffic."
  type        = number
}

variable "database_droplet_id" {
  description = "The ID of the database droplet."
  type        = number
}

variable "allowed_ssh_ips" {
  description = "A list of CIDR-formatted IP address ranges to allow SSH from."
  type        = list(string)
}