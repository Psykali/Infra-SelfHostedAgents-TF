output "vm_public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "vm_resource_group_name" {
  value = azurerm_resource_group.vm_rg.name
}

output "networking_resource_group_name" {  
  value = azurerm_resource_group.network_rg.name
}