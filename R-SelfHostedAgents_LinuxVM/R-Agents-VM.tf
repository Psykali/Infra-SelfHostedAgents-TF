# =============================================
# DEVOPS AGENT VIRTUAL MACHINE
# =============================================
# Purpose: Creates Ubuntu VM for hosting Azure DevOps self-hosted agents
# Uses password from Key Vault for secure authentication

resource "azurerm_linux_virtual_machine" "main" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.agent_rg.name
  location            = azurerm_resource_group.agent_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = azurerm_key_vault_secret.vm_admin_password.value  # From Key Vault
  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # OS Disk with custom name (recommendation #3)
  os_disk {
    name                 = local.os_disk_name  # Custom name
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

  # Custom data for initial configuration
  custom_data = filebase64("cloud-init.yaml")

  tags = merge(local.common_tags, {
    Component   = "compute"
    Description = "Ubuntu VM hosting Azure DevOps self-hosted agents"
    OS          = "Ubuntu-22.04-LTS"
    AutoPatch   = "false"
    Backup      = "false"
    Monitoring  = "basic"
  })
}