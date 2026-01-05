# =============================================
# PRIVATE STORAGE ACCOUNT FOR TERRAFORM STATE
# =============================================
# Purpose: Create private storage account for Terraform state
# Usage: Backend storage with private endpoint connectivity
# =============================================

resource "azurerm_storage_account" "private" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  # Security: Disable public access
  public_network_access_enabled = false
  
  # Enable blob soft delete for recovery
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  
  tags = merge(local.common_tags, {
    Description = "Private storage account for Terraform state files"
    Usage       = "terraform-backend"
  })
  
  lifecycle {
    prevent_destroy = true
  }
}

# Network rules for storage account
resource "azurerm_storage_account_network_rules" "private" {
  storage_account_id = azurerm_storage_account.private.id
  
  # Deny all by default
  default_action = "Deny"
  
  # Allow from agents subnet
  virtual_network_subnet_ids = [data.azurerm_subnet.agents.id]
  
  # Allow Azure services (required for private endpoints)
  bypass = ["AzureServices"]
  
  depends_on = [azurerm_storage_account.private]
}

# Storage container for Terraform State
# FIXED: azurerm_storage_container doesn't support tags
resource "azurerm_storage_container" "tfstate" {
  name                  = local.container_name
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"
  
  # NO TAGS HERE - azurerm_storage_container doesn't support tags
  
  depends_on = [
    azurerm_storage_account.private,
    azurerm_storage_account_network_rules.private
  ]
}