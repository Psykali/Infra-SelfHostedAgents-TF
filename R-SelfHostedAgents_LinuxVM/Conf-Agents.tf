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
    data.azurerm_public_ip.vm_ip
  ]

  connection {
    type     = "ssh"
    user     = azurerm_linux_virtual_machine.main.admin_username
    password = azurerm_linux_virtual_machine.main.admin_password
    host     = data.azurerm_public_ip.vm_ip.ip_address
    timeout  = "15m"
  }

  provisioner "remote-exec" {
  inline = [
    "echo 'Updating system packages...'",
    "sudo apt update && sudo apt upgrade -y",
    "echo 'Installing required packages...'",
    "sudo install -y curl wget unzip software-properties-common",
    "echo 'Downloading agent configuration script...'",
    "wget -O /tmp/agent-config.sh 'https://dev.azure.com/bseforgedevops/TestScripts-Forge/_git/Test-Client-VM-AgentPool?path=/agent-setup.sh&download=true'",
    "sudo chmod +x /tmp/agent-config.sh",
    "sudo /tmp/agent-config.sh"
   ]
  }
}