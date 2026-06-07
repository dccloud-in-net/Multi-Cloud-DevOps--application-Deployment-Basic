# ==============================================================================
# Terraform Backend Configuration
# ==============================================================================
# In a true multi-cloud environment, state is typically stored in either:
# 1. AWS S3 with a DynamoDB Lock Table.
# 2. Azure Blob Storage with a lease lock.
# We comment this out to allow local validation and state testing by default.
# Uncomment and customize during pipeline onboarding.

# terraform {
#   backend "s3" {
#     bucket         = "bankpro-dev-tfstate-bucket"
#     key            = "dev/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "bankpro-dev-tflocks"
#     encrypt        = true
#   }
# }
