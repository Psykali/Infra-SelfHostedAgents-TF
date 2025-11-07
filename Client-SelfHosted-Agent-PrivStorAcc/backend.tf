# This backend configuration will be used after the storage account is created
# Initially, run without backend, then uncomment and terraform init -migrate-state

/*
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-storage-francecentral"
    storage_account_name = "statetfdevopsfrc01"
    container_name       = "tfstate"
    key                  = "devops-agent.terraform.tfstate"
  }
}
*/