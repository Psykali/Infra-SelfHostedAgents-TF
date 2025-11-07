resource "azurerm_resource_group" "test" {
  name     = "BSE-${var.client_name}-RG-TEST-${var.location}-001"
  location = var.location
  tags = {
    Environment = "test"
    Client      = var.client_name
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "test-container"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "test" {
  name                   = "test-file.txt"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Block"
  source_content         = "This is a test file created via private endpoint connection"
}