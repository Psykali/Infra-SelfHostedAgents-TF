### ----------------------------------------------
### Naming Should be Homogene with the Azure & Vlient naming Policies
### ----------------------------------------------
variable "customer" {
  description = "Customer short-code (2-5 lower-case letters/numbers)"
  type        = string
### change only this entry and must be homogene with the client name in the variables of the SelfHosted VM  
  default     = "test"    
}

locals {
  base = "ado-agents"               # workload suffix from stage 1 for data
  base_storage = "tfstate"          # workload suffix for storage assets

  # Storage resource-group name
  storage_rg_name = "rg-storage-${var.customer}-${local.base_storage}"

  # Storage account (24-char max, lowercase, no hyphens at ends)
  private_storage_name = "${var.customer}st${local.base_storage}001"

  # Container names (lower-case, numbers & hyphens only)
  tfstate_container_name = "tfstate-${var.customer}"

  # Private-endpoint related names
  private_endpoint_name            = "pe-${var.customer}-${local.base_storage}-blob"
  private_endpoint_connection_name = "pec-${var.customer}-${local.base_storage}-blob"
  private_endpoint_subnet_name     = "snet-${var.customer}-${local.base_storage}-pe"

  # network objects from stage 1 for data 
  networking_rg_name= "rg-networking-${var.customer}-${local.base}"
  vnet_name   = "vnet-${var.customer}-${local.base}"
  subnet_name = "snet-${var.customer}-${local.base}"
}

### -------------------------------------------------------------------
### Location must be in France as a first option for the rules of RGPD
### -------------------------------------------------------------------
variable "location" {
  description = "Azure region"
  default     = "francecentral"
}