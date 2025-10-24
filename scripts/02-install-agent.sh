#!/bin/bash
set -e

# Configuration
AGENT_VERSION="3.227.2"
AGENT_COUNT=${1:-10}
AGENTS_BASE_DIR="/opt/azure-devops-agents"
AGENT_DIR_PREFIX="agent"

echo "=== Installing $AGENT_COUNT Azure DevOps Agents ==="

cd $AGENTS_BASE_DIR

# Download agent
if [ ! -f "vsts-agent-linux-x64-$AGENT_VERSION.tar.gz" ]; then
    echo "Downloading Azure DevOps agent v$AGENT_VERSION..."
    wget -q https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz
fi

# Create agent directories and extract
for i in $(seq 1 $AGENT_COUNT); do
    AGENT_DIR="$AGENTS_BASE_DIR/$AGENT_DIR_PREFIX-$i"
    
    echo "Setting up agent $i..."
    
    # Create directory
    mkdir -p $AGENT_DIR
    
    # Extract agent files
    tar -zxvf vsts-agent-linux-x64-$AGENT_VERSION.tar.gz -C $AGENT_DIR
    
    # Set permissions
    chmod +x $AGENT_DIR/*.sh
    
    echo "✓ Agent $i files extracted"
done

echo "✓ All agents installed successfully"