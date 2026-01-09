# =============================================
# DATA SOURCES AND OUTPUTS - STORAGE ACCOUNT
# =============================================

data "azurerm_client_config" "current" {}

# Get existing network from agents deployment
data "azurerm_virtual_network" "main" {
  name                = local.vnet_name 
  resource_group_name = local.networking_rg_name 
}


# Get the existing subnet where VM is located
data "azurerm_subnet" "agents" {
  name                 = local.subnet_name
  resource_group_name  = local.networking_rg_name
  virtual_network_name = local.vnet_name
}

# Get the existing NSG
data "azurerm_network_security_group" "agents_nsg" {
  name                = "nsg-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  resource_group_name = local.networking_rg_name
}

/*
data "azurerm_subnet" "private_endpoint" {
  name                 = local.private_endpoint_subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = local.networking_rg_name
}
*/
# =============================================
# OUTPUTS
# =============================================

output "storage_account_name" {
  value = azurerm_storage_account.private.name
}

output "storage_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "storage_resource_group" {
  value = azurerm_resource_group.storage.name
}

output "vm_subnet_id" {
  value = data.azurerm_subnet.agents.id
}

output "private_endpoint_status" {
  value = <<EOT

  ==============================================
  ✅ PRIVATE STORAGE ACCOUNT DEPLOYED
  ==============================================
  Storage Account: ${azurerm_storage_account.private.name}
  Container: ${azurerm_storage_container.tfstate.name}
  Resource Group: ${azurerm_resource_group.storage.name}
  Private Endpoint: ${local.private_endpoint_name}
  VM Subnet: ${data.azurerm_subnet.agents.name}
  
  🔧 Terraform Backend Configuration:
  
  Add this to AgentVM/providers.tf:
  
  terraform {
    backend "azurerm" {
      resource_group_name  = "${azurerm_resource_group.storage.name}"
      storage_account_name = "${azurerm_storage_account.private.name}"
      container_name       = "tfstate"
      key                  = "agents.terraform.tfstate"
    }
  }
  
  💡 Next Steps:
  1. Update AgentVM/providers.tf with above config
  2. Run: terraform init -migrate-state
  3. SSH to VM and test: nslookup ${azurerm_storage_account.private.name}.blob.core.windows.net
  ==============================================
  EOT
}