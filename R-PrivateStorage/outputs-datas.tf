# =============================================
# DATA SOURCES - STORAGE ACCOUNT
# =============================================
# Purpose: Reference existing network resources from agents deployment
# Usage: Gets VNET and subnet info for private endpoint connection
# Important: DevOps agents must be deployed first

# Data source for existing VNet & Subnet from agents deployment
data "azurerm_virtual_network" "main" {
  name                = local.vnet_name 
  resource_group_name = local.networking_rg_name 
}

data "azurerm_subnet" "agents" {
  name                 = local.subnet_name  
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_virtual_network.main.resource_group_name
}

# =============================================
# OUTPUTS - STORAGE ACCOUNT
# =============================================
# Purpose: Output deployment information for integration
# Usage: Provides values needed for agents backend configuration

output "storage_account_name" {
  value = azurerm_storage_account.private.name
}

output "storage_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "storage_resource_group_name" {
  value = azurerm_resource_group.storage.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.storage.id
}

output "private_endpoint_private_ip" {
  value = azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address
}

output "connection_instructions" {
  value = <<EOF

  ==============================================
  🔒 PRIVATE STORAGE ACCOUNT DEPLOYED
  ==============================================
  Storage Account: ${azurerm_storage_account.private.name}
  Container: ${azurerm_storage_container.tfstate.name}
  Resource Group: ${azurerm_resource_group.storage.name}
  Private Endpoint: ${azurerm_private_endpoint.storage.name}
  
  📋 NEXT STEPS:
  1. SSH into VM: ssh ${var.admin_username}@${VM_PUBLIC_IP_FROM_AGENTS_OUTPUT}
  2. Test connection: nslookup ${azurerm_storage_account.private.name}.blob.core.windows.net
  3. Should resolve to private IP via Azure-provided DNS
  
  📝 Terraform Backend Configuration:
  Add to your agents/terraform/providers.tf:
  
  terraform {
    backend "azurerm" {
      resource_group_name  = "${azurerm_resource_group.storage.name}"
      storage_account_name = "${azurerm_storage_account.private.name}"
      container_name       = "${azurerm_storage_container.tfstate.name}"
      key                  = "agents.terraform.tfstate"
    }
  }
  ==============================================
  EOF
}