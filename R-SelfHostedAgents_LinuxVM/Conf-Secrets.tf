# =============================================
# SECRETS MANAGEMENT - DEVOPS AGENTS
# =============================================

# Generate random password for VM
resource "random_password" "vm_password" {
  length           = 21
  special          = true
  override_special = "!@#$%^&*()_+-="
  min_special      = 2
  min_numeric      = 2
  min_upper        = 2
  min_lower        = 2
}

# Store VM password in Key Vault
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  value        = random_password.vm_password.result
  key_vault_id = azurerm_key_vault.main.id
  
  tags = merge(local.common_tags, {
    SecretType   = "VM Credentials"
    RotationDate = formatdate("YYYY-MM-DD", timeadd(timestamp(), "8760h"))
  })
}

# Store DevOps PAT in Key Vault (from variable)
resource "azurerm_key_vault_secret" "devops_pat" {
  name         = "azure-devops-pat"
  value        = var.azure_devops_pat  # Get from variable
  key_vault_id = azurerm_key_vault.main.id
  
  tags = merge(local.common_tags, {
    SecretType     = "Azure DevOps PAT"
    ExpirationDate = formatdate("YYYY-MM-DD", timeadd(timestamp(), "8760h"))
  })
}

# Store Agent Pool configuration
resource "azurerm_key_vault_secret" "agent_config" {
  name = "agent-configuration"
  value = jsonencode({
    agent_pool_name  = local.agent_pool_name
    agent_count      = var.agent_count
    agent_version    = var.agent_version
    organization_url = var.azure_devops_org_url
    client_name      = var.client_name
  })
  key_vault_id = azurerm_key_vault.main.id
  
  tags = merge(local.common_tags, {
    SecretType = "Configuration"
  })
}