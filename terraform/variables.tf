variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "bseforge"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "vm_name" {
  description = "Virtual Machine name"
  type        = string
  default     = "vm-devops-agent-ubuntu"
}

variable "vm_size" {
  description = "Virtual Machine size"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "devopsagent"
}

variable "agent_count" {
  description = "Number of agents to install"
  type        = number
  default     = 10
}

variable "azure_devops_url" {
  description = "Azure DevOps organization URL"
  type        = string
}

variable "pat_token" {
  description = "Azure DevOps PAT token"
  type        = string
  sensitive   = true
}

variable "pool_name" {
  description = "Agent pool name"
  type        = string
}