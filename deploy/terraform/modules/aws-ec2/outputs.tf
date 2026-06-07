output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "The public IP address of the Bastion Host"
}

output "bastion_instance_id" {
  value       = aws_instance.bastion.id
  description = "The Instance ID of the Bastion Host"
}

output "app_private_ips" {
  value       = aws_instance.app[*].private_ip
  description = "The private IP addresses of the application EC2 instances"
}

output "app_instance_ids" {
  value       = aws_instance.app[*].id
  description = "The Instance IDs of the application EC2 instances"
}
