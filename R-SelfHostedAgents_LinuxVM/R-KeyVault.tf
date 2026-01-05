# =============================================
# KEY VAULT FOR SECRETS - DEVOPS AGENTS
# =============================================
# Purpose: Create Key Vault to securely store VM credentials
# Usage: Stores the VM password for secure retrieval

# Key Vault for storing secrets
resource "azurerm_key_vault" "main" {
  name                       = local.kv_name
  location                   = azurerm_resource_group.agent.location
  resource_group_name        = azurerm_resource_group.agent.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  
  # Access policy for current user (Terraform)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
  }
  
  tags = merge(local.common_tags, {
    Component = "security"
    Usage     = "vm-credentials-storage"
  })
}

# Store VM password in Key Vault
resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  value        = random_password.local_vm_password.result
  key_vault_id = azurerm_key_vault.main.id
  
  tags = merge(local.common_tags, {
    Component = "credentials"
    Resource  = local.vm_name
  })
  
  depends_on = [azurerm_key_vault.main]
}

# Add VM identity to Key Vault access policy (optional, for future use)
resource "azurerm_key_vault_access_policy" "vm_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine.main.identity[0].principal_id
  
  secret_permissions = [
    "Get", "List"
  ]
  
  depends_on = [
    azurerm_linux_virtual_machine.main,
    azurerm_key_vault.main
  ]
}

# Data source for current Azure client
data "azurerm_client_config" "current" {}