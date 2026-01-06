# =============================================
# CONFIGURE DEVOPS AGENTS ON VM
# =============================================
# Purpose: SSH into VM and configure Azure DevOps agents with Key Vault integration
# Usage: Uploads and executes agent setup script after VM creation, passing Key Vault info

resource "null_resource" "setup_devops_agents" {
  depends_on = [
    azurerm_linux_virtual_machine.main,
    azurerm_key_vault.main,
    azurerm_key_vault_secret.vm_password,
    azurerm_key_vault_secret.devops_pat,
    azurerm_key_vault_secret.agent_config,
  ]
  

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = random_password.vm_password.result
    host     = data.azurerm_public_ip.vm_ip.ip_address
  }

  # Upload the main setup script
  provisioner "file" {
    source      = "S-Bash-agent-setup.sh"
    destination = "/home/${var.admin_username}/agent-setup.sh"
  }

  # Upload environment configuration file with Key Vault details
  provisioner "file" {
    content = templatefile("${path.module}/S-Agent-Env.sh.tpl", {
      key_vault_name    = azurerm_key_vault.main.name
      vm_resource_group = azurerm_resource_group.vm_rg.name
      client_name       = var.client_name
      admin_username    = var.admin_username
      agent_count       = var.agent_count
      agent_version     = var.agent_version
    })
    destination = "/home/${var.admin_username}/agent-env.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # System packages and Azure CLI
      "sudo DEBIAN_FRONTEND=noninteractive apt update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt install -y unzip curl wget jq",
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
      
      # Configure sudo for admin user
      "echo '${var.admin_username} ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/${var.admin_username}",
      "sudo chmod 440 /etc/sudoers.d/${var.admin_username}",
          
      # Set up environment variables
      "sed -i 's/\\r$//' /home/${var.admin_username}/agent-env.sh",
      "chmod +x /home/${var.admin_username}/agent-env.sh",
      ". /home/${var.admin_username}/agent-env.sh",
      
      # Prepare and execute setup script
      "sed -i 's/\\r$//' /home/${var.admin_username}/agent-setup.sh",
      "sed -i 's/\r$//' /home/${var.admin_username}/agent-setup.sh",
      "sudo chmod +x /home/${var.admin_username}/agent-setup.sh",
      
      # Run the setup script with Key Vault integration
      "cd /home/${var.admin_username} && ./agent-setup.sh --use-keyvault 2>&1 | tee /home/${var.admin_username}/setup.log",
      
      # Display setup log for debugging
      "echo '=== Setup Log Tail ==='",
      "tail -20 /home/${var.admin_username}/setup.log"
    ]
  }
}