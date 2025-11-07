#!/bin/bash

# Update and upgrade system
echo "=== Updating system ==="
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
echo "=== Installing packages ==="
sudo apt-get install -y curl wget unzip apt-transport-https ca-certificates gnupg software-properties-common jq

# Install Azure CLI
echo "=== Installing Azure CLI ==="
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Create devops agent user and directory
echo "=== Setting up DevOps Agent ==="
sudo useradd -m -s /bin/bash devopsagent || echo "User devopsagent already exists"
sudo usermod -aG sudo devopsagent
sudo mkdir -p /opt/devops-agent
sudo chown devopsagent:devopsagent /opt/devops-agent

# Install DevOps Agent
sudo -u devopsagent bash << 'EOF'
cd /opt/devops-agent

# Download latest agent
AGENT_VERSION=$(curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | jq -r '.tag_name' | sed 's/v//')
wget -q https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz

# Extract agent
tar -zxvf vsts-agent-linux-x64-$AGENT_VERSION.tar.gz
rm vsts-agent-linux-x64-$AGENT_VERSION.tar.gz

echo "Agent downloaded and extracted. Manual configuration required."
echo "Run: cd /opt/devops-agent && ./config.sh"
EOF

# Create systemd service template
cat << 'EOF' | sudo tee /etc/systemd/system/azure-devops-agent@.service
[Unit]
Description=Azure DevOps Agent %i
After=network.target

[Service]
Type=simple
User=devopsagent
WorkingDirectory=/opt/devops-agent
ExecStart=/opt/devops-agent/runsvc.sh
Restart=always
RestartSec=10
Environment=AGENT_ALLOW_RUNASROOT=1

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

echo "=== Setup completed successfully ==="
echo "Manual steps:"
echo "1. SSH to the VM: ssh BseSelfAgent@<VM_IP>"
echo "2. Switch to devopsagent: sudo -u devopsagent bash"
echo "3. Configure agent: cd /opt/devops-agent && ./config.sh"
echo "4. Enable service: sudo systemctl enable azure-devops-agent@1.service"
echo "5. Start service: sudo systemctl start azure-devops-agent@1.service"