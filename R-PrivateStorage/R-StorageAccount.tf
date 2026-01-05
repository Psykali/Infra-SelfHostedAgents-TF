# =============================================
# STORAGE ACCOUNT - TERRAFORM STATE
# =============================================
# Purpose: Create private storage account for Terraform state
# Usage: Backend storage with private endpoint connectivity

# Storage Account
resource "azurerm_storage_account" "private" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
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
    prevent_destroy = true  # Critical: Contains Terraform state!
  }
}

# Network Rules - Deny all, allow only from agents subnet
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

# Storage Container for Terraform State
resource "azurerm_storage_container" "tfstate" {
  name                  = local.container_name
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"
  
  tags = merge(local.common_tags, {
    Description = "Container for Terraform state files"
  })
  
  depends_on = [
    azurerm_storage_account.private,
    azurerm_storage_account_network_rules.private
  ]
}