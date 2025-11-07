resource "azurerm_resource_group" "spoke_networking" {
  name     = "rg-spoke-networking-${var.location}"
  location = var.location
  tags = {
    Environment = "Production"
    Component   = "Networking"
  }
}