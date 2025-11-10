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
      "cat > /tmp/agent-setup.sh << 'EOF'",
      "#!/bin/bash",
      "set -e",
      "echo '=== Starting DevOps Agent Setup ==='",
      "DEVOPS_ORG='bseforgedevops'",
      "DEVOPS_PROJECT='TestScripts-Forge'", 
      "DEVOPS_POOL='client-hostedagents-ubuntu01'",
      "DEVOPS_PAT='BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J'",
      "AGENT_COUNT=5",
      "echo 'Fixing package repositories and installing required packages...'",
      "sudo export DEBIAN_FRONTEND=noninteractive",
      "# Fix package sources - use Azure Ubuntu mirror for better reliability",
      "sudo sed -i 's/archive.ubuntu.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list",
      "sudo sed -i 's/security.ubuntu.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list",
      "# Update package lists with retry",
      "for i in {1..5}; do",
      "  echo 'Attempt $i to update package lists...'",
      "  sudo apt-get update && break || sleep 10",
      "done",
      "# Install packages with retry",
      "for i in {1..5}; do",
      "  echo 'Attempt $i to install packages...'",
      "  sudo apt-get install -y curl wget unzip && break || sleep 10",
      "done",
      "echo 'Installing Azure CLI...'",
      "sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
      "echo 'Creating agents directory...'",
      "sudo mkdir -p /opt/az-agents",
      "echo 'Setting up agents...'",
      "for i in {1..5}; do",
      "  agent_name=\"agent-$i\"",
      "  agent_dir=\"/opt/az-agents/$agent_name\"",
      "  echo \"Setting up agent $agent_name in $agent_dir\"",
      "  sudo mkdir -p \"$agent_dir\"",
      "  sudo cd \"$agent_dir\"",
      "  sudo wget -q \"https://download.agent.dev.azure.com/agent/4.264.2/vsts-agent-linux-x64-4.264.2.tar.gz\"",
      "  sudo tar -xzf \"vsts-agent-linux-x64-4.264.2.tar.gz\"",
      "  sudo echo \"Configuring agent...\"",
      "  sudo ./config.sh --unattended \\",
      "    --url \"https://dev.azure.com/$DEVOPS_ORG\" \\",
      "    --auth pat \\",
      "    --token \"$DEVOPS_PAT\" \\",
      "    --pool \"$DEVOPS_POOL\" \\",
      "    --agent \"$agent_name\" \\",
      "    --projectname \"$DEVOPS_PROJECT\" \\",
      "    --replace \\",
      "    --acceptTeeEula",
      "  # Create systemd service",
      "  sudo bash -c 'cat > /etc/systemd/system/azure-pipelines-agent-$i.service << SERVICEEOF",
      "[Unit]",
      "Description=Azure Pipelines Agent $i",
      "After=network.target",
      "[Service]",
      "Type=simple",
      "User=$USER",
      "WorkingDirectory=$agent_dir",
      "ExecStart=$agent_dir/run.sh",
      "Restart=always",
      "RestartSec=10",
      "[Install]",
      "WantedBy=multi-user.target",
      "SERVICEEOF",
      "  '",
      "  sudo systemctl enable \"azure-pipelines-agent-$i.service\"",
      "  sudo systemctl start \"azure-pipelines-agent-$i.service\"",
      "  echo \"Agent $agent_name setup completed\"",
      "done",
      "echo '=== All agents setup successfully! ==='",
      "EOF",
      "sudo chmod +x /tmp/agent-setup.sh",
      "sudo /tmp/agent-setup.sh"
    ]
  }
}