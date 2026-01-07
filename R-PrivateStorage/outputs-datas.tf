# =============================================
# OUTPUTS 
# =============================================
# Purpose: Show deployment results
# Usage: Copy values for Agents Terraform backend config

output "storage_account_name" {
  value       = azurerm_storage_account.private.name
  description = "Name of the private storage account"
}

output "storage_resource_group" {
  value       = azurerm_resource_group.storage.name
  description = "Resource group containing the storage"
}

output "private_endpoint_ip" {
  value       = azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address
  description = "Private IP address assigned to the endpoint"
}

output "backend_configuration" {
  value = <<EOT
==============================================
🔧 BACKEND CONFIGURATION FOR AGENTS
==============================================

Add this to AgentVM/providers.tf:

terraform {
  backend "azurerm" {
    resource_group_name  = "${azurerm_resource_group.storage.name}"
    storage_account_name = "${azurerm_storage_account.private.name}"
    container_name       = "tfstate"
    key                  = "agents.terraform.tfstate"
  }
}

==============================================
✅ DEPLOYMENT SUCCESSFUL
==============================================
Storage: ${azurerm_storage_account.private.name}
Private Endpoint: pep-${azurerm_storage_account.private.name}
Private IP: ${azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address}

💡 Next Steps:
1. Update AgentVM/providers.tf with above config
2. Run in AgentVM/: terraform init -migrate-state
3. Verify: terraform state list
==============================================
EOT
  
  description = "Instructions for configuring Terraform backend"
}