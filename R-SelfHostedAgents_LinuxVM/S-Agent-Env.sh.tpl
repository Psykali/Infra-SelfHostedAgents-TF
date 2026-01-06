#!/bin/bash
# =============================================
# ENVIRONMENT VARIABLES FOR DEVOPS AGENTS
# =============================================
# Purpose: Template file for agent setup environment variables
# Usage: Populated by Terraform with Key Vault and configuration details
# Note: This file is auto-generated - DO NOT MODIFY MANUALLY

# Key Vault Configuration
export KEY_VAULT_NAME="${key_vault_name}"
export VM_RESOURCE_GROUP="${vm_resource_group}"
export CLIENT_NAME="${client_name}"
export ADMIN_USERNAME="${admin_username}"

# Agent Configuration
export AGENT_COUNT="${agent_count}"
export AGENT_VERSION="${agent_version}"

# Service User (same as admin for simplicity)
export SERVICE_USER="${admin_username}"

# Directory Paths
export AGENTS_BASE_DIR="/opt/azure-devops-agents"
export AGENT_DIR_PREFIX="${client_name}-adoagent"
export SERVICE_PREFIX="${client_name}-adoagent"

# Log file
export SETUP_LOG="/home/${admin_username}/setup.log"