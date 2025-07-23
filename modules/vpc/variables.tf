variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
}

variable "region" {
  description = "The DigitalOcean region for the VPC."
  type        = string
}

variable "ip_range" {
  description = "The IP range for the VPC."
  type        = string
  default     = "10.10.10.0/24"
}