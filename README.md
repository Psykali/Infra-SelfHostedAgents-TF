# Azure DevOps Private Agent Infrastructure Setup

This project sets up a complete Azure DevOps infrastructure with private agents, private storage, and private links for secure CI/CD pipelines.

## Architecture Overview

- **Private DevOps Agents**: Ubuntu VM with multiple Azure DevOps agents
- **Private Storage Account**: Secure storage for Terraform state files
- **Private Endpoints**: Secure network connectivity
- **Systemd Services**: Managed agent services
- **Azure CLI & Terraform**: Infrastructure as Code

## Prerequisites

- Azure Subscription
- Azure DevOps Organization
- Azure CLI installed
- Terraform installed
- Appropriate permissions in Azure and Azure DevOps

## Step-by-Step Implementation

### 1. Create Service Principal (SPN)

Run the following script to create an SPN with Contributor role:

```bash
chmod +x create-spn.sh
./create-spn.sh

Important: Save the output credentials securely. You'll need them for Azure DevOps service connections.

2. Create Azure DevOps Resources
A. Create Agent Pool
Go to your Azure DevOps organization

Navigate to Project Settings > Agent Pools

Click Add pool

Set:

Pool type: Self-hosted

Name: client-pool

Auto-provision: Unchecked

B. Create Personal Access Token (PAT)
Go to User Settings > Personal Access Tokens

Click New Token

Set:

Name: DevOps-Agents-PAT

Organization: All accessible organizations

Scopes: Agent Pools (Read & manage)

Expiration: Set appropriate duration

Save the token securely - you'll need it for VM configuration

3. Configure Infrastructure
