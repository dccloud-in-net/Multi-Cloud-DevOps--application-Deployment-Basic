# ==============================================================================
# AWS Security Groups (Network Hardening)
# ==============================================================================

# 1. Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name        = "bankpro-${var.environment}-alb-sg"
  description = "Security group for external ALB allowing inbound web traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP access from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS access from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "bankpro-${var.environment}-alb-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 2. Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name        = "bankpro-${var.environment}-bastion-sg"
  description = "Security group for bastion host admin access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH administrative access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_admin_ips
  }

  egress {
    description = "Allow egress to VPC private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "bankpro-${var.environment}-bastion-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 3. Application EC2 Instance Security Group
resource "aws_security_group" "app_ec2" {
  name        = "bankpro-${var.environment}-app-ec2-sg"
  description = "Security group for app EC2 instances in private subnets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB on application port"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Allow admin SSH traffic from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Allow all outbound traffic for package installs/updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "bankpro-${var.environment}-app-ec2-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# AWS Identity & Access Management (IAM)
# ==============================================================================

# IAM Trust Policy for EC2 instances
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_role" {
  name               = "bankpro-${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "bankpro-${var.environment}-ec2-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Attach AWS ReadOnly Policy for ECR to pull images
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach CloudWatch Agent Policy to write logs and metrics
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# EC2 Instance Profile associated with IAM Role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "bankpro-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "bankpro-${var.environment}-ec2-profile"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
