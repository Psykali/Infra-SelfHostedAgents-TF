# =============================================
# RESOURCE GROUP - STORAGE ACCOUNT
# =============================================
# Purpose: Create persistent resource group for storage account
# Usage: Separate RG for Terraform state storage

resource "azurerm_resource_group" "storage" {
  name     = local.storage_rg_name
  location = var.location
  
  tags = merge(local.common_tags, {
    Description = "Persistent resource group for Terraform state storage"
    CanDelete   = "false"  # Warning: Contains Terraform state!
  })
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}