resource "azurerm_resource_group" "storage" {
  name     = "BSE-${var.client_name}-RG-${var.location}-001"
  location = var.location
  tags = {
    Environment = var.environment
    Client      = var.client_name
  }
}