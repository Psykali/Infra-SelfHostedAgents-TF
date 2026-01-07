# =============================================
# PRIVATE STORAGE ACCOUNT FOR TERRAFORM STATE
# =============================================
# Purpose: Create private storage account for Terraform state
# Usage: Backend storage with private endpoint connectivity

resource "azurerm_storage_account" "private" {
  name                     = local.private_storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  min_tls_version          = "TLS1_2"
  
  # 🔒 Private storage - no public access
  public_network_access_enabled = false
  
  # Enable blob storage
  account_kind = "StorageV2"
  
  # Enable blob properties
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = merge(local.common_tags, {
    Description = "Private storage for Terraform state files"
    Critical    = "true"  # Contains infrastructure state
  })
  
  lifecycle {
    prevent_destroy = true  # Critical: Contains Terraform state!
  }
}

# Network rules - deny all except private endpoint
resource "azurerm_storage_account_network_rules" "private" {
  storage_account_id = azurerm_storage_account.private.id
  
  # DENY all traffic by default
  default_action = "Deny"
  
  # Allow private endpoint subnet
  virtual_network_subnet_ids = [azurerm_subnet.private_endpoint.id]
  
  # Allow Azure services (required for private endpoints)
  bypass = ["AzureServices"]
}

# Wait for storage account and network rules to propagate
resource "null_resource" "wait_for_storage_setup" {
  depends_on = [
    azurerm_storage_account.private,
    azurerm_storage_account_network_rules.private,
  ]

  provisioner "local-exec" {
    command = "echo 'Waiting 30 seconds for storage account to fully provision...' && sleep 30"
  }
}

# Create blob container for Terraform state
resource "azurerm_storage_container" "tfstate" {
  name                  = local.tfstate_container_name
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"

  depends_on = [
    null_resource.wait_for_storage_setup,
    azurerm_private_endpoint.storage,
  ]
}