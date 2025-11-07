variable "client_name" {
  description = "Name of the client"
  type        = string
  default     = "client"
} 

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