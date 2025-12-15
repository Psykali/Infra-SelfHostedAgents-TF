### ------------------------------------------------
### Dedicated subnet for private endpoints (no DNS)
### ------------------------------------------------
resource "azurerm_subnet" "private_endpoint" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = azurerm_resource_group.storage.name
  virtual_network_name = local.vnet_name
  address_prefixes     = ["10.0.0.0/27"]

  service_endpoints = ["Microsoft.Storage"]
  
  # Allow private-endpoint policies to be applied
  private_endpoint_network_policies = "Enabled"
}

### -------------------------
### Private endpoint (no DNS zone)
### -------------------------
resource "azurerm_private_endpoint" "storage" {
  name                = local.private_endpoint_name
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
  subnet_id           = azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = local.private_endpoint_connection_name
    private_connection_resource_id = azurerm_storage_account.private.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}