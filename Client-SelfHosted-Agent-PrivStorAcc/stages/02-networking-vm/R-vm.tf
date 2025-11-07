resource "azurerm_public_ip" "vm" {
  name                = "BSE-${var.client_name}-PIP-${var.location}-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = {
    Environment = "prod"
    Client      = var.client_name
  }
}

resource "azurerm_network_interface" "vm" {
  name                = "BSE-${var.client_name}-NIC-${var.location}-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
  
  tags = {
    Environment = "prod"
    Client      = var.client_name
  }
}

resource "azurerm_linux_virtual_machine" "agent" {
  name                = "BSE-${var.client_name}-VM-${var.location}-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vm.id,
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
    Environment = "prod"
    Client      = var.client_name
    Role        = "selfhosted-agent"
  }
}

resource "azurerm_virtual_machine_extension" "agent_setup" {
  name                 = "BSE-${var.client_name}-EXT-${var.location}-001"
  virtual_machine_id   = azurerm_linux_virtual_machine.agent.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    "script": "${base64encode(file("${path.module}/../../scripts/setup_agent.sh"))}"
  })

  tags = {
    Environment = "prod"
    Client      = var.client_name
  }
}