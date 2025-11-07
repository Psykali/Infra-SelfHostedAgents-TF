#!/bin/bash

# This script runs the DevOps agent setup via local-exec
set -e

VM_IP="$1"
ADMIN_USERNAME="$2"
ADMIN_PASSWORD="$3"
DEVOPS_ORG="$4"
DEVOPS_PAT="$5"
AGENT_POOL="$6"
AGENT_NAME="$7"

# Copy setup script to VM
echo "Copying setup script to VM..."
sshpass -p "$ADMIN_PASSWORD" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ./scripts/setup_devops_agent.sh $ADMIN_USERNAME@$VM_IP:/tmp/

# Make script executable and run it
echo "Running setup script on VM..."
sshpass -p "$ADMIN_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $ADMIN_USERNAME@$VM_IP "
sudo chmod +x /tmp/setup_devops_agent.sh
sudo /tmp/setup_devops_agent.sh '$DEVOPS_ORG' '$DEVOPS_PAT' '$AGENT_POOL' '$AGENT_NAME'
"

echo "DevOps agent setup completed successfully!"