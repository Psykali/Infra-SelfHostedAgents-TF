# =============================================
# VIRTUAL MACHINE - DEVOPS AGENTS
# =============================================
# Purpose: Create Ubuntu VM for hosting DevOps agents
# Usage: Self-hosted agent VM with Key Vault integration

# Generate local password for VM (breaks circular dependency)
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
  
  # System-assigned identity for future Key Vault access
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(local.common_tags, {
    Component   = "compute"
    Description = "Ubuntu VM for Azure DevOps self-hosted agents"
    OS          = "Ubuntu-22.04-LTS"
  })
  
  lifecycle {
    ignore_changes = [
      admin_password  # Password will be managed separately
    ]
  }
}

# Simple extension to install Azure CLI (optional)
resource "azurerm_virtual_machine_extension" "install_tools" {
  name                 = "InstallTools"
  virtual_machine_id   = azurerm_linux_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  
  settings = <<SETTINGS
    {
      "script": "#!/bin/bash\napt-get update\napt-get install -y curl wget unzip jq\ncurl -sL https://aka.ms/InstallAzureCLIDeb | bash"
    }
  SETTINGS
  
  tags = merge(local.common_tags, {
    Component = "setup"
    Purpose   = "install-tools"
  })
}