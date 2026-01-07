# =============================================
# PRIVATE STORAGE ACCOUNT (MVP)
# =============================================
# Purpose: Create private storage for Terraform state
# Usage: VM will connect via private endpoint

resource "azurerm_storage_account" "private" {
  name                     = local.private_storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  # TEMPORARY: Enable public access for container creation
  public_network_access_enabled = true
  
  tags = local.common_tags
  
  # Required for blob storage
  account_kind = "StorageV2"
  
  # Enable blob properties
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

# Create container FIRST (while public access is enabled)
resource "azurerm_storage_container" "tfstate" {
  name                  = local.tfstate_container_name
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"
  
  depends_on = [azurerm_storage_account.private]
}

# Get the existing subnet where VM is located
data "azurerm_subnet" "agents" {
  name                 = local.subnet_name
  resource_group_name  = local.networking_rg_name
  virtual_network_name = local.vnet_name
}

# Network Rules - allow VM subnet via service endpoint
resource "azurerm_storage_account_network_rules" "private" {
  storage_account_id = azurerm_storage_account.private.id
  
  default_action = "Deny"  # Block all by default
  
  # Allow VM subnet (where agents are running)
  virtual_network_subnet_ids = [data.azurerm_subnet.agents.id]
  
  # Required for managed identity to work
  bypass = ["AzureServices"]
  
  depends_on = [
    azurerm_storage_container.tfstate
  ]
}

# After network rules are set, disable public access
resource "null_resource" "disable_public_access" {
  depends_on = [azurerm_storage_account_network_rules.private]
  
  triggers = {
    storage_name = azurerm_storage_account.private.name
  }
  
  provisioner "local-exec" {
    command = <<EOT
      echo "Disabling public access for storage: ${azurerm_storage_account.private.name}"
      az storage account update \
        --name ${azurerm_storage_account.private.name} \
        --resource-group ${azurerm_resource_group.storage.name} \
        --public-network-access Disabled \
        --query 'publicNetworkAccess'
    EOT
  }
}