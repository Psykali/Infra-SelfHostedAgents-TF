# =============================================
# NETWORK INTERFACE (IN AGENT RG AS RECOMMENDED)
# =============================================
# Purpose: Creates network interface for VM in the agent RG
# Following recommendation #1: NIC in VM RG instead of network RG

resource "azurerm_network_interface" "main" {
  name                = local.nic_name
  location            = azurerm_resource_group.agent_rg.location
  resource_group_name = azurerm_resource_group.agent_rg.name  # In agent RG

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id  # Optional, remove for private only
  }

  tags = merge(local.common_tags, {
    Component   = "networking"
    Description = "Network interface for DevOps agent VM"
    AssociatedVM = local.vm_name
  })
}