variable "vpc_id" {
  type        = string
  description = "The VPC ID where the ALB will be deployed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs where the ALB will listen"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for the ALB"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g. dev, stage, prod)"
}

variable "app_instance_ids" {
  type        = list(string)
  default     = []
  description = "List of standalone EC2 instance IDs to attach to the target group (optional if ASG is used instead)"
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "Health check HTTP path for testing target instances"
}
