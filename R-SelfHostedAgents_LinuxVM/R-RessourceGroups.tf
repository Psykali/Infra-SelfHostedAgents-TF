# =============================================
# RESOURCE GROUPS - DEVOPS AGENTS
# =============================================
# Purpose: Create resource groups for networking and compute resources
# Usage: Separates resources by function - network RG and agent RG

# =============================================
# Network Resource Group (VNET, NSG, Subnet)
# =============================================
resource "azurerm_resource_group" "network_rg" {
  name     = local.network_rg_name
  location = var.location
  
  tags = merge(local.common_tags, {
    Component   = "networking"
    Description = "Resource group for networking resources"
  })
}

# =============================================
# Agent Resource Group (VM, Key Vault, NIC)
# =============================================
resource "azurerm_resource_group" "agent" {
  name     = local.agent_rg_name
  location = var.location
  
  tags = merge(local.common_tags, {
    Component   = "compute"
    Description = "Resource group for VM and Key Vault"
  })
}