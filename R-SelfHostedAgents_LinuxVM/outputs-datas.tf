# =============================================
# DATA SOURCES AND OUTPUTS - DEVOPS AGENTS
# =============================================
# Purpose: Reference data and output deployment information
data "azurerm_client_config" "current" {}


# Get VM public IP
data "azurerm_public_ip" "vm_ip" {
  name                = azurerm_public_ip.main.name
  resource_group_name = azurerm_resource_group.vm_rg.name
  depends_on = [azurerm_linux_virtual_machine.main]
}

### ---------
### Outputs
### ---------
output "vm_public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "vm_resource_group_name" {
  value = azurerm_resource_group.vm_rg.name
}

output "networking_resource_group_name" {  
  value = azurerm_resource_group.network_rg.name
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "subnet_id" {
  value = azurerm_subnet.main.id
}

output "network_rg_name" {
  value = azurerm_resource_group.network_rg.name
}