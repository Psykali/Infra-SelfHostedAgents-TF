# =============================================
# SUBNET - Private Endpoint
# =============================================
# Purpose: Create subnet for private endpoint
# Usage: Provides network isolation and connectivity for agents to the private storage account

resource "azurerm_subnet" "private_endpoint" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = local.networking_rg_name
  virtual_network_name = local.vnet_name
  address_prefixes     = ["10.0.0.32/27"]

  private_endpoint_network_policies = "Enabled"
  service_endpoints                 = ["Microsoft.Storage"]

  network_security_group_id = data.azurerm_network_security_group.agents_nsg.id 
}