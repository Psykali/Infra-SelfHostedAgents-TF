# Data sources to reference existing networking resources
data "azurerm_virtual_network" "main" {
  name                = "client-devops-agent-vnet"  # Use actual VNet name from stage 1
  resource_group_name = "client-devops-agents-network-rg" 
}

data "azurerm_subnet" "main" {
  name                 = "client-devops-agent-subnet"  # Use actual subnet name from stage 1
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = "client-devops-agents-network-rg" 
}