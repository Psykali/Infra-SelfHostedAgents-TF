#!/bin/bash
# set -e
# =============================================
# CONFIGURATION VARIABLES
# =============================================
CLIENT_NAME="client"
AZURE_DEVOPS_URL="https://dev.azure.com/bseforgedevops"
PAT_TOKEN="BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J"
POOL_NAME="$CLIENT_NAME-hostedagents-ubuntu01"
AGENT_COUNT=5
AGENTS_BASE_DIR="/opt/azure-devops-agents"
AGENT_DIR_PREFIX="$CLIENT_NAME-adoagent"
AGENT_VERSION="4.261.0"
SERVICE_USER="devopsadmin"
SERVICE_PREFIX="$CLIENT_NAME-adoagent"

# =============================================
# SYSTEM SETUP FUNCTIONS
# =============================================

update_system_packages() {
    echo "Updating system packages..."
    sudo DEBIAN_FRONTEND=noninteractive apt update
    echo "✓ System packages updated"
}

upgrade_system_packages() {
    echo "Upgrading system packages..."
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
    echo "✓ System packages upgraded"
}

install_required_tools() {
    echo "Installing required tools: curl, wget, unzip..."
    
    # Check and install each tool if not present
    if ! command -v curl &> /dev/null; then
        echo "Installing curl..."
        sudo DEBIAN_FRONTEND=noninteractive apt install -y curl
        echo "✓ curl installed"
    else
        echo "✓ curl already installed"
    fi
    
    if ! command -v wget &> /dev/null; then
        echo "Installing wget..."
        sudo DEBIAN_FRONTEND=noninteractive apt install -y wget
        echo "✓ wget installed"
    else
        echo "✓ wget already installed"
    fi
    
    if ! command -v unzip &> /dev/null; then
        echo "Installing unzip..."
        sudo DEBIAN_FRONTEND=noninteractive apt install -y unzip
        echo "✓ unzip installed"
    else
        echo "✓ unzip already installed"
    fi
}

install_azure_cli() {
    echo "Checking Azure CLI installation..."
    
    if command -v az &> /dev/null; then
        echo "✓ Azure CLI already installed"
        az --version | head -1
        return 0
    fi
    
    echo "Installing Azure CLI..."
    
    # Method 1: Official Microsoft script
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    
    # Verify installation
    if command -v az &> /dev/null; then
        echo "✓ Azure CLI installed successfully"
        az --version | head -1
        return 0
    else
        echo "⚠️  Azure CLI installation may have failed, but continuing..."
        return 1
    fi
}

setup_system() {
    echo "============================================="
    echo "SYSTEM SETUP"
    echo "============================================="
    
    update_system_packages
    echo
    
    upgrade_system_packages
    echo
    
    install_required_tools
    echo
    
    install_azure_cli
    echo
    
    echo "✓ System setup completed"
    echo "============================================="
    echo
}

# =============================================
# AZURE DEVOPS AGENT FUNCTIONS
# =============================================

download_agent_package() {
    echo "Downloading Azure DevOps agent version $AGENT_VERSION..."
    cd /tmp
    if [ ! -f "vsts-agent-linux-x64-$AGENT_VERSION.tar.gz" ]; then
        wget -q "https://download.agent.dev.azure.com/agent/$AGENT_VERSION/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz"
        echo "✓ Agent package downloaded"
    else
        echo "✓ Agent package already exists"
    fi
}

