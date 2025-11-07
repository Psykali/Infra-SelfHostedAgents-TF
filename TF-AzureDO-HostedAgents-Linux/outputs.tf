output "ubuntu_vms_public_ips" {
  description = "Public IP addresses of the Ubuntu DevOps agent VMs"
  value = {
    for i, ip in azurerm_public_ip.ubuntu_vms : "ubuntu-vm-${i + 1}" => ip.ip_address
  }
}

output "ubuntu_vms_private_ips" {
  description = "Private IP addresses of the Ubuntu DevOps agent VMs"
  value = {
    for i, nic in azurerm_network_interface.ubuntu_vms : "ubuntu-vm-${i + 1}" => nic.private_ip_address
  }
}

output "windows_vm_public_ip" {
  description = "Public IP address of the Windows DevOps agent VM"
  value       = azurerm_public_ip.windows_vm.ip_address
}

output "windows_vm_private_ip" {
  description = "Private IP address of the Windows DevOps agent VM"
  value       = azurerm_network_interface.windows_vm.private_ip_address
}

output "devops_agent_names" {
  description = "Names of all DevOps agents"
  value = {
    ubuntu_agents = var.ubuntu_agent_names
    windows_agent = var.windows_agent_name
  }
}

output "resource_group_names" {
  description = "Names of all created resource groups"
  value = {
    hub_networking    = azurerm_resource_group.hub_networking.name
    spoke_networking  = azurerm_resource_group.spoke_networking.name
    vm_compute        = azurerm_resource_group.vm.name
    monitoring        = azurerm_resource_group.monitoring.name
  }
}

output "connection_instructions" {
  description = "Instructions to connect to the VMs"
  value = <<EOT

Connection Instructions:
=======================

Ubuntu VMs (SSH):
  ssh ${var.admin_username}@${azurerm_public_ip.ubuntu_vms[0].ip_address}
  ssh ${var.admin_username}@${azurerm_public_ip.ubuntu_vms[1].ip_address}

Windows VM (RDP):
  Use RDP to connect to: ${azurerm_public_ip.windows_vm.ip_address}
  Username: ${var.admin_username}
  Password: [as provided in variables]

DevOps Agents:
  Ubuntu Agents: ${join(", ", var.ubuntu_agent_names)}
  Windows Agent: ${var.windows_agent_name}

EOT
}