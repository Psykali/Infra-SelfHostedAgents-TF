# Variables
variable "vm_rg_name" {
  description = "Name of the resource group"
  default     = "client-devops-agents-vm-rg"
}
variable "networking_rg_name" {
  description = "Name of the resource group"
  default     = "client-devops-agents-network-rg"
}

variable "location" {
  description = "Azure region"
  default     = "francecentral"
}

variable "vm_name" {
  description = "Name of the VM"
  default     = "client-devops-agent-vm"
}

variable "vm_size" {
  description = "VM size"
  default     = "Standard_B2als_v2"
}

variable "agent_count" {
  description = "Number of DevOps agents to install"
  default     = 5
}

variable "devops_org" {
  description = "Azure DevOps organization"
  default = "bseforgedevops"
}

variable "devops_project" {
  description = "Azure DevOps Project"
  default = "TestScripts-Forge"
}

variable "devops_pool" {
  description = "Azure DevOps agent pool name"
  default     = "client-hostedagents-ubuntu01"
}

variable "devops_pat" {
  description = "Azure DevOps Personal Access Token Named: client-devops-pat"
  sensitive   = true
  default     = "BSAAkacP3YMqphCwk0jwyYuYyZMW4QYe3tOVdbCHpEVXAcO8up4XJQQJ99BKACAAAAA2O8gkAAASAZDOgQ7J"
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