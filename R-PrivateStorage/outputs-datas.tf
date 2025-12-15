### ---------------------------------------------------------
### Data sources to reference existing networking resources
### ---------------------------------------------------------

data "azurerm_virtual_network" "main" {
  name                = "client-devops-agent-vnet"  # Use actual VNet name from stage 1
  resource_group_name = "client-devops-agents-network-rg" 
}

data "azurerm_subnet" "main" {
  name                 = "client-devops-agent-subnet"  # Use actual subnet name from stage 1
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = "client-devops-agents-network-rg" 
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