#!/bin/bash
set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_COUNT=${1:-10}

echo "=== Starting Complete Azure DevOps Agent Deployment ==="
echo "Agent Count: $AGENT_COUNT"

# Run all scripts in sequence
echo "1. Installing prerequisites..."
$SCRIPT_DIR/01-prerequisites.sh

echo "2. Installing agents..."
$SCRIPT_DIR/02-install-agent.sh $AGENT_COUNT

echo "3. Configuring agents..."
# Set these environment variables before running
export AZURE_DEVOPS_URL="https://dev.azure.com/your-organization"
export PAT_TOKEN="your-pat-token-here"
export POOL_NAME="your-pool-name"
export AGENT_COUNT=$AGENT_COUNT

$SCRIPT_DIR/03-configure-agents.sh

echo "4. Setting up systemd services..."
$SCRIPT_DIR/04-systemd-setup.sh $AGENT_COUNT

echo "=== Deployment Completed Successfully ==="
echo "Agents should now be online in Azure DevOps"
echo "Check status: systemctl list-units | grep azdevops-agent"