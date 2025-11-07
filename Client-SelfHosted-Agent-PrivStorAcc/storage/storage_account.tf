resource "azurerm_storage_account" "tfstate" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # Enable private access
  public_network_access_enabled = false

  # Enable infrastructure encryption for additional security
  infrastructure_encryption_enabled = true

  min_tls_version = "TLS1_2"

  tags = {
    Environment = "Production"
    Purpose     = "Terraform-State"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Network rules to allow access only from private endpoints and specific subnets
resource "azurerm_storage_account_network_rules" "tfstate" {
  storage_account_id = azurerm_storage_account.tfstate.id

  default_action             = "Deny"
  ip_rules                   = [] # No public IP access
  virtual_network_subnet_ids = [
    azurerm_subnet.vm.id,
    azurerm_subnet.private_endpoints.id
  ]

  # Allow trusted Microsoft services
  bypass = ["AzureServices"]
}