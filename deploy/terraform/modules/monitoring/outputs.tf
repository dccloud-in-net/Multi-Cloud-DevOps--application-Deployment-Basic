output "cloudwatch_log_group_name" {
  value       = aws_cloudwatch_log_group.app_logs.name
  description = "The name of the CloudWatch Log Group for application logs"
}

output "azure_log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.law.id
  description = "The Resource ID of the Azure Log Analytics Workspace"
}

output "azure_log_analytics_workspace_name" {
  value       = azurerm_log_analytics_workspace.law.name
  description = "The Name of the Azure Log Analytics Workspace"
}

output "azure_action_group_id" {
  value       = azurerm_monitor_action_group.alert_group.id
  description = "The Resource ID of the Azure Monitor Action Group"
}
