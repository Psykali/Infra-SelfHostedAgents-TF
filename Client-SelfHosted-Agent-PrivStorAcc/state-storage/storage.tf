resource "azurerm_resource_group" "state_storage" {
  provider = azurerm.state_storage
  name     = "rg-state-storage"
  location = var.location
  tags = {
    Purpose = "Terraform-State-Storage"
  }
}

resource "azurerm_storage_account" "state" {
  provider                 = azurerm.state_storage
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.state_storage.name
  location                 = azurerm_resource_group.state_storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = []
  }

  tags = {
    Purpose = "Terraform-State-Storage"
  }
}

resource "azurerm_storage_container" "tfstate" {
  provider             = azurerm.state_storage
  name                 = "tfstate"
  storage_account_name = azurerm_storage_account.state.name
  container_access_type = "private"
}