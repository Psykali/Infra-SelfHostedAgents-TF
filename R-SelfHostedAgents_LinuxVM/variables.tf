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
  description = "Customer short-code (2-6 lower-case letters/numbers)"
  type        = string
  default     = "acme"   # <-- change only this line
}
locals {
  base = "ado-agents"               # fixed part describing the workload

  # resource-group names
  vm_rg_name        = "rg-${var.customer}-${local.base}"
  networking_rg_name= "rg-${var.customer}-net"
  # network objects
  nsg_name    = "nsg-${var.customer}-${local.base}"
  vnet_name   = "vnet-${var.customer}-${local.base}"
  subnet_name = "snet-${var.customer}-${local.base}"

  # VM objects (keep sequence number if you spin up several)
  vm_name = "vm-${var.customer}-agt-01"
  pip_name = "pip-${var.customer}-agt-01"
  nic_name = "nic-${var.customer}-agt-01"
}



variable "vm_rg_name" {
  description = "Name of the resource group"
  default     = "rg-ado-elfHosted-infa"
}

variable "vm_name" {
  description = "Name of the VM"
  default     = "client-devops-agent-vm"
}

variable "networking_rg_name" {
  description = "Name of the resource group"
  default     = "client-devops-agents-network-rg"
}

variable "nsg_name" {
  description  = " NSG Name "
  default      = "client-devops-agent-nsg"
}

variable "vnet_name" {
  description = "Virtual Network Name"
  default     = "client-devops-agent-vnet"
}

variable "subnet_name" {
  description = "Subnet Name"
  default     = "client-devops-agent-subnet"
}

variable "pip_name" {
  description = "Public IP Name"
  default     = "client-devops-agent-pip"
}

variable "nic_name" {
  description = "Network Interface Name"
  default     = "client-devops-agent-nic"
}
### ----------------------------------------------
### Location must be in France as a first option for the rules of RGPD
### ----------------------------------------------
variable "location" {
  description = "Azure region"
  default     = "francecentral"
}

variable "vm_size" {
  description = "VM size"
  default     = "Standard_B2als_v2"
}