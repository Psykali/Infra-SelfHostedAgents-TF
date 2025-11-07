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

variable "private_endpoint_subnet_cidr" {
  description = "CIDR block for private endpoint subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "ubuntu_vm_size" {
  description = "Size of the Ubuntu virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
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

variable "ubuntu_agent_name" {
  description = "Name for the Ubuntu self-hosted agent"
  type        = string
  default     = "ubuntu-agent-01"
}

variable "storage_account_name" {
  description = "Name for the storage account (must be unique)"
  type        = string
  default     = "statetfdevopsfrc01"
}