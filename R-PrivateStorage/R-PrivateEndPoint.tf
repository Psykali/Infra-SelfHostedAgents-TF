# =============================================
# PRIVATE ENDPOINT - STORAGE ACCOUNT
# =============================================
# Purpose: Create private endpoint for direct storage access
# Note: Uses dedicated subnet for private endpoints (10.0.0.32/27)

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

  tags = merge(local.common_tags, {
    Description = "Private endpoint for Terraform state storage"
  })
}

### ------------------------------------------------
### Dedicated subnet for private endpoints
### ------------------------------------------------
resource "azurerm_subnet" "private_endpoint" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = local.networking_rg_name
  virtual_network_name = local.vnet_name
  address_prefixes     = ["10.0.0.32/27"]
  
  # Private endpoint policies
  private_endpoint_network_policies = "Enabled"
  
  # Service endpoint for storage
  service_endpoints = ["Microsoft.Storage"]
  
  lifecycle {
    ignore_changes = [
      # Ignore changes to service endpoints as they're managed by Azure
      service_endpoints,
    ]
  }
}