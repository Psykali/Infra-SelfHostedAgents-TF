# Resource Group
resource "azurerm_resource_group" "vm_rg" {
  name     = var.vm_rg_name
  location = var.location
}

resource "azurerm_resource_group" "network_rg" {
  name     = var.networking_rg_name
  location = var.location
}

# Network Security Group
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
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.main.name  
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = var.pip_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Dynamic"
}

# Network Interface
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
}

# Connect NSG to NIC
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id 
  network_security_group_id = azurerm_network_security_group.main.id  
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  size                = var.vm_size
  admin_username      = "devopsadmin"
  admin_password      = "FGHJfghj1234"
  disable_password_authentication = false  
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Custom script to install and configure DevOps agents
  custom_data = base64encode(templatefile("${path.module}/agent-setup.sh", {
    devops_org    = var.devops_org
    devops_project = var.devops_project  
    devops_pool   = var.devops_pool
    devops_pat    = var.devops_pat
    agent_count   = var.agent_count
  }))

  identity {
    type = "SystemAssigned"
  }
}

output "vm_public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "vm_resource_group_name" {
  value = azurerm_resource_group.vm_rg.name
}

output "networking_resource_group_name" {  
  value = azurerm_resource_group.network_rg.name
}