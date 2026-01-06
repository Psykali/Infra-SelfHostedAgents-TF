# =============================================
# AZURE DEVOPS PAT MANAGEMENT
# =============================================
# Purpose: Create and manage Azure DevOps Personal Access Token via REST API
# Usage: Uses null_resource with Azure CLI to create PAT since Terraform provider doesn't support PAT creation

# Generate PAT using Azure CLI (since Terraform provider doesn't support PAT creation)
resource "null_resource" "generate_devops_pat" {
  provisioner "local-exec" {
    command = <<EOT
      # Create PAT using Azure DevOps CLI
      az devops login --organization "${var.azure_devops_org_url}"
      PAT_TOKEN=$(az devops security token create \
        --name "Terraform-Agent-PAT-${var.client_name}" \
        --scope "vso.agentpools_manage vso.build_execute vso.project_manage" \
        --org "${var.azure_devops_org_url}" \
        --query "token" -o tsv)
      
      # Store in Key Vault
      az keyvault secret set \
        --vault-name "${azurerm_key_vault.main.name}" \
        --name "azure-devops-pat" \
        --value "$PAT_TOKEN" \
        --output none
    EOT
    
    interpreter = ["bash", "-c"]
    
    environment = {
      AZURE_DEVOPS_ORG_URL = var.azure_devops_org_url
    }
  }
  
  depends_on = [
    azurerm_key_vault.main,
    azurerm_key_vault_access_policy.current_user
  ]
}