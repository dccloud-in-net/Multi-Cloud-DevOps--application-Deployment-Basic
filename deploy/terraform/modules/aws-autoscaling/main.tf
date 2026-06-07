# ==============================================================================
# AWS Autoscaling (Launch Template, ASG, and Policies)
# ==============================================================================

data "aws_ami" "amazon_linux_2_asg" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  selected_ami_asg = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2_asg.id
}

# 1. Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "bankpro-${var.environment}-lt-"
  image_id      = local.selected_ami_asg
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Starting launch template initialization..."
              yum update -y
              mkdir -p /var/log/bankpro
              chown -R ec2-user:ec2-user /var/log/bankpro
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "bankpro-${var.environment}-asg-node"
      Role        = "Application"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 2. Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name_prefix         = "bankpro-${var.environment}-asg-"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  force_delete          = true
  health_check_type     = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# 3. Target Tracking Scaling Policy (CPU-based)
resource "aws_autoscaling_policy" "cpu" {
  name                   = "bankpro-${var.environment}-cpu-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0 # Scales up/down to maintain ~70% CPU usage
  }
}
