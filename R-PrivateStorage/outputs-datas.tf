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