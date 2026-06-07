# ==============================================================================
# AWS Application Load Balancer (ALB) Configuration
# ==============================================================================

# 1. External Application Load Balancer
resource "aws_lb" "external" {
  name               = "bankpro-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "bankpro-${var.environment}-alb"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 2. Target Group for Spring Boot Application (Port 8080)
resource "aws_lb_target_group" "app" {
  name        = "bankpro-${var.environment}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "8080"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name        = "bankpro-${var.environment}-tg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 3. HTTP Listener on Port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# 4. Attach Standalone EC2 Instances to Target Group (Conditional)
resource "aws_lb_target_group_attachment" "app_attach" {
  count            = length(var.app_instance_ids)
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.app_instance_ids[count.index]
  port             = 8080
}
