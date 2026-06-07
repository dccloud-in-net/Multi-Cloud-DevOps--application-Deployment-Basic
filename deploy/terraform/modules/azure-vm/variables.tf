variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group where VMs will be deployed"
}

variable "location" {
  type        = string
  description = "The Azure region for the VMs"
}

variable "subnet_id" {
  type        = string
  description = "The Subnet ID where the VMs will reside"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "The Virtual Machine size/sku"
}

variable "vm_count" {
  type        = number
  default     = 1
  description = "Number of Virtual Machines to create"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "Administrative user for SSH logins"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key string (value) to authorize SSH connections"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g. dev, stage, prod)"
}
