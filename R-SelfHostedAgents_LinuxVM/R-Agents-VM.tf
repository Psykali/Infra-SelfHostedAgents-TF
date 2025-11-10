# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  size                = var.vm_size
  admin_username      = "devopsadmin"
  admin_password      = "FGHJfghj1234"
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

  # Fixed custom_data - removed agent_number from template variables
  custom_data = base64encode(templatefile("${path.module}/agent-setup.sh", {
    devops_org     = var.devops_org
    devops_project = var.devops_project
    devops_pool    = var.devops_pool
    devops_pat     = var.devops_pat
    agent_count    = var.agent_count
  }))

  identity {
    type = "SystemAssigned"
  }
}