# ==============================================================================
# BankPro Prod Environment Values
# ==============================================================================

environment = "prod"
aws_region  = "us-east-1"

# SSH Key Setup
# ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPg5L7k3ZqA8kHwR1j/kR4d31w0eN5c3S1x/b0U1hU5w devops@bankpro.com"
ssh_key_name   = "bankpro_prod_key"

# AWS Network Layout
vpc_cidr = "10.4.0.0/16"

aws_public_subnets = {
  pub-1 = { cidr_block = "10.4.1.0/24", availability_zone = "us-east-1a" }
  pub-2 = { cidr_block = "10.4.2.0/24", availability_zone = "us-east-1b" }
}

aws_private_subnets = {
  priv-1 = { cidr_block = "10.4.10.0/24", availability_zone = "us-east-1a" }
  priv-2 = { cidr_block = "10.4.11.0/24", availability_zone = "us-east-1b" }
}

# AWS Computes
aws_instance_type      = "t3.large"
aws_app_instance_count = 3

# Azure Placement
azure_location = "eastus"

# Azure Network Layout
azure_vnet_cidr = ["10.5.0.0/16"]

azure_subnets = {
  app-1 = { address_prefixes = ["10.5.1.0/24"] }
  app-2 = { address_prefixes = ["10.5.2.0/24"] }
}

# Azure Computes
azure_vm_size  = "Standard_D2s_v5"
azure_vm_count = 3
