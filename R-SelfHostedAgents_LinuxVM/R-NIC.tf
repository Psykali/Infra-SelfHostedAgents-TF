# =============================================
# NETWORK INTERFACE - DEVOPS AGENTS
# =============================================
# Purpose: Create network interface for VM
# Usage: Connects VM to subnet with public IP

resource "azurerm_network_interface" "main" {
  name                = local.nic_name
  location            = azurerm_resource_group.agent.location
  resource_group_name = azurerm_resource_group.agent.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
  
  tags = merge(local.common_tags, {
    Component   = "networking"
    Description = "Network interface for DevOps agent VM"
    AssociatedVM = local.vm_name
  })
}