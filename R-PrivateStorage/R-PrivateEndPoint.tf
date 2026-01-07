# =============================================
# PRIVATE ENDPOINT CONNECTION (MVP)
# =============================================
# Purpose: Direct connection from VM subnet to storage
# Usage: VM uses this private endpoint to access storage

resource "azurerm_private_endpoint" "storage" {
  name                = local.private_endpoint_name
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
  subnet_id           = data.azurerm_subnet.agents.id  # Use existing VM subnet

  private_service_connection {
    name                           = local.private_endpoint_connection_name
    private_connection_resource_id = azurerm_storage_account.private.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = local.common_tags
  
  depends_on = [
    azurerm_storage_account_network_rules.private,
    null_resource.disable_public_access
  ]
}