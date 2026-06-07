# ==============================================================================
# Common Variables
# ==============================================================================

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name (dev, stage, prod)"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH Key string value for instance authorization"
}

variable "ssh_key_name" {
  type        = string
  default     = "bankpro_dev_key"
  description = "Name of the key pair in AWS"
}

# ==============================================================================
# AWS Specific Variables
# ==============================================================================

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Target AWS Region"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "AWS VPC CIDR network boundary"
}

variable "aws_public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "AWS Public Subnets map"
}

variable "aws_private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "AWS Private Subnets map"
}

variable "aws_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "AWS EC2 instance class size"
}

variable "aws_app_instance_count" {
  type        = number
  default     = 1
  description = "Number of standalone AWS EC2 App instances to launch"
}

# ==============================================================================
# Azure Specific Variables
# ==============================================================================

variable "azure_location" {
  type        = string
  default     = "eastus"
  description = "Target Azure Region"
}

variable "azure_vnet_cidr" {
  type        = list(string)
  default     = ["10.1.0.0/16"]
  description = "Azure VNet IP scope"
}

variable "azure_subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
  description = "Azure Subnets map"
}

variable "azure_vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "Azure Virtual Machine class size"
}

variable "azure_vm_count" {
  type        = number
  default     = 1
  description = "Number of Azure VMs to provision"
}
