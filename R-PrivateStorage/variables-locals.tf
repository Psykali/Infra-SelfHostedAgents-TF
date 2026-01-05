# =============================================
# INPUT VARIABLES FOR STORAGE ACCOUNT
# =============================================

# Customer/Client Configuration
variable "customer" {
  description = "Client Acronyme (2-4 characters, lowercase)"
  type        = string
  default     = "test"
  validation {
    condition     = length(var.customer) >= 2 && length(var.customer) <= 5
    error_message = "Customer Acronyme must be 2-4 characters."
  }
}

# Environment Configuration
variable "environment" {
  description = "Deployment environment (dev, qal, prd)"
  type        = string
  default     = "prd"
  validation {
    condition     = contains(["dev", "qal", "prd"], var.environment)
    error_message = "Environment must be 'dev', 'qal', or 'prd'."
  }
}

# Location Configuration
variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "francecentral"
}

variable "location_code" {
  description = "Short code for location (used in naming)"
  type        = string
  default     = "frc"
}

# Storage Configuration
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
}

# DNS Configuration
variable "create_private_dns_zone" {
  description = "Whether to create private DNS zone (set false if DevOps Agents created it)"
  type        = bool
  default     = true
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}