# AWS Application Load Balancer (ALB) Module

This module deploys the Application Load Balancer to route traffic to the target Spring Boot microservice instances.

## Features
- Public ALB in designated public subnets.
- HTTP Listener (Port 80) forwarding to Target Group.
- Target Group checking health at `/` (or specified path) on Port 8080.
- Optional static attaching of EC2 standalone instances.

## Example Usage

```hcl
module "aws_alb" {
  source            = "../../modules/aws-alb"
  vpc_id            = "vpc-12345"
  public_subnet_ids = ["subnet-pub-1", "subnet-pub-2"]
  alb_sg_id         = "sg-alb-123"
  environment       = "dev"
  app_instance_ids  = ["i-0123456789abcdef0"]
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `vpc_id` | `string` | N/A | Target VPC ID |
| `public_subnet_ids` | `list(string)` | N/A | Subnet IDs where ALB will sit |
| `alb_sg_id` | `string` | N/A | Security Group ID for ALB |
| `environment` | `string` | N/A | Environment name (dev/stage/prod) |
| `app_instance_ids` | `list(string)` | `[]` | Standalone EC2 instance IDs to bind |
| `health_check_path` | `string` | `"/"` | Path to probe for health status |

## Outputs

| Name | Description |
|------|-------------|
| `alb_dns_name` | Public DNS address of the load balancer |
| `alb_arn` | ARN of the load balancer |
| `target_group_arn` | Target Group ARN |
