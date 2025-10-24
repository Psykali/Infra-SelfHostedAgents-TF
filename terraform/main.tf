# Resource Group
resource "azurerm_resource_group" "agent_rg" {
  name     = "rg-${var.project_name}-${var.environment}-agents"
  location = var.location
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    CreatedBy   = "terraform"
  }
}

# Network Security Group
resource "azurerm_network_security_group" "agent_nsg" {
  name                = "nsg-${var.project_name}-${var.environment}-agents"
  location            = azurerm_resource_group.agent_rg.location
  resource_group_name = azurerm_resource_group.agent_rg.name

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
    Environment = var.environment
  }
}

# Virtual Network
resource "azurerm_virtual_network" "agent_vnet" {
  name                = "vnet-${var.project_name}-${var.environment}-agents"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.agent_rg.location
  resource_group_name = azurerm_resource_group.agent_rg.name
}

# Subnet
resource "azurerm_subnet" "agent_subnet" {
  name                 = "snet-${var.project_name}-${var.environment}-agents"
  resource_group_name  = azurerm_resource_group.agent_rg.location
  virtual_network_name = azurerm_virtual_network.agent_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "agent_pip" {
  name                = "pip-${var.vm_name}"
  location            = azurerm_resource_group.agent_rg.location
  resource_group_name = azurerm_resource_group.agent_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = {
    Environment = var.environment
  }
}

# Network Interface
resource "azurerm_network_interface" "agent_nic" {
  name                = "nic-${var.vm_name}"
  location            = azurerm_resource_group.agent_rg.location
  resource_group_name = azurerm_resource_group.agent_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.agent_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.agent_pip.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "agent_vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.agent_rg.name
  location            = azurerm_resource_group.agent_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  
  network_interface_ids = [
    azurerm_network_interface.agent_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/../scripts/cloud-init.yaml", {
    project_name    = var.project_name
    agent_count     = var.agent_count
    azure_devops_url = var.azure_devops_url
    pat_token       = var.pat_token
    pool_name       = var.pool_name
  }))

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Role        = "devops-agent"
  }
}

# Outputs
output "vm_public_ip" {
  value = azurerm_public_ip.agent_pip.ip_address
}

output "vm_ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.agent_pip.ip_address}"
}

output "resource_group_name" {
  value = azurerm_resource_group.agent_rg.name
}