output "ubuntu_vm_public_ip" {
  description = "Public IP address of the Ubuntu DevOps agent VM"
  value       = azurerm_public_ip.ubuntu_vm.ip_address
}

output "ubuntu_vm_private_ip" {
  description = "Private IP address of the Ubuntu DevOps agent VM"
  value       = azurerm_network_interface.ubuntu_vm.private_ip_address
}

output "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_account_id" {
  description = "ID of the storage account for Terraform state"
  value       = azurerm_storage_account.tfstate.id
}

output "private_endpoint_ip" {
  description = "Private IP address of the storage account private endpoint"
  value       = azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address
}

output "devops_agent_name" {
  description = "Name of the DevOps agent"
  value       = var.ubuntu_agent_name
}

output "resource_group_names" {
  description = "Names of all created resource groups"
  value = {
    hub_networking    = azurerm_resource_group.hub_networking.name
    spoke_networking  = azurerm_resource_group.spoke_networking.name
    vm_compute        = azurerm_resource_group.vm.name
    storage           = azurerm_resource_group.storage.name
    monitoring        = azurerm_resource_group.monitoring.name
  }
}

output "connection_instructions" {
  description = "Instructions to connect to the VM and use the storage account"
  value = <<EOT

Connection Instructions:
=======================

Ubuntu VM (SSH):
  ssh ${var.admin_username}@${azurerm_public_ip.ubuntu_vm.ip_address}

Storage Account:
  Name: ${azurerm_storage_account.tfstate.name}
  Private Endpoint IP: ${azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address}
  Container: tfstate

DevOps Agent:
  Name: ${var.ubuntu_agent_name}

Terraform Backend Configuration:
  After initial deployment, update backend.tf with:
    resource_group_name  = "${azurerm_resource_group.storage.name}"
    storage_account_name = "${azurerm_storage_account.tfstate.name}"
    container_name       = "tfstate"
    key                  = "devops-agent.terraform.tfstate"

Then run: terraform init -migrate-state

EOT
}

output "network_security_information" {
  description = "Network security configuration details"
  value = <<EOT

Network Security:
================

Storage Account Access:
  - Public network access: DISABLED
  - Access allowed only via: Private Endpoint and VNet subnets
  - Private endpoint in subnet: ${azurerm_subnet.private_endpoints.name}
  - VM can access storage via private network

VNet Configuration:
  - Hub VNet: ${azurerm_virtual_network.hub.address_space[0]}
  - Spoke VNet: ${azurerm_virtual_network.spoke.address_space[0]}
  - VM Subnet: ${azurerm_subnet.vm.address_prefixes[0]}
  - Private Endpoint Subnet: ${azurerm_subnet.private_endpoints.address_prefixes[0]}

EOT
}