# =============================================
# NETWORK SECURITY GROUP (ASSIGNED TO SUBNET)
# =============================================
# Purpose: Creates NSG with security rules and assigns it to subnet
# Following recommendation #5: NSG assigned to subnet instead of NIC

resource "azurerm_network_security_group" "main" {
  name                = local.nsg_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  # SSH access (temporary for setup, consider removing for production)
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"  # Restrict to specific IPs in production
    destination_address_prefix = "*"
  }

  # Allow outbound to Azure DevOps
  security_rule {
    name                       = "AllowAzureDevOpsOutbound"
    priority                   = 1002
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    destination_address_prefix = "AzureDevOps"
  }

  tags = merge(local.common_tags, {
    Component   = "security"
    Description = "Network Security Group for DevOps agent subnet"
    AssignedTo  = "subnet"
  })
}