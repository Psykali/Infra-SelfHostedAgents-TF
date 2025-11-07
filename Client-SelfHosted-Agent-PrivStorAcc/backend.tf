terraform {
  backend "azurerm" {
    resource_group_name  = "rg-state-storage"
    storage_account_name = "statestoragetfdevops"
    container_name       = "tfstate"
    key                  = "devops-agents.tfstate"
  }
}