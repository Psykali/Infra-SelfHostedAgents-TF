# =============================================
# VIRTUAL MACHINE - DEVOPS AGENTS
# =============================================
# Purpose: Create Ubuntu VM for hosting DevOps agents
# Usage: Self-hosted agent VM - ALL CONFIGURATION DONE IN Conf-agentVM.tf

# Generate local password for VM
resource "random_password" "local_vm_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>:?"
}

# Create VM with local password
resource "azurerm_linux_virtual_machine" "main" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.agent.name
  location            = azurerm_resource_group.agent.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.local_vm_password.result
  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  
  # OS Disk with custom name
  os_disk {
    name                 = local.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  # Ubuntu 22.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  
  # System-assigned identity for Key Vault access
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(local.common_tags, {
    Component   = "compute"
    Description = "Ubuntu VM for Azure DevOps self-hosted agents"
    OS          = "Ubuntu-22.04-LTS"
  })
}