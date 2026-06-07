# AWS Network Module

This module sets up the foundational networking components in AWS for the BankPro application.

## Resources Created
- VPC with DNS options enabled
- Internet Gateway (IGW)
- Public & Private Subnets using `for_each` and AZ mappings
- Elastic IP & NAT Gateway (Conditional)
- Public and Private Route Tables
- AWS Elastic Container Registry (ECR)
- Secure S3 Bucket for Artifact Storage

## Example Usage

```hcl
module "aws_network" {
  source      = "../../modules/aws-network"
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"

  public_subnets = {
    pub-1 = { cidr_block = "10.0.1.0/24", availability_zone = "us-east-1a" }
    pub-2 = { cidr_block = "10.0.2.0/24", availability_zone = "us-east-1b" }
  }

  private_subnets = {
    priv-1 = { cidr_block = "10.0.10.0/24", availability_zone = "us-east-1a" }
    priv-2 = { cidr_block = "10.0.11.0/24", availability_zone = "us-east-1b" }
  }

  enable_nat_gateway = true
  create_ecr         = true
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `vpc_cidr` | `string` | N/A | VPC network boundary CIDR |
| `public_subnets` | `map(object)` | N/A | Public subnets mapping details |
| `private_subnets` | `map(object)` | N/A | Private subnets mapping details |
| `environment` | `string` | N/A | Environment name (dev/stage/prod) |
| `enable_nat_gateway` | `bool` | `true` | Enable NGW for private internet |
| `create_ecr` | `bool` | `true` | Create Container Registry |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | AWS VPC ID |
| `public_subnet_ids` | IDs of public subnets |
| `private_subnet_ids` | IDs of private subnets |
| `ecr_repository_url` | ECR Registry endpoint |
| `artifacts_bucket_name` | Managed S3 Bucket name |
