# =============================================
# VARIABLES AND LOCALS - STORAGE ACCOUNT
# =============================================
# Purpose: Define input variables and local values for storage account
# Usage: Central configuration - must match client_name from agents deployment

# ============= INPUT VARIABLES =============
variable "client_name" {
  description = "Client Acronyme 2-4 minisule letters (MUST match agents deployment)"
  type        = string
  # Client Acronyme 2-4 minisule letters (MUST match agents deployment)
  default     = "demo"  # MUST BE SAME AS IN AGENTS DEPLOYMENT
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

# ============= LOCAL VALUES =============
locals {
  # Base naming components
  sequence_number = "01"
  # Client Acronyme 2-4 minisule letters (MUST match agents deployment)
  workload_name   = "ado" # MUST BE SAME AS IN AGENTS DEPLOYMENT
  storage_suffix  = "tfstate"
  
  # Resource Group Names (MS Naming Convention)
  storage_rg_name = "rg-${var.client_name}-${local.workload_name}-${local.storage_suffix}-${var.environment}-${var.location_code}-${local.sequence_number}"
  network_rg_name = "rg-${var.client_name}-${local.workload_name}-network-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Storage Account (24 chars max, lowercase, no hyphens)
  storage_account_name = "st${var.client_name}${local.workload_name}${var.environment}${var.location_code}${local.sequence_number}"
  
  # Container
  container_name = "tfstate"
  
  # Network references (from DevOps Agents deployment)
  vnet_name   = "vnet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  subnet_name = "snet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Private Endpoint
  private_endpoint_name = "pep-st${var.client_name}${local.workload_name}${var.environment}${var.location_code}${local.sequence_number}"
  private_endpoint_nic_name = "nic-pep-st${var.client_name}${local.workload_name}${var.environment}${var.location_code}${local.sequence_number}"
  
  # Common Tags
  common_tags = {
    Client        = var.client_name
    Environment   = var.environment
    Project       = "DevOps Infrastructure"
    Component     = "storage"
    ManagedBy     = "Terraform"
    Persistent    = "true"  # This storage should not be deleted
  }
}