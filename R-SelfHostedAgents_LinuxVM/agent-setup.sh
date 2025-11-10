#!/bin/bash
# agent-setup.sh

# Parameters passed from Terraform
DEVOPS_ORG="${devops_org}"
DEVOPS_POOL="${devops_pool}"
DEVOPS_PAT="${devops_pat}"
AGENT_COUNT="${agent_count}"

# Update and upgrade system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    jq \
    software-properties-common

# Install Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Create devops user and directory
useradd -m -s /bin/bash devops
mkdir -p /home/devops/agents
chown -R devops:devops /home/devops/agents

# Function to install and configure a single agent
setup_agent() {
    local agent_number=$1
    local agent_name="agent-${agent_number}"
    local agent_dir="/home/devops/agents/${agent_name}"
    
    echo "Setting up agent ${agent_name}..."
    
    # Create directory for agent
    mkdir -p $agent_dir
    chown devops:devops $agent_dir
    
    # Download and install agent
    cd $agent_dir
    sudo -u devops bash << EOF
        # Download the agent
        AGENT_VERSION=$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | jq -r '.tag_name' | cut -c2-)
        wget -q https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz
        tar -xzf vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz
        
        # Configure the agent
        ./config.sh --unattended \
            --url "https://dev.azure.com/${DEVOPS_ORG}" \
            --auth pat \
            --token "${DEVOPS_PAT}" \
            --pool "${DEVOPS_POOL}" \
            --agent "${agent_name}" \
            --replace \
            --acceptTeeEula
        
        # Create systemd service
        sudo ./svc.sh install devops
EOF

    # Create systemd service file
    cat > /etc/systemd/system/azure-pipelines-agent-${agent_number}.service << EOF
[Unit]
Description=Azure Pipelines Agent ${agent_number}
After=network.target

[Service]
Type=simple
User=devops
WorkingDirectory=${agent_dir}
ExecStart=${agent_dir}/run.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start the service
    systemctl enable azure-pipelines-agent-${agent_number}.service
    systemctl start azure-pipelines-agent-${agent_number}.service
    
    echo "Agent ${agent_name} setup completed and service started"
}

# Install multiple agents
for i in $(seq 1 $AGENT_COUNT); do
    setup_agent $i
done

# Install Terraform
echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update && apt-get install -y terraform

echo "All agents setup completed successfully!"