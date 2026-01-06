# =============================================
# TERRAFORM VARIABLES EXAMPLE
# =============================================
# Purpose: Example file for terraform.tfvars
# Usage: Copy to terraform.tfvars and fill in your values
# Warning: Never commit terraform.tfvars to version control!

# Azure DevOps Configuration
azure_devops_org_url       = "https://dev.azure.com/bseforgedevops"
azure_devops_bootstrap_pat = "3rWWIoIJYTKgzvtbpmGWVUN0QzdiJzeUiQYz67bt2UQF78WYsIsfJQQJ99CAACAAAAA2O8gkAAASAZDO3SzN"

# Client Configuration
client_name   = "demo"
environment   = "prd"
location      = "francecentral"
location_code = "frc"

# VM Configuration
vm_size      = "Standard_B2als_v2"
admin_username = "devopsadmin"
agent_count  = 3
agent_version = "4.261.0"

# PAT Configuration
agent_pat_display_name = "Terraform-Managed-Agents-PAT"
agent_pat_scope        = ["AgentPools", "Build"]