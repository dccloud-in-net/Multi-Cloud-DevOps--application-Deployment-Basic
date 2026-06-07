# ==============================================================================
# AWS Monitoring (CloudWatch Log Group & Alarms)
# ==============================================================================

# CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/bankpro/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# CloudWatch Alarm for High CPU on AWS Auto Scaling Group (Conditional on ASG name being passed)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count               = var.enable_asg_alarm ? 1 : 0
  alarm_name          = "bankpro-${var.environment}-asg-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors EC2 ASG average CPU utilization"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# Azure Monitoring (Log Analytics Workspace)
# ==============================================================================

# Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "bankpro-${var.environment}-law-sub"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Azure Monitor Action Group for Alert Notifications
resource "azurerm_monitor_action_group" "alert_group" {
  name                = "bankpro-${var.environment}-actiongroup"
  resource_group_name = var.resource_group_name
  short_name          = "bp-alerts"

  email_receiver {
    name                    = "SendToDevOps"
    email_address           = "devops-alerts@bankpro.com"
    use_common_alert_schema = true
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
