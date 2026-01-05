# =============================================
# NETWORK SECURITY GROUP - DEVOPS AGENTS
# =============================================
# Purpose: Define security rules and assign NSG to subnet
# Usage: Controls inbound/outbound traffic at subnet level

resource "azurerm_network_security_group" "main" {
  name                = local.nsg_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  
  # SSH access for initial setup (restrict source in production)
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"  # RESTRICT TO SPECIFIC IP IN PRODUCTION
    destination_address_prefix = "*"
  }
  
  # Allow outbound to Azure DevOps (FIXED: Added source address)
  security_rule {
    name                       = "AllowAzureDevOpsOutbound"
    priority                   = 1002
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"  # ADDED THIS - source is VM subnet
    destination_address_prefix = "AzureDevOps"
  }
  
  # Allow outbound to Azure Storage for Terraform backend
  security_rule {
    name                       = "AllowStorageOutbound"
    priority                   = 1003
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"  # ADDED THIS
    destination_address_prefix = "Storage"
  }
  
  # Allow outbound DNS (required for package updates)
  security_rule {
    name                       = "AllowDNSOutbound"
    priority                   = 1004
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"  # ADDED THIS
    destination_address_prefix = "*"
  }
  
  # Allow outbound HTTP/HTTPS for package updates
  security_rule {
    name                       = "AllowHTTPOutbound"
    priority                   = 1005
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"  # ADDED THIS
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "AllowHTTPSOutbound"
    priority                   = 1006
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"  # ADDED THIS
    destination_address_prefix = "*"
  }
  
  tags = merge(local.common_tags, {
    Component   = "security"
    Description = "Network Security Group for DevOps agents subnet"
  })
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}