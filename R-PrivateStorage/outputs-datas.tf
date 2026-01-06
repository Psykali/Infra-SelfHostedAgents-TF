# =============================================
# DATA SOURCES - STORAGE ACCOUNT
# =============================================
# Purpose: Reference existing network resources from agents deployment
# Usage: Gets VNET and subnet info for private endpoint connection
# Important: DevOps agents must be deployed first

# Data source for existing VNet & Subnet
data "azurerm_virtual_network" "main" {
  name                = local.vnet_name 
  resource_group_name = local.networking_rg_name 
}

data "azurerm_subnet" "main" {
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

output "storage_account_id" {
  value = azurerm_storage_account.private.id
}