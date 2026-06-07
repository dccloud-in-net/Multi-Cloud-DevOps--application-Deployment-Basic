output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC created"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "The CIDR block of the VPC"
}

output "public_subnet_ids" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "The list of public subnet IDs"
}

output "public_subnets_map" {
  value       = aws_subnet.public
  description = "Detailed map of the public subnets"
}

output "private_subnet_ids" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "The list of private subnet IDs"
}

output "private_subnets_map" {
  value       = aws_subnet.private
  description = "Detailed map of the private subnets"
}

output "ecr_repository_url" {
  value       = length(aws_ecr_repository.app) > 0 ? aws_ecr_repository.app[0].repository_url : ""
  description = "URL of the ECR repository"
}

output "artifacts_bucket_name" {
  value       = aws_s3_bucket.artifacts.id
  description = "Name of the S3 artifacts bucket"
}
