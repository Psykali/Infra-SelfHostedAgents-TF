# =============================================
# KEY VAULT FOR SECRETS MANAGEMENT
# =============================================
# Purpose: Creates a Key Vault to securely store VM credentials and secrets

# Generate random password for VM
resource "random_password" "vm_password" {
  length           = 21
  special          = true
  override_special = "!@#%^&*()-_=+[]{}<>:?"
}

# Key Vault for storing secrets
resource "azurerm_key_vault" "main" {
  name                        = local.kv_name
  location                    = azurerm_resource_group.agent_rg.location
  resource_group_name         = azurerm_resource_group.agent_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.key_vault_sku
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  # Access policies
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update"
    ]
  }

  # Allow VM's system-assigned identity to read secrets
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
  name         = "agents-vm-admin-password"
  value        = random_password.vm_password.result
  key_vault_id = azurerm_key_vault.main.id
  content_type = "text/plain"

  tags = merge(local.common_tags, {
    Component = "credentials"
    Resource  = local.vm_name
  })
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}