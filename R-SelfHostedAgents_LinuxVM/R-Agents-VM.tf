# =============================================
# VIRTUAL MACHINE - DEVOPS AGENTS
# =============================================
# Purpose: Create Ubuntu VM for hosting DevOps agents
# Usage: Self-hosted agent VM with Key Vault integration

resource "azurerm_linux_virtual_machine" "main" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.agent.name
  location            = azurerm_resource_group.agent.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = azurerm_key_vault_secret.vm_admin_password.value
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
  
  # Custom data script for agent installation
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    storage_account_name = "st${var.client_name}devops${var.environment}${var.location_code}01"
    storage_account_key  = ""  # Will be injected via Key Vault
    private_endpoint_ip  = ""  # Will be injected after storage deployment
  }))
  
  tags = merge(local.common_tags, {
    Component   = "compute"
    Description = "Ubuntu VM for Azure DevOps self-hosted agents"
    OS          = "Ubuntu-22.04-LTS"
  })
}