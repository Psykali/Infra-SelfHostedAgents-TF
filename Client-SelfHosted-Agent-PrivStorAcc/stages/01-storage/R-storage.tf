resource "azurerm_storage_account" "tfstate" {
  name                     = "bseclientstfr001"
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Allow public access initially for Terraform backend setup
  network_rules {
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  tags = {
    Environment = "prod"
    Client      = var.client_name
    Purpose     = "terraform-state"
  }
}

# Note: Container will be created in Stage 4 after private endpoint