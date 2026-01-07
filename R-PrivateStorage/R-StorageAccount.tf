# =============================================
# PRIVATE STORAGE ACCOUNT (MVP)
# =============================================
# Purpose: Create private storage for Terraform state
# Usage: VM will connect via private endpoint

# Private Storage Account
resource "azurerm_storage_account" "private" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  # 🔒 Critical: Disable public access
  public_network_access_enabled = false
  
  tags = merge(local.common_tags, {
    Purpose = "terraform-state"
  })
}

# Container for Terraform state - MUST be created BEFORE network rules
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"
  
  depends_on = [
    azurerm_storage_account.private
  ]
}

# Network Rules - Allow only private endpoint
# IMPORTANT: Must be created AFTER container to avoid 403 errors
resource "azurerm_storage_account_network_rules" "private" {
  storage_account_id = azurerm_storage_account.private.id
  
  default_action = "Deny"  # Block all public access
  
  # Allow traffic from VM subnet (via private endpoint)
  # Will be updated after private endpoint is created
  virtual_network_subnet_ids = []
  
  # Required for private endpoint to work
  bypass = ["AzureServices"]
  
  depends_on = [
    azurerm_storage_container.tfstate
  ]
}