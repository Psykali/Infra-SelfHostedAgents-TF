### ----------------------
### Public IP "PIP"
### ----------------------
resource "azurerm_public_ip" "main" {
  name                = local.pip_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Dynamic"

  tags = merge(local.common_tags, {
    Description = "Public IP for DevOps agent VM"
    Component   = "networking"
    Ephemeral   = "true"  # Dynamic IPs can change
  })
}