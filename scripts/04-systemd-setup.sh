#!/bin/bash
set -e

# Configuration
AGENT_COUNT=${1:-10}
AGENTS_BASE_DIR="/opt/azure-devops-agents"
AGENT_DIR_PREFIX="agent"
SERVICE_PREFIX="azdevops-agent"
SERVICE_USER=$(whoami)

echo "=== Setting up Systemd Services for $AGENT_COUNT Agents ==="

# Create runsvc.sh for all agents
for i in $(seq 1 $AGENT_COUNT); do
    AGENT_DIR="$AGENTS_BASE_DIR/$AGENT_DIR_PREFIX-$i"
    
    # Create runsvc.sh if it doesn't exist
    if [ ! -f "$AGENT_DIR/runsvc.sh" ]; then
        cat > "$AGENT_DIR/runsvc.sh" << 'EOF'
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. ${DIR}/env.sh
${DIR}/bin/Agent.Listener run --startuptype service
EOF
        chmod +x "$AGENT_DIR/runsvc.sh"
    fi
done

# Stop any running agents
echo "Stopping any running agents..."
pkill -f "Agent.Listener" || true
sleep 3

# Create systemd services
for i in $(seq 1 $AGENT_COUNT); do
    AGENT_DIR="$AGENTS_BASE_DIR/$AGENT_DIR_PREFIX-$i"
    SERVICE_NAME="$SERVICE_PREFIX-$i"
    
    echo "Creating service: $SERVICE_NAME"
    
    # Create systemd service file
    sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null << SERVICE_EOF
[Unit]
Description=Azure DevOps Agent $i
After=network.target

[Service]
Type=simple
User=$SERVICE_USER
WorkingDirectory=$AGENT_DIR
ExecStart=$AGENT_DIR/runsvc.sh
Restart=always
RestartSec=10
Environment=AGENT_ALLOW_RUNASROOT=1

[Install]
WantedBy=multi-user.target
SERVICE_EOF

    # Enable and start service
    sudo systemctl enable $SERVICE_NAME
    sudo systemctl start $SERVICE_NAME
    
    echo "✓ Service $SERVICE_NAME created and started"
done

# Reload systemd
sudo systemctl daemon-reload

echo "=== Final Status ==="
for i in $(seq 1 $AGENT_COUNT); do
    SERVICE_NAME="$SERVICE_PREFIX-$i"
    if systemctl is-active $SERVICE_NAME >/dev/null 2>&1; then
        echo "✓ $SERVICE_NAME: ACTIVE"
    else
        echo "✗ $SERVICE_NAME: INACTIVE"
        sudo systemctl status $SERVICE_NAME --no-pager -l | tail -5
    fi
done

echo "✓ Systemd setup completed"