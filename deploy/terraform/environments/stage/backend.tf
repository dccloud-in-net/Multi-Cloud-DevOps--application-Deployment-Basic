# ==============================================================================
# Terraform Backend Configuration - Stage
# ==============================================================================
# terraform {
#   backend "s3" {
#     bucket         = "bankpro-stage-tfstate-bucket"
#     key            = "stage/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "bankpro-stage-tflocks"
#     encrypt        = true
#   }
# }
