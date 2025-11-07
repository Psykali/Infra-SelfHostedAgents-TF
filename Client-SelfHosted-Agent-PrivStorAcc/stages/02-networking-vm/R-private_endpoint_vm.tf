resource "azurerm_private_endpoint" "storage_from_vm" {
  name                = "BSE-${var.client_name}-PE-VM-${var.location}-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "BSE-${var.client_name}-PSC-VM-${var.location}-001"
    private_connection_resource_id = var.storage_account_id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = {
    Environment = "prod"
    Client      = var.client_name
  }
}