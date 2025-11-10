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