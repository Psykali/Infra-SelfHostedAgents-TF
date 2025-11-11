resource "azurerm_storage_account" "private" {
  name                     = var.private_storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Enable private network access
  public_network_access_enabled = false

  tags = {
    environment = "devops"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.tfstate_container_name
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"

  # Wait for private endpoint to be ready
  depends_on = [
      azurerm_private_endpoint.storage,
      azurerm_storage_account.private
      ]
}