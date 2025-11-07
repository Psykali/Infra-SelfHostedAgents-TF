resource "azurerm_private_endpoint" "storage" {
  name                = "BSE-${var.client_name}-PE-${var.location}-001"
  resource_group_name = azurerm_resource_group.storage.name
  location            = var.location
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "BSE-${var.client_name}-PSC-${var.location}-001"
    private_connection_resource_id = azurerm_storage_account.tfstate.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = {
    Environment = var.environment
    Client      = var.client_name
  }
}