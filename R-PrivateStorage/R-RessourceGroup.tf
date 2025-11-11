# Resource Group for Storage
resource "azurerm_resource_group" "storage" {
  name     = var.storage_rg_name
  location = var.location
}