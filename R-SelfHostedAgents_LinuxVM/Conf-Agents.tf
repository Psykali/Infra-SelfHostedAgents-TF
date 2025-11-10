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

  triggers = {
    vm_id = azurerm_linux_virtual_machine.main.id
  }

  connection {
    type     = "ssh"
    user     = azurerm_linux_virtual_machine.main.admin_username
    password = azurerm_linux_virtual_machine.main.admin_password
    host     = data.azurerm_public_ip.vm_ip.ip_address
    timeout  = "25m"
  }

# Create the script directly on the VM - FIXED VERSION
  provisioner "remote-exec" {
  inline = [
    # Create the main setup script
    "cat > /tmp/agent-setup.sh << 'EOF'",
    "#!/bin/bash",
    "set -e",
    "echo '=== Starting DevOps Agent Setup ==='",
    "DEVOPS_ORG='bseforgedevops'",
    "DEVOPS_PROJECT='TestScripts-Forge'", 
    "DEVOPS_POOL='client-hostedagents-ubuntu01'",
    "DEVOPS_PAT='BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J'",
    "AGENT_COUNT=5",
    "echo 'Updating system and installing packages...'",
    "export DEBIAN_FRONTEND=noninteractive",
    "apt-get update",
    "apt-get upgrade -y",
    "apt-get install -y curl wget unzip git jq software-properties-common",
    "echo 'Installing Azure CLI...'",
    "curl -sL https://aka.ms/InstallAzureCLIDeb | bash",
    "echo 'Creating devops user...'",
    "mkdir -p /opt/devops/agents",
    "echo 'Setting up agents...'",
    "for i in {1..5}; do",
    "  agent_name=\"agent-$$i\"",
    "  agent_dir=\"/home/devops/agents/$$agent_name\"",
    "  echo \"Setting up agent $$agent_name in $$agent_dir\"",
    "  mkdir -p \"$$agent_dir\"",
    "  chown devops:devops \"$$agent_dir\"",
    "  cd \"$$agent_dir\"",
    "  sudo -u devops bash << 'DEVOPSEOF'",
    "    wget -q \"https://download.agent.dev.azure.com/agent/4.264.2/vsts-agent-linux-x64-4.264.2.tar.gz\"",
    "    tar -xzf \"vsts-agent-linux-x64-4.264.2.tar.gz\"",
    "    echo \"Configuring agent...\"",
    "    ./config.sh --unattended \\",
    "      --url \"https://dev.azure.com/$$DEVOPS_ORG\" \\",
    "      --auth pat \\",
    "      --token \"$$DEVOPS_PAT\" \\",
    "      --pool \"$$DEVOPS_POOL\" \\",
    "      --agent \"$$agent_name\" \\",
    "      --projectname \"$$DEVOPS_PROJECT\" \\",
    "      --replace \\",
    "      --acceptTeeEula",
    "    sudo ./run",
    "DEVOPSEOF",
    "  # Create systemd service",
    "  cat > \"/etc/systemd/system/azure-pipelines-agent-$$i.service\" << SERVICEEOF",
    "[Unit]",
    "Description=Azure Pipelines Agent $$i",
    "After=network.target",
    "[Service]",
    "Type=simple",
    "User=devops",
    "WorkingDirectory=$$agent_dir",
    "ExecStart=$$agent_dir/run.sh",
    "Restart=always",
    "RestartSec=10",
    "[Install]",
    "WantedBy=multi-user.target",
    "SERVICEEOF",
    "  systemctl enable \"azure-pipelines-agent-$$i.service\"",
    "  systemctl start \"azure-pipelines-agent-$$i.service\"",
    "  echo \"Agent $$agent_name setup completed\"",
    "done",
    "echo 'Installing Terraform...'",
    "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg",
    "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $$(lsb_release -cs) main\" | tee /etc/apt/sources.list.d/hashicorp.list",
    "apt-get update && apt-get install -y terraform",
    "echo '=== All agents setup successfully! ==='",
    "EOF",
    "chmod +x /tmp/agent-setup.sh",
    "sudo /tmp/agent-setup.sh"
  ]
 }
}