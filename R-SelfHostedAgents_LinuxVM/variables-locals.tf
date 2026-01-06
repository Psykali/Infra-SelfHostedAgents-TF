# =============================================
# VARIABLES AND LOCALS - DEVOPS AGENTS
# =============================================
# Purpose: Define input variables and local values for DevOps agents infrastructure
# Usage: Central configuration point - modify client_name and environment as needed

# ============= INPUT VARIABLES =============
variable "client_name" {
  description = "Client Acronyme between 2-4 miniscule letters (used in resource naming)"
  type        = string
  default     = "client"  ### CHANGE This With Client Acronyme between 2-4 miniscule letters (used in resource naming) 
}

variable "environment" {
  description = "Environment (dev, qal, prd)"
  type        = string
  default     = "prd"
}

variable "location" {
  description = "Azure region for deployment"
  default     = "francecentral"
}

variable "location_code" {
  description = "Short code for location in naming"
  default     = "frc"
}

variable "vm_size" {
  description = "VM size for DevOps agents"
  default     = "Standard_B2als_v2"
}

variable "admin_username" {
  description = "VM administrator username"
  default     = "devopsadmin"
  sensitive   = true
}

# ============= LOCAL VALUES =============
locals {
  # Base naming components
  sequence_number = "01"
  workload_name   = "devops" ### CHANGE This With Client Acronyme between 2-4 miniscule letters (used in resource naming) 
  
  # Resource Group Names (MS Naming Convention)
  network_rg_name = "rg-${var.client_name}-${local.workload_name}-network-${var.environment}-${var.location_code}-${local.sequence_number}"
  agent_rg_name   = "rg-${var.client_name}-${local.workload_name}-agent-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Network Resources
  vnet_name    = "vnet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  subnet_name  = "snet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  nsg_name     = "nsg-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # VM Resources
  vm_name      = "vm-${var.client_name}-${local.workload_name}-agent-${var.environment}-${var.location_code}-${local.sequence_number}"
  os_disk_name = "osdisk-${local.vm_name}"
  nic_name     = "nic-${local.vm_name}"
  pip_name     = "pip-${local.vm_name}"
  
  # Key Vault
  kv_name = "kv-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Common Tags
  common_tags = {
    Client        = var.client_name
    Environment   = var.environment
    Project       = "DevOps Infrastructure"
    ManagedBy     = "Terraform"
    CreationDate  = formatdate("YYYY-MM-DD", timestamp())
  }
}