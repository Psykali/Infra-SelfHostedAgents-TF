# Public IP for Windows VM
resource "azurerm_public_ip" "windows_vm" {
  name                = "pip-windows-vm"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "Production"
    OS          = "Windows"
  }
}

# Network Interface for Windows VM
resource "azurerm_network_interface" "windows_vm" {
  name                = "nic-windows-vm"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows_vm.id
  }

  tags = {
    Environment = "Production"
    OS          = "Windows"
  }
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "devops_agent" {
  name                = "vm-windows-agent-01"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  size                = var.windows_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.windows_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = {
    Environment = "Production"
    Role        = "DevOps-Agent"
    OS          = "Windows"
    AgentName   = var.windows_agent_name
  }
}