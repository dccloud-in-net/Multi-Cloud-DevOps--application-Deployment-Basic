# AWS Security Module

This module implements least-privilege access and network level restriction rules (Security Groups) for the BankPro system.

## Features
- Application Load Balancer Security Group (allows Port 80/443 public).
- Bastion Host Security Group (allows Port 22 from admin/developer IPs).
- App Instance Security Group (restricts Port 8080 only to ALB and Port 22 only to Bastion).
- IAM roles and policies for pulling container images from ECR and reporting logs/metrics to CloudWatch.

## Example Usage

```hcl
module "security" {
  source      = "../../modules/security"
  vpc_id      = "vpc-12345"
  vpc_cidr    = "10.0.0.0/16"
  environment = "dev"

  allowed_admin_ips = ["203.0.113.0/24"]
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `vpc_id` | `string` | N/A | Target VPC where security groups will sit |
| `vpc_cidr` | `string` | N/A | VPC subnet boundary CIDR |
| `environment` | `string` | N/A | Environment name (dev/stage/prod) |
| `allowed_admin_ips` | `list(string)` | `["0.0.0.0/0"]` | Authorized CIDRs for SSH access |

## Outputs

| Name | Description |
|------|-------------|
| `alb_sg_id` | ALB Security Group ID |
| `bastion_sg_id` | Bastion Security Group ID |
| `app_ec2_sg_id` | EC2 Instances Security Group ID |
| `ec2_instance_profile_name` | IAM Instance Profile name |
