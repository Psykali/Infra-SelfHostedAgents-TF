# =============================================
# VARIABLES AND LOCALS - STORAGE ACCOUNT
# =============================================
# Purpose: Configuration for private storage account
# Usage: Must match the agents deployment values exactly

variable "client_name" {
  description = "Client Acronyme 2-4 minisule letters (MUST match agents deployment)"
  type        = string
  default     = "demo"
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
  workload_name   = "ado"
  storage_suffix  = "tfstate"
  
  # Resource Group Names
  storage_rg_name = "rg-${var.client_name}-${local.workload_name}-${local.storage_suffix}-${var.environment}-${var.location_code}-${local.sequence_number}"
  networking_rg_name = "rg-${var.client_name}-${local.workload_name}-network-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Storage Account (24 chars max, lowercase, no hyphens)
  private_storage_name = "st${replace(var.client_name, "-", "")}${local.workload_name}${substr(var.environment, 0, 3)}${var.location_code}${local.sequence_number}"
  
  # Container
  tfstate_container_name = "tfstate"
  
  # Network references (from DevOps Agents deployment)
  vnet_name   = "vnet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  subnet_name = "snet-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Private Endpoint
  private_endpoint_subnet_name = "snet-${var.client_name}-${local.workload_name}-pep-${var.environment}-${var.location_code}-${local.sequence_number}"
  private_endpoint_name = "pep-st${replace(var.client_name, "-", "")}${local.workload_name}${substr(var.environment, 0, 3)}${var.location_code}${local.sequence_number}"
  private_endpoint_connection_name = "pepcon-st${replace(var.client_name, "-", "")}${local.workload_name}${substr(var.environment, 0, 3)}${var.location_code}${local.sequence_number}"
  
  # Common Tags
  common_tags = {
    Client        = var.client_name
    Environment   = var.environment
    Project       = "DevOps Infrastructure"
    Component     = "storage"
    ManagedBy     = "Terraform"
    Persistent    = "true"
  }
}