### ---------------------------------------------------------
### Data sources to reference existing networking resources
### ---------------------------------------------------------
data "azurerm_virtual_network" "main" {
  name                = local.vnet_name 
  resource_group_name = local.networking_rg_name 
}

data "azurerm_subnet" "main" {
  name                 = local.subnet_name  
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_virtual_network.main.resource_group_name
}

### --------
### Outputs
### --------
output "storage_account_name" {
  value = azurerm_storage_account.private.name
}

output "storage_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "storage_account_id" {
  value = azurerm_storage_account.private.id
}