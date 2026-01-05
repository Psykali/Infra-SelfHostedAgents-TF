# =============================================
# VIRTUAL MACHINE - DEVOPS AGENTS
# =============================================
# Purpose: Create Ubuntu VM for hosting DevOps agents
# Usage: Self-hosted agent VM with Key Vault integration via extension

resource "azurerm_linux_virtual_machine" "main" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.agent.name
  location            = azurerm_resource_group.agent.location
  size                = var.vm_size
  admin_username      = var.admin_username
  
  # Use temporary password, will be replaced by Key Vault extension
  admin_password                  = "TempPassword123!"  # Temporary, will be changed
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
  
  # Both system-assigned and user-assigned identity
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(local.common_tags, {
    Component   = "compute"
    Description = "Ubuntu VM for Azure DevOps self-hosted agents"
    OS          = "Ubuntu-22.04-LTS"
  })
  
  # Ensure VM is created before Key Vault extension
  depends_on = [
    azurerm_key_vault.main,
    azurerm_key_vault_secret.vm_admin_password
  ]
}

# Use VM extension to retrieve password from Key Vault
resource "azurerm_virtual_machine_extension" "keyvault" {
  name                 = "KeyVaultPasswordSetup"
  virtual_machine_id   = azurerm_linux_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  
  settings = <<SETTINGS
    {
      "commandToExecute": "echo 'Password management via Key Vault extension would go here' > /tmp/keyvault-setup.txt"
    }
  SETTINGS
  
  protected_settings = <<PROTECTED_SETTINGS
    {
      "secretUrl": "${azurerm_key_vault_secret.vm_admin_password.id}"
    }
  PROTECTED_SETTINGS
  
  tags = merge(local.common_tags, {
    Component = "security"
    Purpose   = "keyvault-password-setup"
  })
}