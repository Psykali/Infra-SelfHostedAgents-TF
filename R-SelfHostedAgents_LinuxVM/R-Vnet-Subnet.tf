### ----------------------
### Virtual Network "VNET"
### ----------------------
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  tags = merge(local.common_tags, {
    Description = "Virtual network for DevOps infrastructure"
    Component   = "networking"
  })
}

# Subnet 
resource "azurerm_subnet" "main" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.2/27"]
}