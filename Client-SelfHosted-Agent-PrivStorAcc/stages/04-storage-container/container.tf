data "azurerm_storage_account" "tfstate" {
  name                = var.storage_account_name
  resource_group_name = "BSE-${var.client_name}-RG-${var.location}-001"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = data.azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Make storage account private now that we have private endpoint
resource "azurerm_storage_account_network_rules" "private" {
  storage_account_id = data.azurerm_storage_account.tfstate.id

  default_action             = "Deny"
  ip_rules                   = []
  virtual_network_subnet_ids = [var.private_endpoint_subnet_id]

  # Allow Azure services to access the storage account
  bypass = ["AzureServices"]
}

resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = data.azurerm_storage_account.tfstate.name
  container_access_type = "private"
}