setup_agent() {
    local agent_num=$1
    local agent_dir="$AGENTS_BASE_DIR/$AGENT_DIR_PREFIX-$agent_num"
    local agent_name="$SERVICE_PREFIX-$agent_num"

    echo "=== Setting up Agent $agent_num ==="

    # Create agent directory
    sudo mkdir -p "$agent_dir"
    sudo chown "$SERVICE_USER:$SERVICE_USER" "$agent_dir"
    echo "✓ Created directory: $agent_dir"

    # Extract agent files if not already present
    if [ ! -f "$agent_dir/config.sh" ]; then
        echo "Extracting agent files..."
        tar -zxf "/tmp/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz" -C "$agent_dir"
        sudo chown -R "$SERVICE_USER:$SERVICE_USER" "$agent_dir"
        sudo chmod +x "$agent_dir"/*.sh
        echo "✓ Agent files extracted"
    fi

    cd "$agent_dir"

    # Remove existing configuration if present
    if [ -f ".agent" ]; then
        echo "Removing existing configuration..."
        sudo -u "$SERVICE_USER" ./config.sh remove --unattended --auth pat --token "$PAT_TOKEN" > /dev/null 2>&1 || true
        sleep 1
    fi

    # Configure agent
    echo "Configuring agent..."
    if sudo -u "$SERVICE_USER" ./config.sh --unattended \
        --url "$AZURE_DEVOPS_URL" \
        --auth pat \
        --token "$PAT_TOKEN" \
        --pool "$POOL_NAME" \
        --agent "$agent_name" \
        --work "_work$agent_num" \
        --replace \
        --acceptTeeEula; then
        echo "✓ Agent $agent_num configured successfully"
        return 0
    else
        echo "✗ Failed to configure Agent $agent_num"
        return 1
    fi
}

create_systemd_service() {
    local agent_num=$1
    local agent_dir="$AGENTS_BASE_DIR/$AGENT_DIR_PREFIX-$agent_num"
    local service_name="$SERVICE_PREFIX-$agent_num"  
    local service_file="/etc/systemd/system/$service_name.service"

    # Check if agent directory exists and has required files
    if [ ! -f "$agent_dir/run.sh" ]; then
        echo "⚠️  Skipping service creation for agent $agent_num: run.sh not found"
        return 1
    fi

    echo "Creating systemd service: $service_name"

    # Create the service file in temp location first
    cat > /tmp/"$service_name.service" << EOF
[Unit]
Description=Azure DevOps Agent $agent_num
After=network.target
Wants=network.target

[Service]
Type=simple
User=$SERVICE_USER
WorkingDirectory=$agent_dir
ExecStart=$agent_dir/run.sh
Restart=always
RestartSec=10
StartLimitInterval=60
StartLimitBurst=5

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

    # Move with sudo
    sudo mv /tmp/"$service_name.service" "$service_file"
    sudo systemctl daemon-reload
    sudo systemctl enable "$service_name" > /dev/null 2>&1
    echo "✓ Systemd service created and enabled: $service_name"
    return 0
}

start_agent_service() {
    local agent_num=$1
    local service_name="$SERVICE_PREFIX-$agent_num"  

    if sudo systemctl start "$service_name"; then
        echo "✓ Started service: $service_name"
        return 0
    else
        echo "✗ Failed to start service: $service_name"
        sudo systemctl status "$service_name" --no-pager -l | tail -3
        return 1
    fi
}

show_status() {
    echo
    echo "============================================="
    echo "SETUP COMPLETED - STATUS SUMMARY"
    echo "============================================="
    
    for i in $(seq 1 $AGENT_COUNT); do
        local service_name="$SERVICE_PREFIX-$i"  
        local agent_dir="$AGENTS_BASE_DIR/$AGENT_DIR_PREFIX-$i"
        
        echo "Agent $i:"
        echo "  Directory: $agent_dir"
        
        if [ -f "/etc/systemd/system/$service_name.service" ]; then
            local status=$(systemctl is-active "$service_name" 2>/dev/null || echo "not-found")
            case "$status" in
                "active") echo "  Service: 🟢 RUNNING" ;;
                "failed") echo "  Service: 🔴 FAILED" ;;
                "inactive") echo "  Service: ⚪ STOPPED" ;;
                *) echo "  Service: ❓ UNKNOWN" ;;
            esac
        else
            echo "  Service: ⚠️  NOT CREATED"
        fi
        echo
    done
}

start_all_services() {
    echo "Starting agent services..."
    for i in $(seq 1 $AGENT_COUNT); do
        local service_name="$SERVICE_PREFIX-$i"
        if [ -f "/etc/systemd/system/$service_name.service" ]; then
            if start_agent_service $i; then
                echo "✓ Agent $i service started"
            else
                echo "⚠️  Failed to start service for agent $i"
            fi
        else
            echo "⚠️  No service file for agent $i - skipping start"
        fi
    done
}

# =============================================
# MAIN EXECUTION
# =============================================

echo "Starting Azure DevOps Agents Setup"
echo "============================================="

# System setup (updates, upgrades, and tool installation)
setup_system

# Create base directory
sudo mkdir -p "$AGENTS_BASE_DIR"
sudo chown "$SERVICE_USER:$SERVICE_USER" "$AGENTS_BASE_DIR"

# Download agent package
download_agent_package

# Setup each agent - CONTINUE EVEN IF SOME FAIL
successful_agents=0
for i in $(seq 1 $AGENT_COUNT); do
    echo "Processing Agent $i of $AGENT_COUNT..."
    if setup_agent $i; then
        ((successful_agents++))
        echo "✓ Agent $i configured"
        
        # Try to create service but don't fail the entire script
        if create_systemd_service $i; then
            echo "✓ Service created for agent $i"
        else
            echo "⚠️  Service creation failed for agent $i (but agent is configured)"
        fi
    else
        echo "✗ Agent $i setup failed"
    fi
    echo "---"
done

# Start all services that were created
start_all_services

# Show final status
show_status

echo "============================================="
echo "SETUP COMPLETED: $successful_agents/$AGENT_COUNT agents configured"
echo "Agents are installed in: $AGENTS_BASE_DIR"
echo "Systemd services: $SERVICE_PREFIX-1 through $SERVICE_PREFIX-$AGENT_COUNT"
echo "Check status: systemctl status $SERVICE_PREFIX-*"
echo "View logs: journalctl -u $SERVICE_PREFIX-1 -f"
echo "============================================="