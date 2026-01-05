# =============================================
# VIRTUAL NETWORK AND SUBNET CONFIGURATION
# =============================================
# Purpose: Creates virtual network and subnet for the DevOps infrastructure
# Includes subnet NSG assignment as per recommendations

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/24"]  # Larger address space for flexibility
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  tags = merge(local.common_tags, {
    Component   = "networking"
    Description = "Virtual network for DevOps infrastructure"
  })
}

# Subnet for DevOps Agents (with NSG assignment)
resource "azurerm_subnet" "main" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/27"]
  
  # Assign NSG to subnet (as per recommendation #5)
  network_security_group_id = azurerm_network_security_group.main.id

  # Enable private endpoints
  private_endpoint_network_policies_enabled = true
}