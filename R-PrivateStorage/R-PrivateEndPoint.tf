# =============================================
# PRIVATE ENDPOINT - STORAGE ACCOUNT
# =============================================
# Purpose: Create private endpoint for direct storage access
# Usage: Enables private connectivity without DNS zone

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
  
  # Custom NIC name as per recommendation
  network_interface {
    name = local.private_endpoint_nic_name
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