# =============================================
# DATA SOURCES AND OUTPUTS - DEVOPS AGENTS
# =============================================
# Purpose: Reference data and output deployment information

# Get VM public IP
data "azurerm_public_ip" "vm_ip" {
  name                = azurerm_public_ip.main.name
  resource_group_name = azurerm_resource_group.network.name
  
  depends_on = [azurerm_linux_virtual_machine.main]
}

# ============= OUTPUTS =============
output "vm_public_ip" {
  value       = data.azurerm_public_ip.vm_ip.ip_address
  description = "Public IP address of the DevOps agent VM"
}

output "vm_name" {
  value       = azurerm_linux_virtual_machine.main.name
  description = "Name of the DevOps agent VM"
}

output "key_vault_name" {
  value       = azurerm_key_vault.main.name
  description = "Name of the Key Vault storing VM credentials"
}

output "key_vault_secret_name" {
  value       = azurerm_key_vault_secret.vm_admin_password.name
  description = "Name of the secret storing VM password"
}

# FIXED: Mark as sensitive since it contains username
output "ssh_connection_command" {
  value       = "ssh ${var.admin_username}@${data.azurerm_public_ip.vm_ip.ip_address}"
  description = "SSH command to connect to VM"
  sensitive   = true  
}

# FIXED: Already marked sensitive
output "key_vault_password_retrieval" {
  value       = "az keyvault secret show --vault-name ${azurerm_key_vault.main.name} --name vm-admin-password --query value -o tsv"
  description = "Command to retrieve VM password from Key Vault"
  sensitive   = true
}

# Add non-sensitive useful outputs
output "deployment_summary" {
  value = <<EOT
✅ DevOps Agents Infrastructure Deployed Successfully!

Resources Created:
- VM: ${azurerm_linux_virtual_machine.main.name}
- Key Vault: ${azurerm_key_vault.main.name}
- Network: ${azurerm_virtual_network.main.name}

Next Steps:
1. Retrieve VM password from Key Vault
2. Connect to VM using SSH
3. Monitor agent setup in setup.log on VM
EOT
  description = "Deployment summary and next steps"
}