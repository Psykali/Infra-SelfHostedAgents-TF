# =============================================
# KEY VAULT FOR SECRETS - DEVOPS AGENTS
# =============================================

resource "azurerm_key_vault" "main" {
  name                        = local.kv_name
  location                    = azurerm_resource_group.agent.location
  resource_group_name         = azurerm_resource_group.agent.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = false
  
  # Current user (Terraform executor) access ONLY
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    key_permissions = [
      "Get", "List", "Create", "Delete", "Purge"
    ]
    
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"
    ]
    
    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Purge"
    ]
  }
    
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
  
  tags = merge(local.common_tags, {
    Description = "Key Vault for storing DevOps secrets and PAT tokens"
    Component   = "security"
    Sensitive   = "true"
  })
}

# =============================================
# KEY VAULT ACCESS POLICIES - DEVOPS AGENTS
# =============================================
# Purpose: Separate Key Vault access policies to avoid circular dependencies
# Usage: Creates access policies after VM and Key Vault are both created

# Add access policy for VM's managed identity AFTER VM is created
resource "azurerm_key_vault_access_policy" "vm_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine.main.identity[0].principal_id
  
  secret_permissions = [
    "Get", "List"
  ]
  
  key_permissions = [
    "Get", "List", "UnwrapKey", "WrapKey"
  ]
  
  depends_on = [
    azurerm_key_vault.main,
    azurerm_linux_virtual_machine.main
  ]
}

# Optional: Add access policy for current user if not already in main Key Vault
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"
  ]
  
  key_permissions = [
    "Get", "List", "Create", "Delete", "Purge"
  ]
  
  depends_on = [azurerm_key_vault.main]
}