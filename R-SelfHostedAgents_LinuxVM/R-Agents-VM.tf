# =============================================
# VIRTUAL MACHINE - DEVOPS AGENTS
# =============================================
# Purpose: Create Ubuntu VM for hosting DevOps agents
# Usage: Self-hosted agent VM - ALL CONFIGURATION DONE IN Conf-agentVM.tf

resource "azurerm_linux_virtual_machine" "main" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.vm_password.result  # Use generated password
  disable_password_authentication = false
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

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.common_tags, {
    Description     = "Ubuntu VM hosting Azure DevOps self-hosted agents"
    Component       = "compute"
    OS              = "Ubuntu-22.04-LTS"
    VM-Size         = var.vm_size
    AutoPatch       = "false"
    Backup          = "false"
    Monitoring      = "basic"
  })

  depends_on = [
    azurerm_key_vault_secret.vm_password,
    random_password.vm_password
  ]
}