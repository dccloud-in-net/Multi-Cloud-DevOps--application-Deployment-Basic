# ==============================================================================
# BankPro Multi-Cloud Dev Environment Main Entry
# ==============================================================================

# AWS Key Pair mapping
resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
  tags       = local.common_tags
}

# 1. AWS VPC & Network Components
module "aws_network" {
  source             = "../../modules/aws-network"
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.aws_public_subnets
  private_subnets    = var.aws_private_subnets
  enable_nat_gateway = true
  create_ecr         = true
  ecr_repo_name      = "bankpro-app"
}

# 2. Security Groups & IAM Roles
module "security" {
  source            = "../../modules/security"
  environment       = var.environment
  vpc_id            = module.aws_network.vpc_id
  vpc_cidr          = module.aws_network.vpc_cidr
  allowed_admin_ips = ["0.0.0.0/0"]
}

# 3. AWS Standalone Compute Instances (Bastion & EC2)
module "aws_ec2" {
  source                 = "../../modules/aws-ec2"
  environment            = var.environment
  key_name               = aws_key_pair.deployer.key_name
  public_subnet_id       = module.aws_network.public_subnet_ids[0]
  private_subnet_ids     = module.aws_network.private_subnet_ids
  bastion_sg_id          = module.security.bastion_sg_id
  app_sg_id              = module.security.app_ec2_sg_id
  iam_instance_profile   = module.security.ec2_instance_profile_name
  app_instance_count     = var.aws_app_instance_count
}

# 4. AWS Application Load Balancer
module "aws_alb" {
  source            = "../../modules/aws-alb"
  environment       = var.environment
  vpc_id            = module.aws_network.vpc_id
  public_subnet_ids = module.aws_network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  app_instance_ids  = module.aws_ec2.app_instance_ids
  health_check_path = "/"
}

# 5. AWS Autoscaling Group (ASG) for scalability
module "aws_autoscaling" {
  source               = "../../modules/aws-autoscaling"
  environment          = var.environment
  instance_type        = var.aws_instance_type
  private_subnet_ids   = module.aws_network.private_subnet_ids
  app_sg_id            = module.security.app_ec2_sg_id
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = module.security.ec2_instance_profile_name
  target_group_arn     = module.aws_alb.target_group_arn
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
}

# 6. Azure Resource Group, VNet, NSG & Container Registry
module "azure_network" {
  source              = "../../modules/azure-network"
  environment         = var.environment
  resource_group_name = "bankpro-${var.environment}-rg"
  location            = var.azure_location
  vnet_cidr           = var.azure_vnet_cidr
  subnets             = var.azure_subnets
  create_acr          = true
}

# 7. Azure Load Balancer & VM Computes
module "azure_vm" {
  source              = "../../modules/azure-vm"
  environment         = var.environment
  resource_group_name = module.azure_network.resource_group_name
  location            = module.azure_network.location
  subnet_id           = values(module.azure_network.subnets_map)[0].id
  vm_size             = var.azure_vm_size
  vm_count            = var.azure_vm_count
  admin_username      = "azureuser"
  ssh_public_key      = var.ssh_public_key
}

# 8. Unified Logs/Metric Monitoring
module "monitoring" {
  source              = "../../modules/monitoring"
  environment         = var.environment
  resource_group_name = module.azure_network.resource_group_name
  location            = module.azure_network.location
  asg_name            = module.aws_autoscaling.asg_name
  log_retention_days  = 14
}
