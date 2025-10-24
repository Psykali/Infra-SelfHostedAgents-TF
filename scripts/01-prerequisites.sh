#!/bin/bash
set -e

echo "=== Installing Prerequisites ==="

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    docker.io

# Add user to docker group
sudo usermod -aG docker $USER

# Create agent directory
sudo mkdir -p /opt/azure-devops-agents
sudo chown $USER:$USER /opt/azure-devops-agents

echo "✓ Prerequisites installed successfully"