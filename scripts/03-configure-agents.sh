#!/bin/bash
set -e

# Configuration (these should be passed as environment variables or parameters)
AZURE_DEVOPS_URL=${AZURE_DEVOPS_URL:-"https://dev.azure.com/your-organization"}
PAT_TOKEN=${PAT_TOKEN:-"your-pat-token"}
POOL_NAME=${POOL_NAME:-"your-pool-name"}
AGENT_COUNT=${AGENT_COUNT:-10}
AGENTS_BASE_DIR="/opt/azure-devops-agents"
AGENT_DIR_PREFIX="agent"

echo "=== Configuring $AGENT_COUNT Azure DevOps Agents ==="

cd $AGENTS_BASE_DIR

for i in $(seq 1 $AGENT_COUNT); do
    AGENT_DIR="$AGENTS_BASE_DIR/$AGENT_DIR_PREFIX-$i"
    
    echo "Configuring agent $i..."
    cd $AGENT_DIR
    
    # Remove existing configuration if present
    if [ -f ".agent" ]; then
        echo "Removing existing configuration..."
        ./config.sh remove --unattended --auth pat --token "$PAT_TOKEN" || true
    fi
    
    # Configure agent
    ./config.sh --unattended \
        --url "$AZURE_DEVOPS_URL" \
        --auth pat \
        --token "$PAT_TOKEN" \
        --pool "$POOL_NAME" \
        --agent "agent-$i-$(hostname)" \
        --work "_work$i" \
        --replace \
        --acceptTeeEula
    
    if [ $? -eq 0 ]; then
        echo "✓ Agent $i configured successfully"
    else
        echo "✗ Failed to configure agent $i"
        exit 1
    fi
done

echo "✓ All agents configured successfully"