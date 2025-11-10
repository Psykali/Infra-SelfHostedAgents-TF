#!/bin/bash
DEVOPS_ORG="bseforgedevops"
DEVOPS_PROJECT="TestScripts-Forge"
DEVOPS_POOL="client-hostedagents-ubuntu01"
DEVOPS_PAT="BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J"
AGENT_COUNT="5"

# Install Azure CLI
echo "Installing Azure CLI..."
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Create devops user and director
sudo mkdir -p /opt/az_devops/agents


# Function to install and configure a single agent
setup_agent() {
    local agent_number=$1
    local agent_name="agent-${agent_number}"
    local agent_dir="/opt/az_devops/agents/${agent_name}"
    
    echo "Setting up agent ${agent_name}..."
    
    # Create directory for agent
    sudo mkdir -p $agent_dir
    
    # Download and install agent
    cd $agent_dir
    sudo bash << EOF
        # Download the agent
        AGENT_VERSION=4.264.2
        sudo wget -q https://download.agent.dev.azure.com/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz
        sudo tar -xzf vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz
        
        # Configure the agent with project name
        sudo ./config.sh --unattended --url "https://dev.azure.com/${DEVOPS_ORG}" --auth pat --token "${DEVOPS_PAT}" --pool "${DEVOPS_POOL}" --agent "${agent_name}" --projectname "${DEVOPS_PROJECT}" --replace --acceptTeeEula
        
        # Create systemd service
        sudo ./run.sh
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
    sudo systemctl enable azure-pipelines-agent-${agent_number}.service
    sudo systemctl start azure-pipelines-agent-${agent_number}.service
    
    echo "Agent ${agent_name} setup completed and service started"
}

# Install multiple agents
for i in $(seq 1 $AGENT_COUNT); do
    sudo setup_agent $i
done

echo "All agents setup completed successfully!"