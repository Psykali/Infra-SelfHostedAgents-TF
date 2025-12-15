### ---------------------------
### Resource Group for Storage
### ---------------------------
resource "azurerm_resource_group" "storage" {
  name     = local.storage_rg_name
  location = var.location
}