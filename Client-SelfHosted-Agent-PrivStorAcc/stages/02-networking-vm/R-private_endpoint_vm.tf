data "azurerm_storage_account" "tfstate" {
  name                = "bse${var.client_name}st${var.location}001"
  resource_group_name = "BSE-${var.client_name}-RG-${var.location}-001"
}

resource "azurerm_private_endpoint" "storage" {
  name                = "BSE-${var.client_name}-PE-${var.location}-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "BSE-${var.client_name}-PSC-${var.location}-001"
    private_connection_resource_id = data.azurerm_storage_account.tfstate.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = {
    Environment = "prod"
    Client      = var.client_name
  }
}