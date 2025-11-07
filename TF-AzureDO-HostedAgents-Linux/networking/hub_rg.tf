resource "azurerm_resource_group" "hub_networking" {
  name     = "rg-hub-networking-${var.location}"
  location = var.location
  tags = {
    Environment = "Production"
    Component   = "Networking"
  }
}