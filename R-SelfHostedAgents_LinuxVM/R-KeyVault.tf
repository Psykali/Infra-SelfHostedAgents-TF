# =============================================
# KEY VAULT FOR SECRETS - DEVOPS AGENTS
# =============================================
# Purpose: Create Key Vault to securely store VM credentials
# Usage: Generates random password and stores it in Key Vault

# Generate secure random password for VM
resource "random_password" "vm_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>:?"
}

# Key Vault for storing secrets
resource "azurerm_key_vault" "main" {
  name                       = local.kv_name
  location                   = azurerm_resource_group.agent.location
  resource_group_name        = azurerm_resource_group.agent.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  
  # Access policy for current user
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
  }
  
  # Access policy for VM system identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_linux_virtual_machine.main.identity[0].principal_id
    
    secret_permissions = [
      "Get", "List"
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
  value        = random_password.vm_password.result
  key_vault_id = azurerm_key_vault.main.id
  
  tags = merge(local.common_tags, {
    Component = "credentials"
    Resource  = local.vm_name
  })
}

# Data source for current Azure client
data "azurerm_client_config" "current" {}