# ==============================================================================
# AWS Environment Outputs - Prod
# ==============================================================================

output "aws_bastion_public_ip" {
  value       = module.aws_ec2.bastion_public_ip
  description = "The public IP address of the AWS Bastion Host"
}

output "aws_alb_dns_name" {
  value       = module.aws_alb.alb_dns_name
  description = "The DNS Endpoint of the AWS Application Load Balancer"
}

output "aws_ecr_repository_url" {
  value       = module.aws_network.ecr_repository_url
  description = "The URL of the AWS ECR registry repository"
}

output "aws_app_private_ips" {
  value       = module.aws_ec2.app_private_ips
  description = "The private IP addresses of the application EC2 instances"
}

# ==============================================================================
# Azure Environment Outputs - Prod
# ==============================================================================

output "azure_lb_public_ip" {
  value       = module.azure_vm.lb_public_ip
  description = "The public IP of the Azure Load Balancer fronting the application"
}

output "azure_acr_login_server" {
  value       = module.azure_network.acr_login_server
  description = "The login server URI of the Azure Container Registry"
}

output "azure_vm_private_ips" {
  value       = module.azure_vm.vm_private_ips
  description = "The private IPs of the Azure VM instances"
}

output "azure_vm_public_ips" {
  value       = module.azure_vm.vm_public_ips
  description = "The public IPs of the Azure VM instances"
}
