# =============================================
# VARIABLES AND LOCALS - DEVOPS AGENTS
# =============================================

# ============= INPUT VARIABLES =============
variable "client_name" {
  description = "Client Acronyme between 2-4 miniscule letters (used in resource naming)"
  type        = string
  default     = "demo"  # CHANGE to actual client name
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

variable "agent_count" {
  description = "Number of DevOps agents to install"
  type        = number
  default     = 3
}

variable "agent_version" {
  description = "Azure DevOps agent version"
  type        = string
  default     = "4.261.0"
}

# ============= LOCAL VALUES =============
locals {
  # Base naming components
  sequence_number = "01"
  workload_name   = "ado"
  
  # Resource Group Names (MS Naming Convention)
  network_rg_name = "rg-${var.client_name}-${local.workload_name}-network-${var.environment}-${var.location_code}-${local.sequence_number}"
  agent_rg_name   = "rg-${var.client_name}-${local.workload_name}-agent-${var.environment}-${var.location_code}-${local.sequence_number}"
  tfstate_rg_name = "rg-${var.client_name}-${local.workload_name}-tfstate-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Network Resources
  vnet_name    = "vnet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  subnet_name  = "snet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  nsg_name     = "nsg-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # VM Resources
  vm_name      = "vm-${var.client_name}-${local.workload_name}-agent-${var.environment}-${var.location_code}-${local.sequence_number}"
  os_disk_name = "osdisk-${local.vm_name}"
  nic_name     = "nic-${local.vm_name}"
  pip_name     = "pip-${local.vm_name}"
  
  # Key Vault - 
  kv_name = "kv1-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Storage Account (for Terraform state) 
  storage_name = "st${replace(var.client_name, "-", "")}${local.workload_name}${substr(var.environment, 0, 3)}${var.location_code}${local.sequence_number}"
  
  # Private Endpoints 
  kv_pep_name   = "pep-${local.kv_name}"
  kv_pep_nic_name = "nic-${local.kv_name}"
  
  # Agent Pool Name
  agent_pool_name = "${var.client_name}-ubuntu-agents-${local.sequence_number}"
  
  # Common Tags
  common_tags = {
    Client        = var.client_name
    Environment   = var.environment
    Project       = "DevOps Infrastructure"
    ManagedBy     = "Terraform"
    CreationDate  = formatdate("YYYY-MM-DD", timestamp())
  }
}