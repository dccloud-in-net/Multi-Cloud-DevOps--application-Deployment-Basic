# Multi-Cloud Monitoring Module

This module implements basic centralized log aggregation and alerts across both AWS and Azure clouds.

## Features
- AWS CloudWatch Log Group with customizable retention.
- AWS CloudWatch high CPU utilization metric alarm targeting ASG.
- Azure Log Analytics Workspace for log collection.
- Azure Monitor Action Group for email/DevOps notifications.

## Example Usage

```hcl
module "monitoring" {
  source              = "../../modules/monitoring"
  environment         = "dev"
  resource_group_name = "bankpro-dev-rg"
  location            = "eastus"
  asg_name            = "bankpro-dev-asg-xyz"
  log_retention_days  = 30
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `environment` | `string` | N/A | Environment name (dev/stage/prod) |
| `resource_group_name` | `string` | N/A | Target Resource Group name (Azure) |
| `location` | `string` | N/A | Target region (Azure) |
| `asg_name` | `string` | `""` | Optional Target ASG Name (AWS) |
| `log_retention_days` | `number` | `30` | Days to keep logs |

## Outputs

| Name | Description |
|------|-------------|
| `cloudwatch_log_group_name` | AWS Log Group Name |
| `azure_log_analytics_workspace_id` | Azure Log Analytics Workspace ID |
| `azure_action_group_id` | Azure Alert Action Group ID |
