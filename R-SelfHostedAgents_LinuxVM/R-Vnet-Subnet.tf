# =============================================
# VIRTUAL NETWORK AND SUBNET - DEVOPS AGENTS
# =============================================
# Purpose: Create virtual network and subnet for agents infrastructure
# Usage: Provides network isolation and connectivity for agents

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  
  tags = merge(local.common_tags, {
    Component   = "networking"
    Description = "Virtual network for DevOps infrastructure"
  })
}

# Subnet for DevOps Agents
resource "azurerm_subnet" "main" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/27"]
  
  # Enable private endpoints for future storage connectivity
  # Updated to use new property name (non-deprecated)
  private_endpoint_network_policies = "Enabled"
  
  # Service endpoints for Azure services
  service_endpoints = ["Microsoft.Storage"]
}