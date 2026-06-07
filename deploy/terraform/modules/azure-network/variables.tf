variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group to create/use"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region for resource placement"
}

variable "vnet_cidr" {
  type        = list(string)
  default     = ["10.1.0.0/16"]
  description = "The CIDR address space for the Azure VNet"
}

variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
  description = "A map of subnets to create under the VNet"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g. dev, stage, prod)"
}

variable "create_acr" {
  type        = bool
  default     = true
  description = "Whether to provision Azure Container Registry"
}

variable "acr_sku" {
  type        = string
  default     = "Standard"
  description = "SKU for the Azure Container Registry"
}
