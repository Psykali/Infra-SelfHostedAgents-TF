#!/bin/bash

# Update and upgrade system
echo "=== Updating system ==="
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
echo "=== Installing packages ==="
sudo apt-get install -y curl wget unzip apt-transport-https ca-certificates gnupg software-properties-common

# Install Azure CLI
echo "=== Installing Azure CLI ==="
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Docker (optional for container jobs)
echo "=== Installing Docker ==="
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# Create devops agent user and directory
echo "=== Setting up DevOps Agent ==="
sudo useradd -m -s /bin/bash devopsagent
sudo usermod -aG sudo devopsagent
sudo mkdir -p /opt/devops-agent
sudo chown devopsagent:devopsagent /opt/devops-agent

# Function to install DevOps agent
install_agent() {
    local AGENT_DIR="/opt/devops-agent"
    cd $AGENT_DIR
    
    # Download latest agent
    AGENT_VERSION=$(curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    sudo -u devopsagent wget -q https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz
    
    # Extract agent
    sudo -u devopsagent tar -zxvf vsts-agent-linux-x64-$AGENT_VERSION.tar.gz
    
    # Create systemd service
    cat << EOF | sudo tee /etc/systemd/system/azure-devops-agent.service
[Unit]
Description=Azure DevOps Agent
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
    sudo systemctl enable azure-devops-agent.service
    
    echo "Agent installed. Manual configuration required with:"
    echo "cd /opt/devops-agent && sudo -u devopsagent ./config.sh"
}

install_agent

echo "=== Setup completed successfully ==="
echo "=== Installed packages: ==="
echo "- System updates"
echo "- curl, wget, unzip"
echo "- Azure CLI"
echo "- Docker"
echo "- Azure DevOps Agent (manual configuration needed)"