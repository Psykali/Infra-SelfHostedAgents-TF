# =============================================
# PRIVATE ENDPOINT - STORAGE ACCOUNT
# =============================================
# Purpose: Create private endpoint for direct storage access
# FIXED: Removed custom network_interface configuration

resource "azurerm_private_endpoint" "storage" {
  name                = local.private_endpoint_name
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
  subnet_id           = data.azurerm_subnet.agents.id
  
  private_service_connection {
    name                           = "${local.storage_account_name}-connection"
    private_connection_resource_id = azurerm_storage_account.private.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  
  tags = merge(local.common_tags, {
    Component = "networking"
    Service   = "storage"
  })
  
  depends_on = [
    azurerm_storage_account.private,
    azurerm_storage_container.tfstate
  ]
}