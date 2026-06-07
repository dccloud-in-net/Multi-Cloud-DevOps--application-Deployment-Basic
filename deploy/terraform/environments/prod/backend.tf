# ==============================================================================
# Terraform Backend Configuration - Prod
# ==============================================================================
# terraform {
#   backend "s3" {
#     bucket         = "bankpro-prod-tfstate-bucket"
#     key            = "prod/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "bankpro-prod-tflocks"
#     encrypt        = true
#   }
# }
