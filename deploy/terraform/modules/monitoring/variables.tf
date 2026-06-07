variable "environment" {
  type        = string
  description = "Environment identifier (e.g. dev, stage, prod)"
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group name for Azure monitor resources"
}

variable "location" {
  type        = string
  description = "Azure region for placing monitoring workspaces"
}

variable "asg_name" {
  type        = string
  default     = ""
  description = "AWS Autoscaling Group name to target CPU utilization alarms"
}

variable "log_retention_days" {
  type        = number
  default     = 30
  description = "Number of days to retain metrics/logs"
}
