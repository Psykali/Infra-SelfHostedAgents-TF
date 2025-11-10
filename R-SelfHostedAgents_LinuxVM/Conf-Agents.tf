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
    user     = "devopsadmin"
    password = "FGHJfghj1234"
    host     = data.azurerm_public_ip.vm_ip.ip_address
    timeout  = "15m"
  }

  # Create the script directly on the VM
  provisioner "remote-exec" {
    inline = [
      "cat > /tmp/agent-setup.sh << 'EOF'",
      "#!/bin/bash",
      "echo 'Starting agent setup...'",
      "DEVOPS_ORG='bseforgedevops'",
      "DEVOPS_PROJECT='TestScripts-Forge'",
      "DEVOPS_POOL='client-hostedagents-ubuntu01'", 
      "DEVOPS_PAT='BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J'",
      "AGENT_COUNT=5",
      "echo 'Updating system...'",
      "apt-get update && apt-get upgrade -y",
      "apt-get install -y curl wget unzip git jq",
      "curl -sL https://aka.ms/InstallAzureCLIDeb | bash",
      "useradd -m -s /bin/bash devops",
      "mkdir -p /home/devops/agents",
      "chown -R devops:devops /home/devops/agents",
      "for i in {1..5}; do",
      "  agent_dir=\"/home/devops/agents/agent-\$i\"",
      "  mkdir -p \"\$agent_dir\"",
      "  chown devops:devops \"\$agent_dir\"",
      "  cd \"\$agent_dir\"",
      "  sudo -u devops bash -c \"",
      "    AGENT_VERSION=\\$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | jq -r '.tag_name' | cut -c2-)",
      "    wget -q https://vstsagentpackage.azureedge.net/agent/\\$AGENT_VERSION/vsts-agent-linux-x64-\\$AGENT_VERSION.tar.gz",
      "    tar -xzf vsts-agent-linux-x64-\\$AGENT_VERSION.tar.gz",
      "    ./config.sh --unattended --url https://dev.azure.com/$DEVOPS_ORG --auth pat --token $DEVOPS_PAT --pool $DEVOPS_POOL --agent agent-\$i --projectname $DEVOPS_PROJECT --replace --acceptTeeEula",
      "    sudo ./svc.sh install devops",
      "  \"",
      "  systemctl enable azure-pipelines-agent-\$i.service",
      "  systemctl start azure-pipelines-agent-\$i.service",
      "  echo 'Agent \$i setup completed'",
      "done",
      "echo 'All agents setup successfully!'",
      "EOF",
      "chmod +x /tmp/agent-setup.sh",
      "sudo /tmp/agent-setup.sh"
    ]
  }
}