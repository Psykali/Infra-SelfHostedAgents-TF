### =============================================
### VARIABLES
### =============================================
### Client configuration
variable "client_name" {
  description = "Client acronyme 3-5 lettres (used in naming)"
  type        = string
  default     = "Client"  ### Change this for Client acronyme 3-5 lettres (used in naming)
}

variable "environment" {
  description = "Environment (dev, qal, prod)"
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

### VM Configuration
variable "vm_size" {
  description = "VM size for DevOps agents"
  default     = "Standard_B2als_v2"
}

variable "admin_username" {
  description = "VM admin username"
  default     = "devopsadmin"
  sensitive   = true
}

### Key Vault Configuration
variable "key_vault_sku" {
  description = "Key Vault SKU"
  default     = "standard"
}

### Storage Configuration
variable "storage_account_tier" {
  description = "Storage account tier"
  default     = "Standard"
}

variable "storage_replication" {
  description = "Storage replication type"
  default     = "LRS"
}

### =============================================
### LOCALS (Naming Convention)
### =============================================

locals {
  ### Base naming components
  base_name        = "Client" ### Change this for Client acronyme 3-5 lettres (used in naming)
  sequence_number  = "01"
  
  ### Resource Group Names (Following MS naming convention)
  network_rg_name  = "rg-${var.client_name}-${local.base_name}-network-${var.environment}-${var.location_code}-${local.sequence_number}"
  agent_rg_name    = "rg-${var.client_name}-${local.base_name}-agent-${var.environment}-${var.location_code}-${local.sequence_number}"
  tfstate_rg_name  = "rg-${var.client_name}-${local.base_name}-tfstate-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # Network Resources
  vnet_name        = "vnet-${var.client_name}-${local.base_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  subnet_name      = "snet-${var.client_name}-${local.base_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  nsg_name         = "nsg-${var.client_name}-${local.base_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  
  # VM Resources
  vm_name          = "vm-${var.client_name}-${local.base_name}-agent-${var.environment}-${var.location_code}-${local.sequence_number}"
  os_disk_name     = "osdisk-${local.vm_name}"
  nic_name         = "nic-${local.vm_name}"
  pip_name         = "pip-${local.vm_name}"
  
  # Key Vault
  kv_name          = "kv-${var.client_name}-${local.base_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  kv_pep_name      = "pep-${local.kv_name}"
  kv_nic_name      = "nic-${local.kv_pep_name}"
  
  # Storage Account (limited to 24 chars, no hyphens)
  sa_name          = "st${var.client_name}${local.base_name}${var.environment}${var.location_code}${local.sequence_number}"
  sa_pep_name      = "pep-${local.sa_name}"
  sa_nic_name      = "nic-${local.sa_pep_name}"
  
  # Private DNS Zone
  privatelink_dns_zone = "privatelink.blob.core.windows.net"
  
  # Common Tags
  common_tags = {
    Client        = var.client_name
    Environment   = var.environment
    Criticality   = "High"
    CreatedBy     = "Terraform"
    Purpose       = "DevOps Self-Hosted Agents Infrastructure"
    Project       = "Forge DevOps"
    CreationDate  = formatdate("YYYY-MM-DD", timestamp())
    ManagedBy     = "Terraform"
  }
}