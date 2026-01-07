# =============================================
# TERRAFORM PROVIDERS - STORAGE ACCOUNT
# =============================================
# Purpose: Configure Terraform providers for storage account deployment
# Note: Initial deployment uses local state, then migrate to this storage

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true  # Protect storage RG
    }
  }
}