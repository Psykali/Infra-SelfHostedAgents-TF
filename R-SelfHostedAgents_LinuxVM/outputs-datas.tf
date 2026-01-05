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
  sensitive = true‌
  value       = azurerm_key_vault_secret.vm_admin_password.name
  description = "Name of the secret storing VM password"
}

output "ssh_connection_command" {
  sensitive = true‌
  value       = "ssh ${var.admin_username}@${data.azurerm_public_ip.vm_ip.ip_address}"
  description = "SSH command to connect to VM"
}

output "key_vault_password_retrieval" {
  sensitive = true‌
  value       = "az keyvault secret show --vault-name ${azurerm_key_vault.main.name} --name vm-admin-password --query value -o tsv"
  description = "Command to retrieve VM password from Key Vault"
  sensitive   = true
}