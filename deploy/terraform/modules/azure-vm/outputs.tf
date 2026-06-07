output "lb_public_ip" {
  value       = azurerm_public_ip.lb_pip.ip_address
  description = "The public IP of the Azure Load Balancer"
}

output "vm_private_ips" {
  value       = azurerm_linux_virtual_machine.vm[*].private_ip_address
  description = "The private IPs of the VMs"
}

output "vm_public_ips" {
  value       = azurerm_public_ip.vm_pip[*].ip_address
  description = "The public IPs of the VMs (for direct admin connection)"
}

output "vm_principal_ids" {
  value       = [for identity in azurerm_linux_virtual_machine.vm[*].identity : identity[0].principal_id]
  description = "The Managed Identity Principal IDs of the VMs"
}
