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
    destination = "agent-setup.sh"
  }

  provisioner "remote-exec" {
  inline = [
    # Paquets
    "sudo DEBIAN_FRONTEND=noninteractive apt update -y",
    "sudo DEBIAN_FRONTEND=noninteractive apt install -y unzip curl wget",
    "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
    
    # Set User without Password
    "echo '${azurerm_linux_virtual_machine.main.admin_username} ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/${azurerm_linux_virtual_machine.main.admin_username}",
    "sudo chmod 440 /etc/sudoers.d/${azurerm_linux_virtual_machine.main.admin_username}",
    
    # Fix and prepare the script
    "sed -i 's/\r$//' /home/devopsadmin/agent-setup.sh",
    "sudo chmod +x /home/devopsadmin/agent-setup.sh",
    
    # Run script with error output
    "cd /home/devopsadmin && ./agent-setup.sh 2>&1 || echo \"Script failed with exit code: $?\""
    ]
  }
}