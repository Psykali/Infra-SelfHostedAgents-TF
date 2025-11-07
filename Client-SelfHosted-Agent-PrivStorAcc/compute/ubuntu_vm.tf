# Public IP for Ubuntu VM
resource "azurerm_public_ip" "ubuntu_vm" {
  name                = "pip-ubuntu-vm-01"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "Production"
    OS          = "Ubuntu"
  }
}

# Network Interface for Ubuntu VM
resource "azurerm_network_interface" "ubuntu_vm" {
  name                = "nic-ubuntu-vm-01"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu_vm.id
  }

  tags = {
    Environment = "Production"
    OS          = "Ubuntu"
  }
}

# Ubuntu Virtual Machine
resource "azurerm_linux_virtual_machine" "devops_agent" {
  name                = "vm-ubuntu-agent-01"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  size                = var.ubuntu_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.ubuntu_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = "Production"
    Role        = "DevOps-Agent"
    OS          = "Ubuntu"
    AgentName   = var.devops_agent_name
  }
}

# Data sources for private endpoint
data "azurerm_virtual_network" "spoke" {
  name                = azurerm_virtual_network.spoke.name
  resource_group_name = azurerm_resource_group.spoke_networking.name
}

data "azurerm_subnet" "vm" {
  name                 = azurerm_subnet.vm.name
  virtual_network_name = data.azurerm_virtual_network.spoke.name
  resource_group_name  = azurerm_resource_group.spoke_networking.name
}