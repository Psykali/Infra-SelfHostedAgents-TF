### ----------------------------------------------
### Variables to be modified to the clients values
### ----------------------------------------------
variable "admin_username" {
  description = "Name of the VM Admin login"
  sensitive = true
  default     = "devopsadmin"
}
### --------------------------------------------------------------------------------------------
### Password for the VM of the Agents, Create a strong Password and store it in bitwarden
### --------------------------------------------------------------------------------------------
variable "admin_password" {
  description = "Name of the resource group"
  sensitive = true
  default     = "FGHJfghj1234!"
}
### ----------------------------------------------
### Naming Should be Homogene with the Azure & Vlient naming Policies
### ----------------------------------------------
variable "customer" {
  description = "Customer short-code (2-5 lower-case letters/numbers)"
  type        = string
  default     = "client"   # <-- change only this line
}
locals {
  base = "ado-agents"               # fixed part describing the workload

  # resource-group names
  vm_rg_name        = "rg-infra-${var.customer}-${local.base}"
  networking_rg_name= "rg-networking-${var.customer}-${local.base}"
  # network objects
  nsg_name    = "nsg-${var.customer}-${local.base}"
  vnet_name   = "vnet-${var.customer}-${local.base}"
  subnet_name = "snet-${var.customer}-${local.base}"

  # VM objects (keep sequence number if you spin up several)
  vm_name = "vm-${var.customer}-${local.base}-001"
  pip_name = "pip-${var.customer}-${local.base}-001"
  nic_name = "nic-${var.customer}-${local.base}-001"
}
### -------------------------------------------------------------------
### Location must be in France as a first option for the rules of RGPD
### -------------------------------------------------------------------
variable "location" {
  description = "Azure region"
  default     = "francecentral"
}

variable "vm_size" {
  description = "VM size"
  default     = "Standard_B2als_v2"
}
### -------
### Tages 
### -------
locals {
  common_tags = {
    Client        = "BSE"
    Environment   = "Prod"     ### Choose between (Dev, QAL & Prod)
    Criticality   = "High"     ### Choose between (Low, Medium & High)
    CreatedBy     = "SKA"      ###  BSE Name Code
    Purpose       = "Test DevOps SelfHosted Agents"
    Project       = "Forge DevOps"
#    CostCenter    = ""
#    BusinessUnit  = ""
    CreationDate  = formatdate("YYYY-MM-DD", timestamp())
    Terraform     = "true"
    ManagedBy     = "terraform"
  }
}