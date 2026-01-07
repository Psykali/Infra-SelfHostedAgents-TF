# =============================================
# RBAC ASSIGNMENT - VM MANAGED IDENTITY
# =============================================
# Purpose: Grant VM managed identity access to storage account
# Usage: VM can push/pull Terraform state via private endpoint

data "azurerm_user_assigned_identity" "vm_identity" {
  name                = "uai-${var.client_name}-${local.workload_name}-${var.environment}-${var.location_code}-${local.sequence_number}"
  resource_group_name = local.networking_rg_name
}

resource "azurerm_role_assignment" "vm_storage_blob_contributor" {
  scope                = azurerm_storage_account.private.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_user_assigned_identity.vm_identity.principal_id

  depends_on = [
    azurerm_storage_account.private
  ]
}