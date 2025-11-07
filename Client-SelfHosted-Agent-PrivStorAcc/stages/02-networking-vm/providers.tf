terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "BSE-CLIENT-RG-FRANCE-CENTRAL-001"
    storage_account_name = "bseclientstfrancecentral001"
    container_name       = "tfstate"
    key                  = "networking-vm.tfstate"
  }
}

provider "azurerm" {
  features {}
}