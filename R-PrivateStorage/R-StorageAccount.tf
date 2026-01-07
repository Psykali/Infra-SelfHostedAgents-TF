# =============================================
# PRIVATE STORAGE ACCOUNT FOR TERRAFORM STATE
# =============================================
# Purpose: Create private storage account for Terraform state
# Approach: Use Azure CLI to create container after private endpoint is ready
# Security: NO PUBLIC ACCESS EVER - private endpoint only
# =============================================

resource "azurerm_storage_account" "private" {
  name                     = local.private_storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  # CRITICAL: NO PUBLIC ACCESS - PRIVATE ENDPOINT ONLY
  public_network_access_enabled = false
  
  # Enable blob storage
  account_kind = "StorageV2"
  
  tags = local.common_tags
}

# Create dedicated subnet for private endpoint (10.0.0.32/27)
resource "azurerm_subnet" "private_endpoint" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = local.networking_rg_name
  virtual_network_name = local.vnet_name
  address_prefixes     = ["10.0.0.32/27"]
  
  # Enable private endpoints
  private_endpoint_network_policies = "Enabled"
  
  # Service endpoint for storage
  service_endpoints = ["Microsoft.Storage"]
}


# =============================================
# CONTAINER FOR TERRAFORM STATE
# =============================================
# Purpose: Create container via Terraform (not CLI)
# Depends on private endpoint being ready

resource "azurerm_storage_container" "tfstate" {
  name                  = local.tfstate_container_name
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"

  depends_on = [
    null_resource.wait_for_private_endpoint
  ]
}
