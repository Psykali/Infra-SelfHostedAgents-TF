terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "BSE-${var.client_name}-RG-${var.location}-001"
    storage_account_name = var.storage_account_name
    container_name       = "tfstate"
    key                  = "stage4-container.tfstate"
  }
}

provider "azurerm" {
  features {}
}