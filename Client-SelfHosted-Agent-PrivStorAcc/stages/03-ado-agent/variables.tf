variable "ado_organization" {
  description = "Azure DevOps organization name"
  type        = string
  default     = "bseforgedevops"
}

variable "ado_project" {
  description = "Azure DevOps project name"
  type        = string
  default     = "TestScripts-Forge"
}

variable "client_name" {
  description = "Name of the client"
  type        = string
  default     = "client"
}

variable "devops_admin_pat" {
  description = "Azure DevOps PAT with sufficient permissions to create resources"
  type        = string
  sensitive   = true
}