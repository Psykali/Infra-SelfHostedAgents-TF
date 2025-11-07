#!/bin/bash

set -e

# Variables
DEVOPS_ORG="$1"
DEVOPS_PAT="$2"
AGENT_POOL="$3"
AGENT_NAME="$4"

echo "Starting DevOps agent setup for: $AGENT_NAME"

# Update and upgrade system
echo "Updating and upgrading system..."
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt-get install -y curl wget unzip apt-transport-https ca-certificates gnupg software-properties-common

# Install Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Create devops agent user
echo "Creating devops agent user..."
if id "devopsagent" &>/dev/null; then
    echo "User devopsagent already exists"
else
    sudo useradd -m -s /bin/bash devopsagent
    sudo usermod -aG sudo devopsagent
    echo "devopsagent ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi

# Switch to devopsagent user and setup agent
sudo -u devopsagent bash << EOF
cd /home/devopsagent

# Download and install Azure DevOps agent
echo "Downloading Azure DevOps agent..."
AGENT_VERSION=\$(curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget -q https://vstsagentpackage.azureedge.net/agent/\$AGENT_VERSION/vsts-agent-linux-x64-\$AGENT_VERSION.tar.gz

echo "Extracting agent..."
tar -zxvf vsts-agent-linux-x64-\$AGENT_VERSION.tar.gz

echo "Configuring agent..."
./config.sh --unattended \
  --url "https://dev.azure.com/$DEVOPS_ORG" \
  --auth pat \
  --token "$DEVOPS_PAT" \
  --pool "$AGENT_POOL" \
  --agent "$AGENT_NAME" \
  --replace \
  --acceptTeeEula

echo "Creating systemd service..."
sudo ./svc.sh install devopsagent
EOF

# Create the systemd service file
sudo tee /etc/systemd/system/azure-devops-agent-$AGENT_NAME.service > /dev/null << EOF
[Unit]
Description=Azure DevOps Agent $AGENT_NAME
After=network.target

[Service]
Type=simple
User=devopsagent
WorkingDirectory=/home/devopsagent
ExecStart=/home/devopsagent/runsvc.sh
Restart=always
RestartSec=10
Environment=AGENT_ALLOW_RUNASROOT=1

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
echo "Enabling and starting Azure DevOps agent service..."
sudo systemctl daemon-reload
sudo systemctl enable azure-devops-agent-$AGENT_NAME.service
sudo systemctl start azure-devops-agent-$AGENT_NAME.service

echo "Azure DevOps agent setup completed successfully for $AGENT_NAME!"
echo "Agent $AGENT_NAME is now running and connected to Azure DevOps"