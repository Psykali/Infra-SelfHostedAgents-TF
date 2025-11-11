#!/bin/bash
set -e

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
# FUNCTIONS
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
    local agent_name="$AGENT_VERSION-adoagent-$agent_num"

    echo "=== Setting up Agent $agent_num ==="

    # Create agent directory
    mkdir -p "$agent_dir"
    echo "✓ Created directory: $agent_dir"

    # Extract agent files if not already present
    if [ ! -f "$agent_dir/config.sh" ]; then
        echo "Extracting agent files..."
        tar -zxf "/tmp/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz" -C "$agent_dir"
        chmod +x "$agent_dir"/*.sh
        echo "✓ Agent files extracted"
    fi

    cd "$agent_dir"

    # Remove existing configuration if present
    if [ -f ".agent" ]; then
        echo "Removing existing configuration..."
        ./config.sh remove --unattended --auth pat --token "$PAT_TOKEN" > /dev/null 2>&1 || true
        sleep 1
    fi

    # Configure agent
    echo "Configuring agent..."
    if ./config.sh --unattended \
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

    sudo tee "$service_file" > /dev/null << EOF
[Unit]
Description=Azure DevOps Agent $agent_num
After=network.target
Wants=network.target

[Service]
Type=simple
User=$SERVICE_USER
WorkingDirectory=$agent_dir
ExecStart=$agent_dir/runsvc.sh
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

    sudo systemctl daemon-reload
    sudo systemctl enable "$service_name" > /dev/null 2>&1
    echo "✓ Systemd service created and enabled: $service_name"
}

start_agent_service() {
    local agent_num=$1
    local service_name="$SERVICE_PREFIX-$agent_num"  

    if sudo systemctl start "$service_name"; then
        echo "✓ Started service: $service_name"
    else
        echo "✗ Failed to start service: $service_name"
        sudo systemctl status "$service_name" --no-pager -l | tail -3
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

# =============================================
# MAIN EXECUTION
# =============================================

echo "Starting Azure DevOps Agents Setup"
echo "============================================="

# Create base directory
sudo mkdir -p "$AGENTS_BASE_DIR"
sudo chown "$SERVICE_USER:$SERVICE_USER" "$AGENTS_BASE_DIR"

# Download agent package
download_agent_package

# Setup each agent
successful_agents=0
for i in $(seq 1 $AGENT_COUNT); do
    if setup_agent $i; then
        ((successful_agents++))
        create_systemd_service $i
    fi
    echo
done

# Start all services
echo "Starting all agent services..."
for i in $(seq 1 $AGENT_COUNT); do
    start_agent_service $i
done

# Show final status
show_status

echo "============================================="
echo "SETUP COMPLETED: $successful_agents/$AGENT_COUNT agents configured"
echo "Agents are installed in: $AGENTS_BASE_DIR"
echo "Systemd services: $SERVICE_PREFIX-1 through $SERVICE_PREFIX-$AGENT_COUNT"
echo "Check status: systemctl status $SERVICE_PREFIX-*"
echo "View logs: journalctl -u $SERVICE_PREFIX-1 -f"
echo "============================================="