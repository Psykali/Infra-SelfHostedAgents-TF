resource "azurerm_storage_account" "tfstate" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Make it private from the beginning - no public access
  network_rules {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
    
    # Allow Azure services to bypass the rules for backend setup
    bypass = ["AzureServices"]
  }

  tags = {
    Environment = "prod"
    Client      = var.client_name
    Purpose     = "terraform-state"
  }
}

# Create the container immediately since we're using AzureServices bypass
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}