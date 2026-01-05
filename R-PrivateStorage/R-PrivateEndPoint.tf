# =============================================
# PRIVATE ENDPOINT - STORAGE ACCOUNT
# =============================================
# Purpose: Create private endpoint for direct storage access
# Location: storage-account/ folder ONLY

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
  
  # Custom NIC name
  network_interface {
    name = local.private_endpoint_nic_name
  }
  
  tags = merge(local.common_tags, {
    Component = "networking"
    Service   = "storage"
  })
}