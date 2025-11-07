# Data source to get storage account info dynamically
data "azurerm_storage_account" "tfstate" {
  name                = var.storage_account_name
  resource_group_name = "BSE-${var.client_name}-RG-${var.location}-001"
}

# Update storage account network rules to remove deployment IP and add private endpoint
resource "azurerm_storage_account_network_rules" "private_with_pe" {
  storage_account_id = data.azurerm_storage_account.tfstate.id

  default_action             = "Deny"
  ip_rules                   = []  # Remove deployment IP
  virtual_network_subnet_ids = [var.private_endpoint_subnet_id]

  # Allow Azure services only (no more deployment IP)
  bypass = ["AzureServices"]
}

# Test that private endpoint is working
resource "azurerm_storage_blob" "connection_test" {
  name                   = "private-endpoint-test.txt"
  storage_account_name   = data.azurerm_storage_account.tfstate.name
  storage_container_name = "tfstate"
  type                   = "Block"
  source_content         = "This file was created via private endpoint connection at ${timestamp()}"
  
  depends_on = [azurerm_storage_account_network_rules.private_with_pe]
}