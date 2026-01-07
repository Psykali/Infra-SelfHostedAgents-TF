# =============================================
# PRIVATE ENDPOINT CONNECTION (MVP)
# =============================================
# Purpose: Direct connection from VM subnet to storage
# Usage: VM uses this private endpoint to access storage

# Get existing subnet from AgentVM deployment
data "azurerm_subnet" "agents" {
  name                 = local.subnet_name
  resource_group_name  = local.network_rg_name
  virtual_network_name = local.vnet_name
}

# Private Endpoint for Storage Blob service
resource "azurerm_private_endpoint" "storage" {
  name                = "pep-${local.storage_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.storage.name
  subnet_id           = data.azurerm_subnet.agents.id  # Connect to VM's subnet

  private_service_connection {
    name                           = "pepcon-${local.storage_name}"
    private_connection_resource_id = azurerm_storage_account.private.id
    subresource_names              = ["blob"]  # Allow blob access
    is_manual_connection           = false
  }

  tags = local.common_tags
  
  depends_on = [
    azurerm_storage_account.private,
    azurerm_storage_account_network_rules.private
  ]
}