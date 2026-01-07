# =============================================
# NETWORK CONNECTION CONFIGURATION
# =============================================
# Purpose: Configure network connectivity between agents VM and storage
# Usage: Sets up route table and ensures agents subnet can reach storage

# Get VM NIC information for reference
data "azurerm_network_interface" "agent_vm_nic" {
  name                = "nic-vm-${var.client_name}-${local.workload_name}-agent-${var.environment}-${var.location_code}-${local.sequence_number}"
  resource_group_name = "rg-${var.client_name}-${local.workload_name}-agent-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  depends_on = [
    data.azurerm_virtual_network.main
  ]
}

# Optional: Route table for better control
resource "azurerm_route_table" "storage_routes" {
  name                = "rt-${var.client_name}-${local.workload_name}-storage-${var.environment}-${var.location_code}-${local.sequence_number}"
  location            = var.location
  resource_group_name = local.networking_rg_name
  
  route {
    name                   = "to-storage-private-endpoint"
    address_prefix         = "${azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address}/32"
    next_hop_type          = "VnetLocal"
  }

  tags = merge(local.common_tags, {
    Description = "Route table for storage private endpoint connectivity"
  })
}

# Associate route table with agents subnet
resource "azurerm_subnet_route_table_association" "agents_to_storage" {
  subnet_id      = data.azurerm_subnet.agents.id
  route_table_id = azurerm_route_table.storage_routes.id
  
  depends_on = [
    azurerm_subnet.private_endpoint,
    azurerm_private_endpoint.storage,
  ]
}