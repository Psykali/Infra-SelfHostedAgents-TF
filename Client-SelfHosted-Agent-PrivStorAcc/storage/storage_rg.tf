resource "azurerm_resource_group" "storage" {
  name     = "rg-storage-${var.location}"
  location = var.location
  tags = {
    Environment = "Production"
    Component   = "Storage"
    Purpose     = "Terraform-State"
  }
}