resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.location}"
  resource_group_name = azurerm_resource_group.hub_networking.name
  location            = azurerm_resource_group.hub_networking.location
  address_space       = [var.hub_vnet_cidr]
  tags = {
    Environment = "Production"
    Type        = "Hub"
  }
}

resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub_networking.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_cidr, 8, 0)]
}

resource "azurerm_subnet" "hub_azure_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub_networking.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_cidr, 8, 1)]
}