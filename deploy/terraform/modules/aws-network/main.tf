# ==============================================================================
# AWS Network Infrastructure (VPC & Subnets)
# ==============================================================================

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "bankpro-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create Internet Gateway for Public Traffic
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "bankpro-${var.environment}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create Public Subnets using for_each
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "bankpro-${var.environment}-public-${each.key}"
    Type        = "Public"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create Private Subnets using for_each
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name        = "bankpro-${var.environment}-private-${each.key}"
    Type        = "Private"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create Elastic IP for NAT Gateway (Conditional)
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name        = "bankpro-${var.environment}-nat-eip"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create NAT Gateway in the first public subnet (Conditional)
resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  # Retrieve the ID of the first public subnet in the map keyset
  subnet_id = values(aws_subnet.public)[0].id

  tags = {
    Name        = "bankpro-${var.environment}-nat-gw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_internet_gateway.igw]
}

# ==============================================================================
# Route Tables & Routing Rules
# ==============================================================================

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "bankpro-${var.environment}-public-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route Table for Private Subnets (Points to NAT Gateway if enabled)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat[0].id
    }
  }

  tags = {
    Name        = "bankpro-${var.environment}-private-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route Table Associations (Public Subnets)
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations (Private Subnets)
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# ==============================================================================
# Container Registry & Artifact Storage
# ==============================================================================

# Provision ECR Repository for the application
resource "aws_ecr_repository" "app" {
  count                = var.create_ecr ? 1 : 0
  name                 = "bankpro-${var.environment}-${var.ecr_repo_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "bankpro-${var.environment}-${var.ecr_repo_name}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# S3 Bucket for general artifacts and backups
resource "aws_s3_bucket" "artifacts" {
  bucket        = "bankpro-${var.environment}-artifacts-bucket-sub"
  force_destroy = var.environment == "dev" ? true : false

  tags = {
    Name        = "bankpro-${var.environment}-artifacts"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "artifacts_versioning" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_encryption" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
