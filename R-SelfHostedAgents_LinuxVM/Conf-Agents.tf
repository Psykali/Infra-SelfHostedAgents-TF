# Get the public IP address after VM creation
data "azurerm_public_ip" "vm_ip" {
  name                = azurerm_public_ip.main.name
  resource_group_name = azurerm_resource_group.network_rg.name
  
  depends_on = [azurerm_linux_virtual_machine.main]
}

# Create a null_resource that waits for VM and public IP
resource "null_resource" "setup_devops_agents" {
  depends_on = [
    azurerm_linux_virtual_machine.main,
    azurerm_public_ip.main,
    data.azurerm_public_ip.vm_ip
  ]

  triggers = {
    vm_id         = azurerm_linux_virtual_machine.main.id
    public_ip     = data.azurerm_public_ip.vm_ip.ip_address
    script_hash   = filesha256("${path.module}/agent-setup.sh")
  }

  # Connection configuration for SSH
  connection {
    type     = "ssh"
    user     = azurerm_linux_virtual_machine.main.admin_username
    password = azurerm_linux_virtual_machine.main.admin_password
    host     = data.azurerm_public_ip.vm_ip.ip_address
    timeout  = "25m"
  }

  # Create the script directly on the VM
  provisioner "file" {
    content = templatefile("${path.module}/agent-setup.sh", {})
    destination = "/tmp/agent-setup.sh"
  }

  # Execute the script on the VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/agent-setup.sh",
      "sudo /tmp/agent-setup.sh",
      "echo 'Agent setup completed successfully'"
    ]
  }
}