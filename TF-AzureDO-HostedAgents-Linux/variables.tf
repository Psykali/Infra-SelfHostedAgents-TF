variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "francecentral"
}

variable "hub_vnet_cidr" {
  description = "CIDR block for Hub VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "spoke_vnet_cidr" {
  description = "CIDR block for Spoke VNet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vm_subnet_cidr" {
  description = "CIDR block for VM subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "ado-selfhostlin"
}

variable "devops_org" {
  description = "Azure DevOps organization name"
  type        = string
}

variable "devops_pat" {
  description = "Azure DevOps Personal Access Token"
  type        = string
  sensitive   = true
}

variable "devops_agent_pool" {
  description = "Azure DevOps agent pool name"
  type        = string
  default     = "Default"
}

variable "devops_agent_name" {
  description = "Name for the self-hosted agent"
  type        = string
  default     = "linux-agents-01"
}