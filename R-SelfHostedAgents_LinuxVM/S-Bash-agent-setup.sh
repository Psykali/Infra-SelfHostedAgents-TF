#!/bin/bash
# =============================================
# AZURE DEVOPS AGENTS SETUP WITH KEY VAULT
# =============================================
# Purpose: Install and configure Azure DevOps agents with Key Vault integration
# Usage: Retrieves PAT and configuration from Azure Key Vault using Managed Identity
# Note: Requires VM to have system-assigned identity with Key Vault access

# =============================================
# CONFIGURATION FUNCTIONS
# =============================================

# Load environment variables if agent-env.sh exists
if [ -f "/home/${ADMIN_USERNAME:-devopsadmin}/agent-env.sh" ]; then
    echo "Loading environment variables from agent-env.sh"
    . "/home/${ADMIN_USERNAME:-devopsadmin}/agent-env.sh"
fi

# Set default values if not provided
CLIENT_NAME="${CLIENT_NAME:-demo}"
ADMIN_USERNAME="${ADMIN_USERNAME:-devopsadmin}"
SERVICE_USER="${SERVICE_USER:-$ADMIN_USERNAME}"
AGENT_COUNT="${AGENT_COUNT:-5}"
AGENT_VERSION="${AGENT_VERSION:-4.261.0}"
AGENTS_BASE_DIR="${AGENTS_BASE_DIR:-/opt/azure-devops-agents}"
AGENT_DIR_PREFIX="${AGENT_DIR_PREFIX:-$CLIENT_NAME-adoagent}"
SERVICE_PREFIX="${SERVICE_PREFIX:-$CLIENT_NAME-adoagent}"

# =============================================
# KEY VAULT INTEGRATION FUNCTIONS
# =============================================

# Authenticate with Managed Identity
authenticate_with_identity() {
    echo "Authenticating with system-assigned identity..."
    if az login --identity --allow-no-subscriptions > /dev/null 2>&1; then
        echo "✓ Authenticated with Managed Identity"
        return 0
    else
        echo "✗ Failed to authenticate with Managed Identity"
        return 1
    fi
}

# Get secret from Key Vault
get_keyvault_secret() {
    local secret_name="$1"
    
    if [ -z "$KEY_VAULT_NAME" ]; then
        echo "ERROR: KEY_VAULT_NAME not set" >&2
        return 1
    fi
    
    # Get secret without extra output
    az keyvault secret show \
        --vault-name "$KEY_VAULT_NAME" \
        --name "$secret_name" \
        --query "value" -o tsv 2>/dev/null
}

# Get agent configuration from Key Vault
load_agent_configuration() {
    echo "Loading agent configuration from Key Vault..."
    
    # Get configuration JSON
    local config_json=$(get_keyvault_secret "agent-configuration")
    
    if [ -n "$config_json" ]; then
        # Parse configuration
        AZURE_DEVOPS_URL=$(echo "$config_json" | jq -r '.organization_url // empty')
        POOL_NAME=$(echo "$config_json" | jq -r '.agent_pool_name // empty')
        AGENT_COUNT=$(echo "$config_json" | jq -r '.agent_count // 5')
        AGENT_VERSION=$(echo "$config_json" | jq -r '.agent_version // "4.261.0"')
        CLIENT_NAME=$(echo "$config_json" | jq -r '.client_name // "demo"')
        
        echo "✓ Configuration loaded:"
        echo "  Organization: $AZURE_DEVOPS_URL"
        echo "  Pool: $POOL_NAME"
        echo "  Agents: $AGENT_COUNT"
        echo "  Version: $AGENT_VERSION"
        return 0
    else
        echo "⚠️  Using default configuration (no Key Vault config found)"
        
        # Set defaults
        AZURE_DEVOPS_URL="https://dev.azure.com/bseforgedevops"
        POOL_NAME="$CLIENT_NAME-ubuntu-agents-001"
        return 1
    fi
}

# Get PAT from Key Vault
load_pat_token() {
    echo "Loading PAT token from Key Vault..."
    
    local pat_token=$(get_keyvault_secret "azure-devops-pat")
    
    if [ -n "$pat_token" ]; then
        PAT_TOKEN="$pat_token"
        echo "✓ PAT token loaded from Key Vault"
        return 0
    else
        echo "✗ No PAT token found in Key Vault"
        echo "ERROR: Cannot proceed without PAT token"
        return 1
    fi
}

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
    echo "Installing required tools..."
    
    local tools=("curl" "wget" "unzip" "jq")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "Installing $tool..."
            sudo DEBIAN_FRONTEND=noninteractive apt install "$tool" -y
            echo "✓ $tool installed"
        else
            echo "✓ $tool already installed"
        fi
    done
}

