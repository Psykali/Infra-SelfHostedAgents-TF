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
    destination = "agent-config.sh"
  }

  provisioner "remote-exec" {
  inline = [
    # Update system
    "sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y",
    
    # Install dependencies
    "sudo DEBIAN_FRONTEND=noninteractive apt install -y curl wget",
    
    # Set permissions on the uploaded file
    "cd /home/devopsadmin && sudo chmod +x agent-setup.sh",
    
    # Install Azure CLI
    "curl -sL https://aka.ms/InstallAzureCLIDeb | bash",
    
    # Wait for Azure CLI installation to complete
    "sleep 10",
    
    # Run the setup script
    "sudo /bin/bash agent-setup.sh"
    ]
  } 
}