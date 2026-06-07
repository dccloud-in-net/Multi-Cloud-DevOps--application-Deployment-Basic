output "alb_sg_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the Security Group for the Application Load Balancer"
}

output "bastion_sg_id" {
  value       = aws_security_group.bastion.id
  description = "The ID of the Security Group for the Bastion Host"
}

output "app_ec2_sg_id" {
  value       = aws_security_group.app_ec2.id
  description = "The ID of the Security Group for the EC2 App Instances"
}

output "ec2_iam_role_name" {
  value       = aws_iam_role.ec2_role.name
  description = "Name of the EC2 IAM role created"
}

output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_profile.name
  description = "Name of the EC2 IAM Instance Profile created"
}
