terraform {
  required_version = ">= 1.0"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "BSE-CLIENT-RG-FRANCE-CENTRAL-001"
    storage_account_name = "bseclientstfrancecentral001"
    container_name       = "tfstate"
    key                  = "ado-agent.tfstate"
  }
}

provider "azuredevops" {
  # PAT will be provided via environment variable AZDO_PERSONAL_ACCESS_TOKEN
  org_service_url = "https://dev.azure.com/${var.ado_organization}"
}