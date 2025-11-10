# Network Security Group "NSG"
resource "azurerm_network_security_group" "main" {
  name                = var.nsg_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

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

  tags = merge(local.common_tags, {
    Description = "NSG for DevOps agent VM"
    Component   = "security"
  })
}

# Virtual Network "VNET"
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  tags = merge(local.common_tags, {
    Description = "Virtual network for DevOps infrastructure"
    Component   = "networking"
  })
}

# Subnet 
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP "PIP"
resource "azurerm_public_ip" "main" {
  name                = var.pip_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Dynamic"

  tags = merge(local.common_tags, {
    Description = "Public IP for DevOps agent VM"
    Component   = "networking"
    Ephemeral   = "true"  # Dynamic IPs can change
  })
}

# Network Interface "NIC"
resource "azurerm_network_interface" "main" {
  name                = var.nic_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = merge(local.common_tags, {
    Description = "Network interface for DevOps agent VM"
    Component   = "networking"
  })
}