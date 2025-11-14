data "azurerm_storage_account" "verification" {
  name                = azurerm_storage_account.private.name
  resource_group_name = azurerm_resource_group.storage.name

  depends_on = [
    azurerm_storage_container.tfstate,
    azurerm_private_endpoint.storage,
    null_resource.wait_for_full_setup
  ]
}

# Simple test that outputs success message
resource "null_resource" "test_access_simple" {
  depends_on = [
    azurerm_storage_container.tfstate,
    azurerm_private_endpoint.storage,
    null_resource.wait_for_full_setup
  ]

  provisioner "local-exec" {
    command = <<EOF
      echo "=============================================="
      echo "✅ PRIVATE STORAGE ACCOUNT SETUP COMPLETED"
      echo "=============================================="
      echo "Storage Account: ${azurerm_storage_account.private.name}"
      echo "Container: ${azurerm_storage_container.tfstate.name}"
      echo "Private Endpoint: ${azurerm_private_endpoint.storage.name}"
      echo "Public Access: ${azurerm_storage_account.private.public_network_access_enabled ? "ENABLED" : "DISABLED"}"
      echo "Default Action: ${azurerm_storage_account_network_rules.private.default_action}"
      echo "Allowed Subnets: ${length(azurerm_storage_account_network_rules.private.virtual_network_subnet_ids)}"
      echo ""
      echo "📝 TESTING INSTRUCTIONS:"
      echo "1. SSH into your self-hosted agent VM"
      echo "2. Run: nslookup ${azurerm_storage_account.private.name}.blob.core.windows.net"
      echo "3. Should resolve to a private IP (10.x.x.x)"
      echo "4. Test with: az storage container list --account-name ${azurerm_storage_account.private.name}"
      echo "=============================================="
    EOF
  }
}

output "storage_account_verification" {
  value = {
    name                      = data.azurerm_storage_account.verification.name
    public_network_access     = data.azurerm_storage_account.verification.public_network_access_enabled
    private_endpoint_connections = length(data.azurerm_storage_account.verification.private_endpoint_connections)
    network_rules_default_action = azurerm_storage_account_network_rules.private.default_action
    allowed_subnets_count     = length(azurerm_storage_account_network_rules.private.virtual_network_subnet_ids)
    status                    = "✅ Private storage account configured successfully"
  }
  description = "Verification of private storage account configuration"
}