resource "azurerm_resource_group" "network" {
  name     = "BSE-${var.client_name}-RG-NET-${var.location}-001"
  location = var.location
  tags = {
    Environment = "prod"
    Client      = var.client_name
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "BSE-${var.client_name}-VNET-${var.location}-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  
  tags = {
    Environment = "prod"
    Client      = var.client_name
  }
}

resource "azurerm_subnet" "vm" {
  name                 = "BSE-${var.client_name}-SNET-VM-${var.location}-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "BSE-${var.client_name}-SNET-PE-${var.location}-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_network_security_group" "vm" {
  name                = "BSE-${var.client_name}-NSG-${var.location}-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = {
    Environment = "prod"
    Client      = var.client_name
  }
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}