install_azure_cli() {
    echo "Checking Azure CLI installation..."
    
    if command -v az &> /dev/null; then
        echo "✓ Azure CLI already installed"
        az --version | head -1
        return 0
    fi
    
    echo "Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    
    if command -v az &> /dev/null; then
        echo "✓ Azure CLI installed successfully"
        az --version | head -1
        return 0
    else
        echo "✗ Azure CLI installation failed"
        return 1
    fi
}

setup_system() {
    echo "============================================="
    echo "SYSTEM SETUP"
    echo "============================================="
    
    update_system_packages
    upgrade_system_packages
    install_required_tools
    install_azure_cli
    
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
    local package_file="vsts-agent-linux-x64-$AGENT_VERSION.tar.gz"
    local download_url="https://download.agent.dev.azure.com/agent/$AGENT_VERSION/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz"
    
    if [ ! -f "$package_file" ]; then
        echo "Downloading from $download_url..."
        wget -q "$download_url"
        
        if [ $? -eq 0 ] && [ -f "$package_file" ]; then
            echo "✓ Agent package downloaded"
        else
            echo "✗ Failed to download agent package"
            return 1
        fi
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

    # Extract agent files
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
        sleep 2
    fi

    # Configure agent
    echo "Configuring agent '$agent_name' in pool '$POOL_NAME'..."
    
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

    if [ ! -f "$agent_dir/run.sh" ]; then
        echo "⚠️  Skipping service creation: run.sh not found in $agent_dir"
        return 1
    fi

    echo "Creating systemd service: $service_name"

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
Environment=PAT_TOKEN=$PAT_TOKEN

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

    sudo mv /tmp/"$service_name.service" "$service_file"
    sudo systemctl daemon-reload
    sudo systemctl enable "$service_name"
    echo "✓ Systemd service created: $service_name"
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
        sudo systemctl status "$service_name" --no-pager -l | tail -5
        return 1
    fi
}

# =============================================
# MAIN EXECUTION
# =============================================

main() {
    echo "============================================="
    echo "AZURE DEVOPS AGENTS SETUP WITH KEY VAULT"
    echo "============================================="
    echo "Client: $CLIENT_NAME"
    echo "User: $ADMIN_USERNAME"
    echo "Date: $(date)"
    echo "============================================="
    
    # Step 1: Authenticate and load configuration from Key Vault
    if authenticate_with_identity; then
        load_agent_configuration
        if ! load_pat_token; then
            echo "ERROR: Cannot proceed without PAT token"
            exit 1
        fi
    else
        echo "ERROR: Authentication failed"
        exit 1
    fi
    
    # Step 2: System setup
    setup_system
    
    # Step 3: Create base directory
    sudo mkdir -p "$AGENTS_BASE_DIR"
    sudo chown "$SERVICE_USER:$SERVICE_USER" "$AGENTS_BASE_DIR"
    
    # Step 4: Download agent package
    if ! download_agent_package; then
        echo "ERROR: Failed to download agent package"
        exit 1
    fi
    
    # Step 5: Setup agents
    echo "Setting up $AGENT_COUNT agents..."
    local successful_agents=0
    
    for i in $(seq 1 $AGENT_COUNT); do
        echo "--- Processing Agent $i/$AGENT_COUNT ---"
        
        if setup_agent $i; then
            ((successful_agents++))
            
            if create_systemd_service $i; then
                if start_agent_service $i; then
                    echo "✓ Agent $i fully configured and running"
                else
                    echo "⚠️  Agent $i configured but failed to start"
                fi
            else
                echo "⚠️  Agent $i configured but service creation failed"
            fi
        else
            echo "✗ Agent $i setup failed"
        fi
        echo
    done
    
    # Step 6: Show final status
    echo "============================================="
    echo "SETUP COMPLETED"
    echo "============================================="
    echo "Successfully configured: $successful_agents/$AGENT_COUNT agents"
    echo "Agent directory: $AGENTS_BASE_DIR"
    echo "Agent pool: $POOL_NAME"
    echo "Organization: $AZURE_DEVOPS_URL"
    echo ""
    echo "Service commands:"
    echo "  Check status: systemctl status $SERVICE_PREFIX-*"
    echo "  View logs: journalctl -u $SERVICE_PREFIX-1 -f"
    echo "  List agents: ls $AGENTS_BASE_DIR/"
    echo "============================================="
    
    # Verify at least one agent is running
    if [ $successful_agents -eq 0 ]; then
        echo "WARNING: No agents were successfully configured!"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    "--help"|"-h")
        echo "Usage: $0 [--use-keyvault]"
        echo "  --use-keyvault: Retrieve secrets from Azure Key Vault (default)"
        exit 0
        ;;
    *)
        # Run main function
        main
        ;;
esac