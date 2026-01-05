### ------------------------------------------------
### Dedicated subnet for private endpoints (no DNS)
### ------------------------------------------------
resource "azurerm_subnet" "private_endpoint" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = local.networking_rg_name
  virtual_network_name = local.vnet_name
  address_prefixes     = ["10.0.0.32/27"]

  service_endpoints = ["Microsoft.Storage"]
  
  # Allow private-endpoint policies to be applied
  private_endpoint_network_policies = "Enabled"
}
