# Get the public IP address after VM creation
data "azurerm_public_ip" "vm_ip" {
  name                = azurerm_public_ip.main.name
  resource_group_name = azurerm_resource_group.network_rg.name
  depends_on = [azurerm_linux_virtual_machine.main]
}

# Create a null_resource that waits for VM
resource "null_resource" "setup_devops_agents" {
  depends_on = [azurerm_linux_virtual_machine.main]

  connection {
    type     = "ssh"
    user     = azurerm_linux_virtual_machine.main.admin_username
    password = azurerm_linux_virtual_machine.main.admin_password
    host     = data.azurerm_public_ip.vm_ip.ip_address
  }

  # Upload the script file
  provisioner "file" {
    source      = "agent-setup.sh"
    destination = "/home/devopsadmin/agent-config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Checking if file was uploaded...'",
      "ls -la /tmp/agent-config.sh",
      "echo 'Setting permissions...'",
      "sudo chmod +x /tmp/agent-config.sh",
      "echo 'Starting agent configuration...'",
      "sudo /tmp/agent-config.sh"
    ]
  }
}