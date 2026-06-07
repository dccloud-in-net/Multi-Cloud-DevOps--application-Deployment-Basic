output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "The name of the Resource Group created"
}

output "location" {
  value       = azurerm_resource_group.main.location
  description = "The Azure region where resources are deployed"
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "The name of the VNet created"
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The ID of the VNet created"
}

output "subnets_map" {
  value       = azurerm_subnet.subnet
  description = "Detailed map of the created subnets"
}

output "subnet_ids" {
  value       = [for s in azurerm_subnet.subnet : s.id]
  description = "List of subnet IDs"
}

output "nsg_id" {
  value       = azurerm_network_security_group.nsg.id
  description = "The Network Security Group ID"
}

output "acr_login_server" {
  value       = length(azurerm_container_registry.acr) > 0 ? azurerm_container_registry.acr[0].login_server : ""
  description = "The login server URL for the ACR"
}

output "acr_admin_username" {
  value       = length(azurerm_container_registry.acr) > 0 ? azurerm_container_registry.acr[0].admin_username : ""
  description = "Admin username for the ACR"
}

output "acr_admin_password" {
  value       = length(azurerm_container_registry.acr) > 0 ? azurerm_container_registry.acr[0].admin_password : ""
  sensitive   = true
  description = "Admin password for the ACR"
}
