# AWS EC2 Module

This module deploys the standalone EC2 compute instances for BankPro:
1. Bastion Host in a public subnet for jump-box SSH automation.
2. Standalone Application VM instances in private subnets.

## Example Usage

```hcl
module "aws_ec2" {
  source                = "../../modules/aws-ec2"
  environment           = "dev"
  key_name              = "bankpro_deploy_key"
  public_subnet_id      = "subnet-pub-1234"
  private_subnet_ids     = ["subnet-priv-1234", "subnet-priv-5678"]
  bastion_sg_id         = "sg-bastion"
  app_sg_id             = "sg-app"
  iam_instance_profile  = "ec2-iam-instance-profile-name"
  app_instance_count    = 2
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `ami_id` | `string` | `""` | Optional AMI ID override (defaults to latest Amazon Linux 2) |
| `instance_type` | `string` | `"t3.micro"` | Size of the application instances |
| `bastion_instance_type` | `string` | `"t3.micro"` | Size of the Bastion instances |
| `public_subnet_id` | `string` | N/A | Subnet ID for the Bastion Host |
| `private_subnet_ids` | `list(string)` | N/A | List of subnets for App Instances |
| `bastion_sg_id` | `string` | N/A | Security Group ID for Bastion |
| `app_sg_id` | `string` | N/A | Security Group ID for App instances |
| `key_name` | `string` | N/A | SSH Keypair Name |
| `iam_instance_profile` | `string` | N/A | IAM instance profile mapping |
| `environment` | `string` | N/A | Environment name (dev/stage/prod) |
| `app_instance_count` | `number` | `1` | Number of EC2 instances to provision |

## Outputs

| Name | Description |
|------|-------------|
| `bastion_public_ip` | Bastion Host public IP |
| `app_private_ips` | Array of Private IPs for App instances |
| `app_instance_ids` | Array of Instance IDs for App instances |
