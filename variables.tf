variable "do_token" {
  description = "DigitalOcean API token."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "A name for the project, used to prefix resource names."
  type        = string
  default     = "laravel-percona"
}

variable "do_region" {
  description = "The DigitalOcean region to deploy resources in."
  type        = string
  default     = "sgp1"
}

variable "ssh_pub_key_path" {
  description = "Path to your public SSH key to be added to DigitalOcean."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to your private SSH key for remote execution."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "vpc_ip_range" {
  description = "The IP range for the VPC."
  type        = string
  default     = "10.10.10.0/24"
}

variable "allowed_ssh_ips" {
  description = "A list of CIDR-formatted IP address ranges to allow SSH from."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "db_root_password" {
  description = "The root password for the Percona MySQL database."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name for the application database."
  type        = string
  default     = "laravel"
}

variable "db_user" {
  description = "The username for the application database user."
  type        = string
  default     = "laravel_user"
}

variable "db_password" {
  description = "The password for the application database user."
  type        = string
  sensitive   = true
}

variable "webserver_droplet_size" {
  description = "The size/plan for the webserver Droplet."
  type        = string
  default     = "s-1vcpu-2gb"
}

variable "database_droplet_size" {
  description = "The size/plan for the database Droplet."
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "database_disk_size" {
  description = "The size of the block storage volume for the database in GB."
  type        = number
  default     = 40
}

variable "database_disk_mount_path" {
  description = "The path where the database volume will be mounted."
  type        = string
  default     = "/mnt/mysql/data"
}

variable "webserver_hostname" {
  description = "The hostname for the webserver Droplet."
  type        = string
  default     = "laravel-web-01"
}

variable "database_hostname" {
  description = "The hostname for the database Droplet."
  type        = string
  default     = "percona-db-01"
}

variable "droplet_os_image" {
  description = "The operating system image for the Droplets."
  type        = string
  default     = "ubuntu-24-04-x64"
}