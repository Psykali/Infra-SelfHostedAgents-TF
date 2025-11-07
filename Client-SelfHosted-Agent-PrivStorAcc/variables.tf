variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "France Central"
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

variable "ubuntu_vm_size" {
  description = "Size of the Ubuntu virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "BseAdoSelfAgent"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "devops_org" {
  description = "Azure DevOps organization name"
  type        = string
}

variable "devops_project" {
  description = "Azure DevOps project name"
  type        = string
}

variable "devops_pat" {
  description = "Azure DevOps Personal Access Token"
  type        = string
  sensitive   = true
}

variable "agent_pool_name" {
  description = "Azure DevOps agent pool name"
  type        = string
  default     = "selfhosted-pool"
}