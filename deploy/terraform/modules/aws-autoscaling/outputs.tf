output "asg_name" {
  value       = aws_autoscaling_group.app.name
  description = "The name of the Auto Scaling Group"
}

output "asg_arn" {
  value       = aws_autoscaling_group.app.arn
  description = "The ARN of the Auto Scaling Group"
}

output "asg_id" {
  value       = aws_autoscaling_group.app.id
  description = "The ID of the Auto Scaling Group"
}
