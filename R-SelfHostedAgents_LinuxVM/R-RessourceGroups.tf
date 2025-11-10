resource "azurerm_resource_group" "vm_rg" {
  name     = var.vm_rg_name
  location = var.location

  tags = merge(local.common_tags, {
    Description = "Resource group for DevOps agent VMs"
    Component   = "compute"
  })
}

resource "azurerm_resource_group" "network_rg" {
  name     = var.networking_rg_name
  location = var.location

  tags = merge(local.common_tags, {
    Description = "Resource group for networking resources"
    Component   = "networking"
  })
}