# =============================================
# TERRAFORM PROVIDERS - DEVOPS AGENTS
# =============================================
# Purpose: Configure Terraform providers for DevOps agents infrastructure
# Usage: Defines Azure provider and backend configuration for remote state storage
# Note: Backend config should be updated after storage account deployment

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.10"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuredevops" {
  org_service_url       = var.azure_devops_org_url
  personal_access_token = var.azure_devops_bootstrap_pat
}