# =============================================
# DATA SOURCES AND OUTPUTS - DEVOPS AGENTS
# =============================================
# Purpose: Reference data and output deployment information
# Usage: Gets VM public IP and outputs key information

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

output "network_resource_group" {
  value       = azurerm_resource_group.network.name
  description = "Name of the network resource group"
}

output "agent_resource_group" {
  value       = azurerm_resource_group.agent.name
  description = "Name of the agent resource group"
}

output "vnet_name" {
  value       = azurerm_virtual_network.main.name
  description = "Name of the virtual network"
}

output "subnet_name" {
  value       = azurerm_subnet.main.name
  description = "Name of the subnet"
}

# FIXED: Added sensitive = true flag
output "deployment_instructions" {
  value = <<EOT
✅ DevOps Agents Infrastructure Deployed!

Next Steps:
1. Retrieve VM password from Key Vault:
   az keyvault secret show --vault-name ${azurerm_key_vault.main.name} --name vm-admin-password

2. SSH to VM for verification:
   ssh ${var.admin_username}@${data.azurerm_public_ip.vm_ip.ip_address}

3. After storage deployment, update cloud-init.yaml with:
   - Storage account private endpoint IP
   - Storage account access key

4. Run agent setup script on VM
EOT
  description = "Post-deployment instructions"
  sensitive   = true  # ADDED THIS LINE
}