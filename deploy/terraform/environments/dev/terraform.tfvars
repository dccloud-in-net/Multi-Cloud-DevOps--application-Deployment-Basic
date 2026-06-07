# ==============================================================================
# BankPro Dev Environment Values
# ==============================================================================

environment = "dev"
aws_region  = "us-east-1"

# SSH Key Setup (Replace with actual developer public key, or let scripts generate)
# ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPg5L7k3ZqA8kHwR1j/kR4d31w0eN5c3S1x/b0U1hU5w devops@bankpro.com"
ssh_key_name   = "bankpro_dev_key_v2"

# AWS Network Layout
vpc_cidr = "10.0.0.0/16"

aws_public_subnets = {
  pub-1 = { cidr_block = "10.0.1.0/24", availability_zone = "us-east-1a" }
  pub-2 = { cidr_block = "10.0.2.0/24", availability_zone = "us-east-1b" }
}

aws_private_subnets = {
  priv-1 = { cidr_block = "10.0.10.0/24", availability_zone = "us-east-1a" }
  priv-2 = { cidr_block = "10.0.11.0/24", availability_zone = "us-east-1b" }
}

# AWS Computes
aws_instance_type      = "t2.micro"
aws_app_instance_count = 1

# Azure Placement
azure_location = "eastus"

# Azure Network Layout
azure_vnet_cidr = ["10.1.0.0/16"]

azure_subnets = {
  app-1 = { address_prefixes = ["10.1.1.0/24"] }
  app-2 = { address_prefixes = ["10.1.2.0/24"] }
}

# Azure Computes
azure_vm_size  = "Standard_B1s"
azure_vm_count = 1
