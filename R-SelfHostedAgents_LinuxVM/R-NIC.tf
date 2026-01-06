# =============================================
# NETWORK INTERFACE - DEVOPS AGENTS
# =============================================
# Purpose: Create network interface for VM
# Usage: Connects VM to subnet with public IP

resource "azurerm_network_interface" "main" {
  name                = local.nic_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = merge(local.common_tags, {
    Description = "Network interface for DevOps agent VM"
    Component   = "networking"
  })
}