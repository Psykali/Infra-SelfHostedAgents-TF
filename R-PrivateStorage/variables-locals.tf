# =============================================
# VARIABLES AND LOCALS - STORAGE ACCOUNT
# =============================================

variable "client_name" {
  description = "Client Acronyme miniscule 2-4 letters (MUST match agents deployment)"
  type        = string
  default     = "demo"  # MUST BE SAME AS IN AGENTS DEPLOYMENT
}

variable "environment" {
  description = "Environment (dev, qal, prd)"
  type        = string
  default     = "prd"
}

variable "location" {
  description = "Azure region"
  default     = "francecentral"
}

variable "location_code" {
  description = "Location short code"
  default     = "frc"
}

# ============= LOCAL VALUES =============
locals {
  # Base naming components
  sequence_number = "01"
  workload_name   = "ado" # Client Acronyme miniscule 2-4 letters (MUST match agents deployment)
  storage_suffix  = "tfstate"
  
  # Resource Group Names
  storage_rg_name = "rg-${var.client_name}-${local.workload_name}-${local.storage_suffix}-${var.environment}-${var.location_code}-${local.sequence_number}"
  network_rg_name = "rg-${var.client_name}-${local.workload_name}-network-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Network references (from DevOps Agents deployment)
  vnet_name   = "vnet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  subnet_name = "snet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Storage Account (24 chars max, lowercase, no hyphens)
  storage_account_name = "st${var.client_name}${local.workload_name}${var.environment}${var.location_code}${local.sequence_number}"
  
  # Container
  container_name = "tfstate"
  
  # Private Endpoint - FIXED: removed custom NIC name
  private_endpoint_name = "pep-${local.storage_account_name}"
  
  # Common tags
  common_tags = {
    Client        = var.client_name
    Environment   = var.environment
    Project       = "DevOps Infrastructure"
    Component     = "storage"
    ManagedBy     = "Terraform"
    Persistent    = "true"
  }
}