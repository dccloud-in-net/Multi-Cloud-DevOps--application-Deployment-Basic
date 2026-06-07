# ==============================================================================
# AWS Compute Instances (Bastion & Application Servers)
# ==============================================================================

# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  selected_ami = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2.id
}

# 1. Bastion Host (Public Subnet)
resource "aws_instance" "bastion" {
  ami                         = local.selected_ami
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "bankpro-${var.environment}-bastion"
    Role        = "Bastion"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 2. Application Instances (Private Subnets)
resource "aws_instance" "app" {
  count         = var.app_instance_count
  ami           = local.selected_ami
  instance_type = var.instance_type
  # Cycle through available private subnets to balance instances
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Starting EC2 initialization..."
              yum update -y
              # Standard logs directory configuration
              mkdir -p /var/log/bankpro
              chown -R ec2-user:ec2-user /var/log/bankpro
              EOF

  tags = {
    Name        = "bankpro-${var.environment}-app-ec2-${count.index + 1}"
    Role        = "Application"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
