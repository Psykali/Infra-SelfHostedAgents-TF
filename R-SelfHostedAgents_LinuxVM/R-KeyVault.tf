# =============================================
# KEY VAULT FOR SECRETS - DEVOPS AGENTS
# =============================================

resource "azurerm_key_vault" "main" {
  name                        = local.kv_name
  location                    = azurerm_resource_group.vm_rg.location
  resource_group_name         = azurerm_resource_group.vm_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = false
  
  # Current user access - defined inline (not separate resource)
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
  
  # VM identity access - defined inline
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
}