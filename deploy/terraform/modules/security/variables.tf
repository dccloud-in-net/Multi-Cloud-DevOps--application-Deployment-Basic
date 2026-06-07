variable "vpc_id" {
  type        = string
  description = "The ID of the AWS VPC where security groups will be created"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g. dev, stage, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR range of the VPC for boundary validation rules"
}

variable "allowed_admin_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0"] # In real production, this would be restricted to corporate IP/VPN range
  description = "Allowed CIDR blocks for administrative SSH access"
}
