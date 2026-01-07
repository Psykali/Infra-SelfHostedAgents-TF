# =============================================
# VARIABLES AND LOCALS - STORAGE ACCOUNT
# =============================================
# Purpose: Configuration for private storage account
# Usage: Must match the agents deployment values
# Reference: Uses same client_name, environment, location as agents

# ============= INPUT VARIABLES =============
variable "client_name" {
  description = "Client name (2-4 letters) - MUST match agents deployment"
  type        = string
  default     = "demo"  # Must be same as in AgentVM deployment
}

variable "environment" {
  description = "Environment (dev, qal, prd)"
  type        = string
  default     = "prd"   # Must be same as in AgentVM deployment
}

variable "location" {
  description = "Azure region"
  default     = "francecentral"
}

variable "location_code" {
  description = "Short location code"
  default     = "frc"
}

# ============= LOCAL VALUES =============
locals {
  # Naming components
  sequence = "01"
  workload = "ado"  # Must match AgentVM
  
  # Resource Groups
  storage_rg  = "rg-${var.client_name}-${local.workload}-tfstate-${var.environment}-${var.location_code}-${local.sequence}"
  network_rg  = "rg-${var.client_name}-${local.workload}-network-${var.environment}-${var.location_code}-${local.sequence}"
  
  # Storage Account (24 chars max, lowercase)
  storage_name = "st${var.client_name}${local.workload}${substr(var.environment, 0, 3)}${var.location_code}${local.sequence}"
  
  # Network (from existing AgentVM deployment)
  vnet_name   = "vnet-${var.client_name}-${local.workload}-${var.environment}-${var.location_code}-${local.sequence}"
  subnet_name = "snet-${var.client_name}-${local.workload}-${var.environment}-${var.location_code}-${local.sequence}"
  
  # Tags
  tags = {
    Project = "DevOps Agents"
    Client  = var.client_name
    Env     = var.environment
  }
}