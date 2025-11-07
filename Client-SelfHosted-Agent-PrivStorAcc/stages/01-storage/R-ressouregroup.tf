resource "azurerm_resource_group" "storage" {
  name     = "BSE-${var.client_name}-RG-001"
  location = var.location
  tags = {
    Environment = "prod"
    Client      = var.client_name
  }
}