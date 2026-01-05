# =============================================
# DATA SOURCES - STORAGE ACCOUNT
# =============================================
# Purpose: Reference existing network resources from agents deployment
# Usage: Gets VNET and subnet info for private endpoint connection
# Important: DevOps agents must be deployed first

# Data source for existing network resource group
data "azurerm_resource_group" "network" {
  name = local.network_rg_name
}

# Data source for existing virtual network
data "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  resource_group_name = data.azurerm_resource_group.network.name
}

# Data source for existing subnet
data "azurerm_subnet" "agents" {
  name                 = local.subnet_name
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.network.name
}

# =============================================
# OUTPUTS - STORAGE ACCOUNT
# =============================================
# Purpose: Output deployment information for integration
# Usage: Provides values needed for agents backend configuration

output "storage_account_name" {
  value       = azurerm_storage_account.private.name
  description = "Name of the private storage account"
}

output "storage_container_name" {
  value       = azurerm_storage_container.tfstate.name
  description = "Name of the Terraform state container"
}

output "storage_resource_group" {
  value       = azurerm_resource_group.storage.name
  description = "Resource group containing the storage account"
}

output "storage_account_key" {
  value       = azurerm_storage_account.private.primary_access_key
  description = "Primary access key for the storage account"
  sensitive   = true
}

output "private_endpoint_ip" {
  value       = azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address
  description = "Private IP address for storage endpoint"
}

output "backend_configuration" {
  value = {
    resource_group_name  = azurerm_resource_group.storage.name
    storage_account_name = azurerm_storage_account.private.name
    container_name       = azurerm_storage_container.tfstate.name
    key                  = "terraform.tfstate"
  }
  description = "Terraform backend configuration values"
}

output "hosts_file_entry" {
  value = "${azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address} ${azurerm_storage_account.private.name}.blob.core.windows.net"
  description = "Entry to add to /etc/hosts on agents VM"
}

output "deployment_instructions" {
  value = <<EOT
✅ Storage Account Deployment Complete!

IMPORTANT NEXT STEPS:

1. Update DevOps Agents Terraform backend:
   - Edit providers.tf in devops-agents folder
   - Add backend configuration:
   
   backend "azurerm" {
     resource_group_name  = "${azurerm_resource_group.storage.name}"
     storage_account_name = "${azurerm_storage_account.private.name}"
     container_name       = "${azurerm_storage_container.tfstate.name}"
     key                  = "devops-agents.tfstate"
   }

2. Migrate DevOps Agents state:
   cd ../devops-agents/
   terraform init -migrate-state
   terraform apply

3. Configure agents VM hosts file:
   SSH to VM: ssh devopsadmin@<vm-public-ip>
   Run: sudo echo "${azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address} ${azurerm_storage_account.private.name}.blob.core.windows.net" >> /etc/hosts

4. Test connectivity from VM:
   nslookup ${azurerm_storage_account.private.name}.blob.core.windows.net
   # Should resolve to private IP
EOT
  description = "Post-deployment instructions"
}