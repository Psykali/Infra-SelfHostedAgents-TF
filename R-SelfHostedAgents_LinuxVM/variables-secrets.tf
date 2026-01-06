# =============================================
# SECRET VARIABLES - DEVOPS AGENTS
# =============================================
# Purpose: Store sensitive variables separately from main variables
# Usage: This file should be excluded from Git (.gitignore)
#        Use terraform.tfvars or environment variables for values

variable "azure_devops_org_url" {
  description = "Azure DevOps organization URL (e.g., https://dev.azure.com/yourorg)"
  type        = string
  sensitive   = true
}

variable "azure_devops_bootstrap_pat" {
  description = "Bootstrap PAT for creating agent PATs - requires 'Agent Pools (read, manage)' scope"
  type        = string
  sensitive   = true
}

variable "agent_pat_display_name" {
  description = "Display name for the generated agent PAT"
  type        = string
  default     = "Terraform-Managed-Agent-PAT"
}

variable "agent_pat_scope" {
  description = "Scopes for the generated agent PAT"
  type        = list(string)
  default     = ["AgentPools"]
}