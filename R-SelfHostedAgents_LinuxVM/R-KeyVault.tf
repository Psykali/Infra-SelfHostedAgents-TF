# =============================================
# KEY VAULT FOR SECRETS - DEVOPS AGENTS
# =============================================
# Purpose: Create Key Vault to securely store VM credentials and DevOps PAT
# Usage: Central secrets management with managed identity access

resource "azurerm_key_vault" "main" {
  name                        = local.kv_name
  location                    = azurerm_resource_group.agent.location
  resource_group_name         = azurerm_resource_group.agent.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = false
  
  # Current user (Terraform executor) access
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
  
  # VM's system-assigned identity access for runtime secrets retrieval
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_linux_virtual_machine.main.identity[0].principal_id
    
    secret_permissions = [
      "Get", "List"
    ]
    
    key_permissions = [
      "Get", "List", "UnwrapKey", "WrapKey"
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
  
  lifecycle {
    ignore_changes = [
      access_policy
    ]
  }
}

data "azurerm_client_config" "current" {}

# Output Key Vault information for reference
output "key_vault_name" {
  value       = azurerm_key_vault.main.name
  description = "Name of the Key Vault storing secrets"
  sensitive   = false
}

output "key_vault_id" {
  value       = azurerm_key_vault.main.id
  description = "Resource ID of the Key Vault"
  sensitive   = false
}