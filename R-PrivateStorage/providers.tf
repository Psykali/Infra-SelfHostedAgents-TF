### =============================================
### PROVIDERS FOR STORAGE DEPLOYMENT
### =============================================
### Purpose: Configures Terraform providers for storage account deployment
### Note: Initial deployment has no backend. After first deploy, configure backend.

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Azure provider configuration
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}