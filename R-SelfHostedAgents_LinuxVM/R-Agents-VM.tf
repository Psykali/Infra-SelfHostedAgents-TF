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

  identity {
    type = "SystemAssigned"
  }
}

# Create a null_resource with local-exec provisioner
resource "null_resource" "setup_devops_agents" {
  depends_on = [azurerm_linux_virtual_machine.main]

  # Trigger on VM creation or when script changes
  triggers = {
    vm_id         = azurerm_linux_virtual_machine.main.id
    script_hash   = filesha256("${path.module}/agent-setup.sh")
  }

  # Connection configuration for SSH
  connection {
    type     = "ssh"
    user     = azurerm_linux_virtual_machine.main.admin_username
    password = azurerm_linux_virtual_machine.main.admin_password
    host     = azurerm_public_ip.main.ip_address
    timeout  = "10m"
  }

  # Copy the script to the VM
  provisioner "file" {
    source      = "${path.module}/agent-setup.sh"
    destination = "/tmp/agent-setup.sh"
  }

  # Copy the environment variables file
  provisioner "file" {
    content = templatefile("${path.module}/agent-env.tpl")
    destination = "/tmp/agent-env.sh"
  }

  # Execute the script on the VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/agent-setup.sh",
      "chmod +x /tmp/agent-env.sh",
      "source /tmp/agent-env.sh",
      "sudo /tmp/agent-setup.sh",
      "echo 'Agent setup completed successfully'"
    ]
  }
}