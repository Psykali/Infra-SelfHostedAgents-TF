variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "France Central"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "BseAdoSelfHostAgent"
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

variable "devops_agent_name" {
  description = "Name for the self-hosted agent"
  type        = string
  default     = "ubuntu-agent-01"
}

variable "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  type        = string
  default     = "statestoragetfdevops"
}