# DevOps Infrastructure - Terraform Deployment

## 📋 Overview

This repository contains Terraform infrastructure for deploying a secure, enterprise-grade Azure DevOps environment with self-hosted agents and private state storage.

## 🏗️ Architecture

The infrastructure is divided into two independent but complementary deployments:

### **Storage Account Deployment** (`storage-account/`)
- Private Storage Account for Terraform state files
- Private endpoint with Private DNS Zone
- Secure, no public access configuration
- Persistent resource group (should not be deleted)

### **DevOps Agents Deployment** (`devops-agents/`)
- Ubuntu VM with Azure DevOps self-hosted agents
- Key Vault for secure credential management
- Network infrastructure (VNET, NSG, Subnet)
- Private connectivity to storage
- Auto-generated secure passwords

## 📁 Folder Structure
devops-infrastructure/
├── 📖 README.md # This file
├── 📁 storage-account/ # STORAGE ACCOUNT DEPLOYMENT
│ ├── 📄 README-storage.md # Storage-specific documentation
│ ├── 📄 providers.tf # Terraform providers configuration
│ ├── 📄 variables.tf # Input variables
│ ├── 📄 locals.tf # Naming conventions and locals
│ ├── 📄 data-sources.tf # References to existing resources
│ ├── 📄 R-RessourceGroup.tf # Storage resource group
│ ├── 📄 R-StorageAccount.tf # Private storage account
│ ├── 📄 R-Networking.tf # Private endpoint
│ ├── 📄 private-dns.tf # Private DNS zone configuration
│ ├── 📄 outputs.tf # Output values
│ └── 📄 Test-Connection.tf # Connectivity tests
│
└── 📁 devops-agents/ # DEVOPS AGENTS DEPLOYMENT
├── 📄 README-agents.md # Agents-specific documentation
├── 📄 providers.tf # Terraform providers with backend
├── 📄 variables.tf # Input variables
├── 📄 locals.tf # Naming conventions and locals
├── 📄 data-sources.tf # References to existing resources
├── 📄 R-RessourceGroups.tf # Network and agent resource groups
├── 📄 R-Vnet-Subnet.tf # Virtual network and subnet
├── 📄 R-NSG.tf # Network security group
├── 📄 R-NIC.tf # Network interface (in agent RG)
├── 📄 R-PublicIP.tf # Public IP (optional)
├── 📄 keyvault.tf # Key Vault and secrets
├── 📄 private-endpoints.tf # Private endpoints for services
├── 📄 R-Agents-VM.tf # Ubuntu VM for agents
├── 📄 Conf-Agents.tf # Agent configuration
├── 📄 S-Bash-agent-setup.sh # Agent installation script
├── 📄 agent-config.tmpl # Agent configuration template
├── 📄 outputs.tf # Output values
└── 📄 terraform.tfvars.example # Example variables file

text

## 🎯 Deployment Objectives

### ✅ **Following Microsoft Recommendations:**
1. **Resource Group Distribution**
   - Network resources in Network RG
   - VM + Key Vault in Agent RG
   - Storage in separate persistent RG

2. **Microsoft Naming Conventions**
   - All resources follow Azure naming best practices
   - Consistent naming across all deployments

3. **Security Best Practices**
   - Private endpoints for all PaaS services
   - No public access to storage
   - NSG at subnet level
   - Key Vault for secrets management

4. **Infrastructure as Code Principles**
   - Modular, maintainable code
   - Version-controlled configuration
   - Repeatable deployments

## 🚀 Deployment Sequence

### **Phase 1: Initial Setup**
```bash
# Clone repository
git clone <repository-url>
cd devops-infrastructure

# Configure Azure authentication
az login
az account set --subscription <subscription-id>
Phase 2: Deploy Storage Account (First Time Only)
bash
cd storage-account/

# Initialize Terraform
terraform init

# Review deployment plan
terraform plan -out=storage.tfplan

# Apply deployment
terraform apply storage.tfplan

# Save outputs for next phase
terraform output -json > ../storage-outputs.json
Phase 3: Deploy DevOps Agents
bash
cd ../devops-agents/

# Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize with remote backend (using storage account)
terraform init

# Review deployment plan
terraform plan -out=agents.tfplan

# Apply deployment
terraform apply agents.tfplan
Phase 4: Post-Deployment Configuration
Retrieve VM password from Key Vault

Configure Azure DevOps organization and PAT token

Verify agent connectivity

Test storage connectivity

🔧 Configuration
Required Variables
Create terraform.tfvars in each folder with:

For storage-account/:

hcl
customer     = "yourclient"
environment  = "prd"
location     = "francecentral"
For devops-agents/:

hcl
client_name          = "yourclient"
environment          = "prd"
location             = "francecentral"
azure_devops_url     = "https://dev.azure.com/your-org"
pat_token            = "your-pat-token"  # Store securely!
Optional Variables
vm_size: VM size for agents (default: Standard_B2als_v2)

agent_count: Number of agents (default: 5)

key_vault_sku: Key Vault SKU (default: standard)

🔒 Security Features
Network Security
Private endpoints for all PaaS services

NSG at subnet level (not NIC level)

No public access to storage account

Restricted inbound traffic (SSH only)

Secrets Management
Auto-generated VM passwords

Secrets stored in Key Vault

System-assigned identities for access

No secrets in Terraform state

Compliance
RGPD compliance (France Central region)

Microsoft naming conventions

Enterprise security patterns

Audit logging enabled

📊 Outputs
Storage Account Deployment:
bash
# After deployment, you'll get:
- Storage account name
- Container name
- Private endpoint IP
- Backend configuration for Terraform
DevOps Agents Deployment:
bash
# After deployment, you'll get:
- VM public IP address
- Key Vault name and ID
- Resource group names
- Connection instructions

🛠️ Maintenance
Updating Agents
Update S-Bash-agent-setup.sh with new agent version

Run terraform apply to update VM configuration

Scaling Agents
Update agent_count variable

Run terraform apply

Rotating Secrets
Generate new PAT token in Azure DevOps

Update in Key Vault

Restart agent services

🚨 Troubleshooting
Common Issues:
Storage Account Connection Failed

bash
# Check private endpoint status
az network private-endpoint show --name <endpoint-name> --resource-group <rg-name>

# Verify DNS resolution
nslookup <storage-account>.blob.core.windows.net
Agents Not Connecting to Azure DevOps

bash
# Check agent service status
systemctl status <agent-service>

# View agent logs
journalctl -u <agent-service> -f
Terraform State Locked

bash
# Force unlock if needed
terraform force-unlock <lock-id>
Monitoring:
Check Azure Monitor for VM metrics

Review Key Vault access logs

Monitor storage account activity

Check Azure DevOps agent pool status

📝 Best Practices
Version Control
Store .tfstate files in remote backend only

Never commit .tfvars files with secrets

Use Git tags for deployment versions

Collaboration
Use Terraform Cloud/Enterprise for teams

Implement pull request reviews

Maintain change logs

Cost Optimization
Use appropriate VM sizes

Implement auto-shutdown schedules

Monitor storage usage