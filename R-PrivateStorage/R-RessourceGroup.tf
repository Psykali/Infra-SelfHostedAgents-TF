# =============================================
# RESOURCE GROUP - STORAGE ACCOUNT
# =============================================
# Purpose: Create persistent resource group for storage account
# Usage: Separate RG for Terraform state storage

resource "azurerm_resource_group" "storage" {
  name     = local.storage_rg_name
  location = var.location
  tags     = local.common_tags
}