# This script is only to test the connection to the backend of the selfhosted agent
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "client-tfstate-storage-rg"
    storage_account_name = "clienttfprivstacc"
    container_name       = "client-tfstate"
    key                  = "test-resources.tfstate"
    # Uncomment if using storage account key:
    # storage_account_key = "your-storage-account-key"
  }
}

provider "azurerm" {
  features {}
}

# Simple test resource group
resource "azurerm_resource_group" "test" {
  name     = "rg-client-simple-test"
  location = "francecentral"

  tags = {
    Environment = "Test"
    DeployedVia = "Terraform with Private Backend"
  }
}

# Output to verify
output "test_resource_group_id" {
  value = azurerm_resource_group.test.id
}

output "backend_info" {
  value = "State stored in: clienttfprivstacc/client-tfstate/test-resources.tfstate"
}