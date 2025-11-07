resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-${var.location}"
  resource_group_name = azurerm_resource_group.spoke_networking.name
  location            = azurerm_resource_group.spoke_networking.location
  address_space       = [var.spoke_vnet_cidr]
  tags = {
    Environment = "Production"
    Type        = "Spoke"
  }
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.spoke_networking.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.vm_subnet_cidr]
}