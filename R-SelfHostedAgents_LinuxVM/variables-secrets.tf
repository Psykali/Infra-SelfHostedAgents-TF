# =============================================
# SECRET VARIABLES - DEVOPS AGENTS
# =============================================
# Purpose: Store sensitive variables
# Usage: Use terraform.tfvars or environment variables

variable "azure_devops_org_url" {
  description = "Azure DevOps organization URL"
  type        = string
  sensitive   = true
}

variable "azure_devops_pat" {
  description = "Azure DevOps PAT for agents (create manually in DevOps portal)"
  type        = string
  sensitive   = true
}