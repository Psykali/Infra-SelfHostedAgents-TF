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

# Create the script directly on the VM
  provisioner "remote-exec" {
  inline = [
    # Step 1: Fix APT issues first
    "echo '=== Fixing APT package manager ==='",
    "sudo rm -rf /var/lib/apt/lists/*",
    "sudo apt-get clean",
    "sudo apt-get update --fix-missing || true",
    
    # Step 2: Install required packages with error handling
    "echo '=== Installing required packages ==='",
    "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget unzip git jq software-properties-common apt-transport-https ca-certificates gnupg lsb-release",
    
    # Step 3: Install Azure CLI
    "echo '=== Installing Azure CLI ==='",
    "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
    
    # Step 4: Create user and directories
    "echo '=== Creating user and directories ==='",
    "sudo useradd -m -s /bin/bash devops 2>/dev/null || true",
    "sudo mkdir -p /home/devops/agents",
    "sudo chown -R devops:devops /home/devops/agents",
    
    # Step 5: Setup 1st agent with hardcoded version
    "echo '=== Setting up first agent ==='",
    "sudo -u devops mkdir -p /home/devops/agents/agent-1",
    "cd /home/devops/agents/agent-1",
    "sudo -u devops wget -q https://vstsagentpackage.azureedge.net/agent/3.227.2/vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops tar -xzf vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops ./config.sh --unattended --url 'https://dev.azure.com/bseforgedevops' --auth pat --token 'BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J' --pool 'client-hostedagents-ubuntu01' --agent 'agent-1' --projectname 'TestScripts-Forge' --replace --acceptTeeEula",
    "sudo ./svc.sh install devops",
    
    # Step 6: Setup 2nd agent
    "echo '=== Setting up second agent ==='",
    "sudo -u devops mkdir -p /home/devops/agents/agent-2",
    "cd /home/devops/agents/agent-2", 
    "sudo -u devops wget -q https://vstsagentpackage.azureedge.net/agent/3.227.2/vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops tar -xzf vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops ./config.sh --unattended --url 'https://dev.azure.com/bseforgedevops' --auth pat --token 'BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J' --pool 'client-hostedagents-ubuntu01' --agent 'agent-2' --projectname 'TestScripts-Forge' --replace --acceptTeeEula",
    "sudo ./svc.sh install devops",
    
    # Step 7: Setup 3rd agent
    "echo '=== Setting up second agent ==='",
    "sudo -u devops mkdir -p /home/devops/agents/agent-3",
    "cd /home/devops/agents/agent-3", 
    "sudo -u devops wget -q https://vstsagentpackage.azureedge.net/agent/3.227.2/vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops tar -xzf vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops ./config.sh --unattended --url 'https://dev.azure.com/bseforgedevops' --auth pat --token 'BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J' --pool 'client-hostedagents-ubuntu01' --agent 'agent-2' --projectname 'TestScripts-Forge' --replace --acceptTeeEula",
    "sudo ./svc.sh install devops",
    
    # Step 8: Setup 4th agent
    "echo '=== Setting up second agent ==='",
    "sudo -u devops mkdir -p /home/devops/agents/agent-4",
    "cd /home/devops/agents/agent-4", 
    "sudo -u devops wget -q https://vstsagentpackage.azureedge.net/agent/3.227.2/vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops tar -xzf vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops ./config.sh --unattended --url 'https://dev.azure.com/bseforgedevops' --auth pat --token 'BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J' --pool 'client-hostedagents-ubuntu01' --agent 'agent-2' --projectname 'TestScripts-Forge' --replace --acceptTeeEula",
    "sudo ./svc.sh install devops",
    
    # Step 9: Setup 5th agent
    "echo '=== Setting up second agent ==='",
    "sudo -u devops mkdir -p /home/devops/agents/agent-5",
    "cd /home/devops/agents/agent-5", 
    "sudo -u devops wget -q https://vstsagentpackage.azureedge.net/agent/3.227.2/vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops tar -xzf vsts-agent-linux-x64-3.227.2.tar.gz",
    "sudo -u devops ./config.sh --unattended --url 'https://dev.azure.com/bseforgedevops' --auth pat --token 'BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J' --pool 'client-hostedagents-ubuntu01' --agent 'agent-2' --projectname 'TestScripts-Forge' --replace --acceptTeeEula",
    "sudo ./svc.sh install devops",
    
    "echo '=== Setup completed successfully! ==='"
   ]
  }
}
