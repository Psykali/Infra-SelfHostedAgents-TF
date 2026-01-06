# =============================================
# SECRET VARIABLES - DEVOPS AGENTS
# =============================================
# Purpose: Store sensitive variables
# Usage: Use terraform.tfvars or environment variables

variable "azure_devops_org_url" {
  description = "Azure DevOps organization URL"
  type        = string
  sensitive   = true
  default     = "https://dev.azure.com/bseforgedevops"
}

variable "azure_devops_pat" {
  description = "Azure DevOps PAT for agents (create manually in DevOps portal)"
  type        = string
  sensitive   = true
  default     = "Hga16IPIP3S4xZSAV91wspYV0v8CUlNJ9wGwGLV4GccoPd1dV1LcJQQJ99CAACAAAAA2O8gkAAASAZDO2ul1"
}