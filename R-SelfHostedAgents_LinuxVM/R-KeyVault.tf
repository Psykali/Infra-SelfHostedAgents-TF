# =============================================
# KEY VAULT FOR SECRETS - DEVOPS AGENTS
# =============================================
# Purpose: Create Key Vault to securely store VM credentials
# Usage: Stores the VM password for secure retrieval

resource "azurerm_key_vault" "main" {
  name                        = "kv-${var.customer}-${local.base}-secrets"
  location                    = azurerm_resource_group.vm_rg.location
  resource_group_name         = azurerm_resource_group.vm_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = false
  
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    key_permissions = [
      "Get", "List"
    ]
    
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
    
    certificate_permissions = [
      "Get", "List"
    ]
  }
  
  # Allow VM's system-assigned identity to access secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_linux_virtual_machine.main.identity[0].principal_id
    
    secret_permissions = [
      "Get", "List"
    ]
  }
  
  tags = merge(local.common_tags, {
    Description = "Key Vault for storing DevOps secrets"
    Component   = "security"
  })
}

data "azurerm_client_config" "current" {}