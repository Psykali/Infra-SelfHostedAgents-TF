terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variables
variable "vm_rg_name" {
  description = "Name of the resource group"
  default     = "client-devops-agents-vm-rg"
}
variable "networking_rg_name" {
  description = "Name of the resource group"
  default     = "client-devops-agents-network-rg"
}

variable "location" {
  description = "Azure region"
  default     = "francecentral"
}

variable "vm_name" {
  description = "Name of the VM"
  default     = "client-devops-agent-vm"
}

variable "vm_size" {
  description = "VM size"
  default     = "Standard_B2als_v2"
}

variable "agent_count" {
  description = "Number of DevOps agents to install"
  default     = 5
}

variable "devops_org" {
  description = "Azure DevOps organization"
  default = "bseforgedevops"
}

variable "devops_project" {
  description = "Azure DevOps Project"
  default = "TestScripts-Forge"
}

variable "devops_pool" {
  description = "Azure DevOps agent pool name"
  default     = "client-hostedagents-ubuntu01"
}

variable "devops_pat" {
  description = "Azure DevOps Personal Access Token Named: client-devops-pat"
  sensitive   = true
  default     = "BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J"
}

variable "nsg_name" {
  description  = " NSG Name "
  default      = "client-devops-agent-nsg"
}

variable "vnet_name" {
  description = "Virtual Network Name"
  default     = "client-devops-agent-vnet"
}

variable "subnet_name" {
  description = "Subnet Name"
  default     = "client-devops-agent-subnet"
}

variable "pip_name" {
  description = "Public IP Name"
  default     = "client-devops-agent-pip"
}

variable "nic_name" {
  description = "Public IP Name"
  default     = "client-devops-agent-nic"
}

# Resource Group
resource "azurerm_resource_group" "vm_main" {
  name     = var.vm_rg_name
  location = var.location
}

resource "azurerm_resource_group" "networking_main" {
  name     = var.networking_rg_name
  location = var.location
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = var.nsg_name
  location            = azurerm_resource_group.networking_main.location
  resource_group_name = azurerm_resource_group.networking_main.name

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
  location            = azurerm_resource_group.networking_main.location
  resource_group_name = azurerm_resource_group.networking_main.name
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.networking_main.name
  virtual_network_name = azurerm_virtual_network.networking_main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = var.pip_name
  location            = azurerm_resource_group.networking_main.location
  resource_group_name = azurerm_resource_group.networking_main.name
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = var.nic_name
  location            = azurerm_resource_group.networking_main.location
  resource_group_name = azurerm_resource_group.networking_main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.networking_main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Connect NSG to NIC
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.networking_main.id
  network_security_group_id = azurerm_network_security_group.networking_main.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.vm_main.name
  location            = azurerm_resource_group.vm_main.location
  size                = var.vm_size
  admin_username      = "devopsadmin"
  admin_password      = "FGHJfghj1234"
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
    devops_pool   = var.devops_pool
    devops_pat    = var.devops_pat
    agent_count   = var.agent_count
  }))

  identity {
    type = "SystemAssigned"
  }
}

output "vm_public_ip" {
  value = azurerm_public_ip.networking_main.ip_address
}

output "vm_resource_group_name" {
  value = azurerm_resource_group.vm_main.name
}

output "netowrking_resource_group_name" {
  value = azurerm_resource_group.networking_main.name
}