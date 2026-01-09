# =============================================
# PRIVATE ENDPOINT CONNECTION 
# =============================================
# Purpose: Direct connection from VM subnet to storage
# Usage: VM uses this private endpoint to access storage

# Create private endpoint FIRST
resource "azurerm_private_endpoint" "storage" {
  name                = local.private_endpoint_name
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
#  subnet_id           = data.azurerm_subnet.private_endpoint.id
  subnet_id = azurerm_subnet.private_endpoint.id
  
  private_service_connection {
    name                           = local.private_endpoint_connection_name
    private_connection_resource_id = azurerm_storage_account.private.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = local.common_tags
}

# Network rules - allow private endpoint subnet ONLY
resource "azurerm_storage_account_network_rules" "private" {
  storage_account_id = azurerm_storage_account.private.id
  
  default_action = "Deny"
  
#  virtual_network_subnet_ids = [data.azurerm_subnet.private_endpoint.id]
  virtual_network_subnet_ids = [azurerm_subnet.private_endpoint.id]
  
  bypass = ["AzureServices"]
  
  depends_on = [azurerm_private_endpoint.storage]
}

# Wait for private endpoint to be fully ready
resource "null_resource" "wait_for_private_endpoint" {
  depends_on = [
    azurerm_private_endpoint.storage,
    azurerm_storage_account_network_rules.private
  ]

  provisioner "local-exec" {
    command = "sleep 60"
    interpreter = ["/bin/sh", "-c"]
  }
}