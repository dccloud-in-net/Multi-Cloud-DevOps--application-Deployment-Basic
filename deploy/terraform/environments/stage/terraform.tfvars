# ==============================================================================
# BankPro Stage Environment Values
# ==============================================================================

environment = "stage"
aws_region  = "us-east-1"

# SSH Key Setup
# ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPg5L7k3ZqA8kHwR1j/kR4d31w0eN5c3S1x/b0U1hU5w devops@bankpro.com"
ssh_key_name   = "bankpro_stage_key"

# AWS Network Layout
vpc_cidr = "10.2.0.0/16"

aws_public_subnets = {
  pub-1 = { cidr_block = "10.2.1.0/24", availability_zone = "us-east-1a" }
  pub-2 = { cidr_block = "10.2.2.0/24", availability_zone = "us-east-1b" }
}

aws_private_subnets = {
  priv-1 = { cidr_block = "10.2.10.0/24", availability_zone = "us-east-1a" }
  priv-2 = { cidr_block = "10.2.11.0/24", availability_zone = "us-east-1b" }
}

# AWS Computes
aws_instance_type      = "t3.medium"
aws_app_instance_count = 2

# Azure Placement
azure_location = "eastus"

# Azure Network Layout
azure_vnet_cidr = ["10.3.0.0/16"]

azure_subnets = {
  app-1 = { address_prefixes = ["10.3.1.0/24"] }
  app-2 = { address_prefixes = ["10.3.2.0/24"] }
}

# Azure Computes
azure_vm_size  = "Standard_B2s"
azure_vm_count = 2
