### ---------------------------------------------------------
### Data sources to reference existing networking resources
### ---------------------------------------------------------
### Variables for the data 
### ----------------------
variable "customer" {
  description = "Customer short-code (2-5 lower-case letters/numbers)"
  type        = string
  default     = "test"   # <-- change only this line
}
locals {
  base = "ado-agents"               # fixed part describing the workload

  # resource-group names
  networking_rg_name= "rg-networking-${var.customer}-${local.base}"
  # network objects
  vnet_name   = "vnet-${var.customer}-${local.base}"
  subnet_name = "snet-${var.customer}-${local.base}"


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