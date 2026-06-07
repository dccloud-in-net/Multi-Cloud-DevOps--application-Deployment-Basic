output "alb_dns_name" {
  value       = aws_lb.external.dns_name
  description = "The public DNS name of the Application Load Balancer"
}

output "alb_arn" {
  value       = aws_lb.external.arn
  description = "The ARN of the Application Load Balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app.arn
  description = "The ARN of the Target Group"
}

output "target_group_name" {
  value       = aws_lb_target_group.app.name
  description = "Name of the target group"
}
