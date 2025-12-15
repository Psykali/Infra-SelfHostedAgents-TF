### ----------------------
### Infra Resource Group
### ----------------------
resource "azurerm_resource_group" "vm_rg" {
  name     = local.vm_rg_name
  location = var.location

  tags = merge(local.common_tags, {
    Description = "Resource group for DevOps agent VMs"
    Component   = "compute"
  })
}

### --------------------------
### Networking Resource Group
### ---------------------------
resource "azurerm_resource_group" "network_rg" {
  name     = local.networking_rg_name
  location = var.location

  tags = merge(local.common_tags, {
    Description = "Resource group for networking resources"
    Component   = "networking"
  })
}