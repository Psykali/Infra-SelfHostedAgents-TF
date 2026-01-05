# =============================================
# PUBLIC IP ADDRESS - DEVOPS AGENTS
# =============================================
# Purpose: Create public IP for VM SSH access
# Usage: Provides temporary public access for initial setup

resource "azurerm_public_ip" "main" {
  name                = local.pip_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  
  tags = merge(local.common_tags, {
    Component   = "networking"
    Description = "Public IP for DevOps agent VM (temporary)"
    Ephemeral   = "true"
  })
}