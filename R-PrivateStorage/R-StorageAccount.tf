# =============================================
# PRIVATE STORAGE ACCOUNT
# =============================================
# Purpose: Create private storage for Terraform state
# Usage: VM will connect via private endpoint
# Features: No public access, private endpoint only

# Resource Group for storage
resource "azurerm_resource_group" "storage" {
  name     = local.storage_rg
  location = var.location
  tags     = local.tags
}

# Private Storage Account
resource "azurerm_storage_account" "private" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "ZRS" # for minimum cost unless other demande of the client
  min_tls_version          = "TLS1_2"
  
  # 🔒 Critical: Disable public access
  public_network_access_enabled = false
  
  tags = merge(local.tags, {
    Component = "storage"
    Purpose   = "terraform-state"
  })
}

# Container for Terraform state
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"
}