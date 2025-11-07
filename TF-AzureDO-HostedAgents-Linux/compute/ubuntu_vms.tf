resource "azurerm_public_ip" "ubuntu_vms" {
  count               = 2
  name                = "pip-ubuntu-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "Production"
    OS          = "Ubuntu"
  }
}

# Network Interfaces for Ubuntu VMs
resource "azurerm_network_interface" "ubuntu_vms" {
  count               = 2
  name                = "nic-ubuntu-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu_vms[count.index].id
  }

  tags = {
    Environment = "Production"
    OS          = "Ubuntu"
  }
}

# Ubuntu Virtual Machines
resource "azurerm_linux_virtual_machine" "devops_agents" {
  count               = 2
  name                = "vm-ubuntu-agent-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  size                = var.ubuntu_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.ubuntu_vms[count.index].id,
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
    AgentName   = var.ubuntu_agent_names[count.index]
  }
}