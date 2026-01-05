# =============================================
# KEY VAULT FOR SECRETS - DEVOPS AGENTS
# =============================================
# Purpose: Create Key Vault to securely store VM credentials
# Usage: Generates random password and stores it in Key Vault
# Note: Uses separate user-assigned identity to break circular dependency

# Generate secure random password for VM
resource "random_password" "vm_password" {
  length           = 21
  special          = true
  override_special = "!@#%^&*()-_=+[]{}<>:?"
}

# Create a user-assigned identity for VM (breaks the cycle)
resource "azurerm_user_assigned_identity" "vm_identity" {
  name                = "id-${local.vm_name}"
  resource_group_name = azurerm_resource_group.agent.name
  location            = azurerm_resource_group.agent.location
  
  tags = merge(local.common_tags, {
    Component = "identity"
    Usage     = "vm-keyvault-access"
  })
}

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
  
  # Access policy for user-assigned identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.vm_identity.principal_id
    
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

# Output the secret ID for VM reference
output "key_vault_secret_id" {
  value       = azurerm_key_vault_secret.vm_admin_password.id
  description = "Key Vault secret ID for VM password"
  sensitive   = true
}