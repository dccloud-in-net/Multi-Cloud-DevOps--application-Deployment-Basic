variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the AWS VPC"
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr))
    error_message = "VPC CIDR must be a valid CIDR block notation (e.g. 10.0.0.0/16)."
  }
}

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "A map of public subnets to create under the VPC, key is subnet identifier"
}

variable "private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "A map of private subnets to create under the VPC, key is subnet identifier"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g. dev, stage, prod)"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to provision a NAT Gateway for private subnet outbound traffic"
}

variable "create_ecr" {
  type        = bool
  default     = true
  description = "Whether to provision an AWS ECR repository for Docker images"
}

variable "ecr_repo_name" {
  type        = string
  default     = "bankpro-app"
  description = "Name for the ECR repository"
}
