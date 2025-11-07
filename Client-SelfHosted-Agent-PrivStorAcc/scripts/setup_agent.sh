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

# Function to install and configure DevOps agent
install_agent() {
    local AGENT_DIR="/opt/devops-agent"
    cd $AGENT_DIR
    
    # Download latest agent
    echo "Downloading Azure DevOps agent..."
    AGENT_VERSION=$(curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | jq -r '.tag_name' | sed 's/v//')
    sudo -u devopsagent wget -q https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz
    
    # Extract agent
    echo "Extracting agent..."
    sudo -u devopsagent tar -zxvf vsts-agent-linux-x64-$AGENT_VERSION.tar.gz
    sudo -u devopsagent rm vsts-agent-linux-x64-$AGENT_VERSION.tar.gz
    
    # Make agent executable
    sudo -u devopsagent chmod +x *.sh
    sudo -u devopsagent chmod +x bin/*
    
    echo "Agent installed. Manual configuration required with PAT."
    echo "Run: cd /opt/devops-agent && sudo -u devopsagent ./config.sh"
}

install_agent

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

# Create configuration helper script
cat << 'EOF' | sudo tee /opt/devops-agent/configure-agent.sh
#!/bin/bash

echo "Azure DevOps Agent Configuration Helper"
echo "========================================"

read -p "Enter Azure DevOps Organization: " ORG
read -p "Enter Agent Pool Name: " POOL
read -s -p "Enter PAT Token: " PAT
echo

cd /opt/devops-agent

sudo -u devopsagent ./config.sh --unattended \
  --url "https://dev.azure.com/$ORG" \
  --auth pat \
  --token "$PAT" \
  --pool "$POOL" \
  --agent "BSE-$(hostname)" \
  --replace \
  --acceptTeeEula

if [ $? -eq 0 ]; then
    echo "Agent configured successfully!"
    echo "Enabling and starting service..."
    sudo systemctl enable azure-devops-agent@1.service
    sudo systemctl start azure-devops-agent@1.service
    echo "Agent service started and enabled!"
else
    echo "Agent configuration failed!"
fi
EOF

sudo chmod +x /opt/devops-agent/configure-agent.sh

echo "=== Setup completed successfully ==="
echo ""
echo "Manual configuration steps:"
echo "1. SSH to the VM: ssh BseSelfAgent@<VM_IP>"
echo "2. Run the configuration helper: sudo /opt/devops-agent/configure-agent.sh"
echo "3. Follow the prompts to enter:"
echo "   - Azure DevOps Organization"
echo "   - Agent Pool Name"
echo "   - PAT Token (created in Stage 3)"
echo ""
echo "The agent will automatically register with your Azure DevOps organization!"