# ==============================================================================
# Terraform Backend Configuration - Stage
# ==============================================================================

terraform {
  backend "azurerm" {
    resource_group_name  = "REVA-RACE-PROJECT-ACCESS"
    storage_account_name = "devopsracerevaprodccloud"
    container_name       = "revaprotfstate"
    key                  = "stage.aks-multicloudapp.tfstate"
  }
}
