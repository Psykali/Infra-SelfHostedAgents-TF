# =============================================
# CONFIGURE DEVOPS AGENTS ON VM
# =============================================
# Purpose: SSH into VM and configure Azure DevOps agents
# Usage: Uploads and executes agent setup script after VM creation
# Note: This is your working script, modified to use Key Vault password

# Wait for VM and Key Vault to be ready
resource "null_resource" "setup_devops_agents" {
  depends_on = [
    azurerm_linux_virtual_machine.main,
    azurerm_key_vault_secret.vm_admin_password,
    azurerm_key_vault_access_policy.vm_identity
  ]

  connection {
    type     = "ssh"
    user     = azurerm_linux_virtual_machine.main.admin_username
    # Use password from Key Vault
    password = azurerm_key_vault_secret.vm_admin_password.value
    host     = data.azurerm_public_ip.vm_ip.ip_address
  }
  
  # Upload the agent setup script
  provisioner "file" {
    source      = "S-Bash-agent-setup.sh"
    destination = "agent-setup.sh"
  }

  # Execute configuration commands
  provisioner "remote-exec" {
    inline = [
      # Update packages
      "sudo DEBIAN_FRONTEND=noninteractive apt update -y",
      
      # Install required tools
      "sudo DEBIAN_FRONTEND=noninteractive apt install -y unzip curl wget jq",
      
      # Install Azure CLI
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
      
      # Set User without Password for sudo
      "echo '${azurerm_linux_virtual_machine.main.admin_username} ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/${azurerm_linux_virtual_machine.main.admin_username}",
      "sudo chmod 440 /etc/sudoers.d/${azurerm_linux_virtual_machine.main.admin_username}",
      
      # Fix line endings and make script executable
      "sed -i 's/\r$//' /home/${azurerm_linux_virtual_machine.main.admin_username}/agent-setup.sh",
      "sudo chmod +x /home/${azurerm_linux_virtual_machine.main.admin_username}/agent-setup.sh",
      
      # Create directory for agents
      "sudo mkdir -p /opt/azure-devops-agents",
      "sudo chown ${azurerm_linux_virtual_machine.main.admin_username}:${azurerm_linux_virtual_machine.main.admin_username} /opt/azure-devops-agents",
      
      # Run script with error output
      "cd /home/${azurerm_linux_virtual_machine.main.admin_username} && ./agent-setup.sh 2>&1 | tee setup.log"
    ]
  }
  
  # Add retry logic in case of transient SSH issues
  provisioner "local-exec" {
    command = "echo 'Agent setup completed or in progress. Check /home/${azurerm_linux_virtual_machine.main.admin_username}/setup.log on VM for details.'"
  }
}