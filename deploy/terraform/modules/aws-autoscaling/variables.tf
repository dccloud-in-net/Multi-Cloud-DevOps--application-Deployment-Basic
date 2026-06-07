variable "environment" {
  type        = string
  description = "Environment identifier (e.g. dev, stage, prod)"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance size for the scale group"
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "Specific AMI ID. If empty, Amazon Linux 2 will be resolved."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private Subnet IDs where autoscaled EC2s will run"
}

variable "app_sg_id" {
  type        = string
  description = "Security group ID for application instances"
}

variable "key_name" {
  type        = string
  description = "SSH Keypair name to bind to instances"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM Instance Profile name to authorize instance policies"
}

variable "target_group_arn" {
  type        = string
  description = "The Target Group ARN of the ALB to associate with the ASG"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of instances in the scaling group"
}

variable "max_size" {
  type        = number
  default     = 3
  description = "Maximum number of instances in the scaling group"
}

variable "desired_capacity" {
  type        = number
  default     = 1
  description = "Desired target capacity for the scaling group"
}
