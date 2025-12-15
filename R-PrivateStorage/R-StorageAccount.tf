### ------------------------------------------
### Storage Account with public access Denied 
### ------------------------------------------
resource "azurerm_storage_account" "private" {
  name                     = local.private_storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = false
  tags = {
    environment = "devops"
  }
}

resource "azurerm_storage_account_network_rules" "private" {
  storage_account_id = azurerm_storage_account.private.id
  
  # DENY all traffic by default
  default_action = "Deny"
  # Allow private endpoint subnet
  virtual_network_subnet_ids = [azurerm_subnet.private_endpoint.id]
  # Allow Azure services (required for private endpoints and other Azure services)
  bypass = ["AzureServices"]
}

resource "null_resource" "wait_for_full_setup" {
  depends_on = [
    azurerm_private_endpoint.storage,
  ]

  provisioner "local-exec" {
    command = "sleep 300"  # Wait for private endpoint to be fully ready
  }
}

### ---------------------
### Creat Blob Container 
### ---------------------
resource "azurerm_storage_container" "tfstate" {
  name                  = local.tfstate_container_name
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"

  depends_on = [null_resource.wait_for_full_setup]
}