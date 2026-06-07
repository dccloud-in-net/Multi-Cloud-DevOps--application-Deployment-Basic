# AWS Auto Scaling Group (ASG) Module

This module configures the Launch Template and Auto Scaling Group to support scalable application node pools.

## Features
- Launch Template with disk security and standard user_data logging paths.
- Auto Scaling Group tied to designated private subnets.
- Preconfigured Target Tracking scaling policy targeting 70% CPU usage.

## Example Usage

```hcl
module "aws_autoscaling" {
  source               = "../../modules/aws-autoscaling"
  environment          = "dev"
  instance_type        = "t3.micro"
  private_subnet_ids   = ["subnet-priv-1", "subnet-priv-2"]
  app_sg_id            = "sg-app-123"
  key_name             = "bankpro_deploy_key"
  iam_instance_profile = "profile-name"
  target_group_arn     = "tg-arn"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `environment` | `string` | N/A | Environment name (dev/stage/prod) |
| `instance_type` | `string` | `"t3.micro"` | Instance class to launch |
| `ami_id` | `string` | `""` | AMI ID to use (resolves to latest Amazon Linux 2 if blank) |
| `private_subnet_ids` | `list(string)` | N/A | Subnet IDs where VMs are deployed |
| `app_sg_id` | `string` | N/A | Security Group ID |
| `key_name` | `string` | N/A | Key Pair Name |
| `iam_instance_profile` | `string` | N/A | IAM Instance profile name |
| `target_group_arn` | `string` | N/A | ALB Target Group ARN |
| `min_size` | `number` | `1` | Minimum running instances |
| `max_size` | `number` | `3` | Maximum running instances |
| `desired_capacity` | `number` | `1` | Desired running instances |

## Outputs

| Name | Description |
|------|-------------|
| `asg_name` | Name of the ASG |
| `asg_arn` | ARN of the ASG |
| `asg_id` | ID of the ASG |
