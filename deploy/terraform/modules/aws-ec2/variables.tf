variable "ami_id" {
  type        = string
  default     = ""
  description = "Specific AMI ID to override. If empty, Amazon Linux 2 AMI will be auto-selected."
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance size for the Spring Boot application"
}

variable "bastion_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance size for the Bastion host"
}

variable "public_subnet_id" {
  type        = string
  description = "Public Subnet ID to place the Bastion host"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for application instances"
}

variable "bastion_sg_id" {
  type        = string
  description = "Security group ID for the Bastion host"
}

variable "app_sg_id" {
  type        = string
  description = "Security group ID for application instances"
}

variable "key_name" {
  type        = string
  description = "SSH Keypair name to associate with EC2 instances"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM Instance Profile name to bind to application instances"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g. dev, stage, prod)"
}

variable "app_instance_count" {
  type        = number
  default     = 1
  description = "Number of standalone application instances to spin up"
}
