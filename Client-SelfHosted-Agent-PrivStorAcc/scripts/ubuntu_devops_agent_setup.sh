#!/bin/bash

# Update and upgrade system
echo "Updating and upgrading system..."
apt-get update
apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
apt-get install -y curl wget unzip apt-transport-https ca-certificates gnupg software-properties-common jq

# Install Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Terraform (optional - for testing connectivity)
echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update && apt-get install -y terraform

# Create devops agent user
echo "Creating devops agent user..."
if id "devopsagent" &>/dev/null; then
    echo "User devopsagent already exists"
else
    useradd -m -s /bin/bash devopsagent
    usermod -aG sudo devopsagent
    echo "devopsagent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
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
  --url "https://dev.azure.com/${devops_org}" \
  --auth pat \
  --token "${devops_pat}" \
  --pool "${devops_agent_pool}" \
  --agent "${devops_agent_name}" \
  --replace \
  --acceptTeeEula

echo "Creating systemd service..."
sudo ./svc.sh install devopsagent
EOF

# Create the systemd service file
cat << EOF > /etc/systemd/system/azure-devops-agent-${devops_agent_name}.service
[Unit]
Description=Azure DevOps Agent ${devops_agent_name}
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
systemctl daemon-reload
systemctl enable azure-devops-agent-${devops_agent_name}.service
systemctl start azure-devops-agent-${devops_agent_name}.service

# Test storage account connectivity from the VM
echo "Testing storage account connectivity..."
echo "Storage Account: ${storage_account_name}"
echo "Resource Group: ${resource_group_name}"

# Test if we can access the storage account via private endpoint
echo "Testing private endpoint connectivity..."
if az storage container list --account-name ${storage_account_name} --auth-mode login > /dev/null 2>&1; then
    echo "SUCCESS: Storage account is accessible via private endpoint"
else
    echo "WARNING: Cannot access storage account directly. This is expected if private endpoint is not configured for this VM."
    echo "The private endpoint configuration allows the self-hosted agent to access the storage account internally."
fi

echo "Azure DevOps agent setup completed successfully for ${devops_agent_name}!"
echo "Private storage account ${storage_account_name} is configured for Terraform state management"