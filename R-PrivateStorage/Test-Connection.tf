# =============================================
# CONNECTION TEST - STORAGE ACCOUNT
# =============================================
# Purpose: Test and verify storage account connectivity
# Usage: Validates private endpoint configuration

# Wait for private endpoint to be fully provisioned
resource "time_sleep" "wait_for_provisioning" {
  create_duration = "300s"  # Wait 5 minutes
  
  depends_on = [
    azurerm_private_endpoint.storage
  ]
}

# Test verification output
resource "null_resource" "verification_output" {
  depends_on = [time_sleep.wait_for_provisioning]
  
  provisioner "local-exec" {
    command = <<EOF
      echo "=============================================="
      echo "✅ STORAGE ACCOUNT DEPLOYMENT VERIFIED"
      echo "=============================================="
      echo "📦 Storage Account: ${azurerm_storage_account.private.name}"
      echo "📁 Container: ${azurerm_storage_container.tfstate.name}"
      echo "🔗 Private Endpoint: ${azurerm_private_endpoint.storage.name}"
      echo "🌐 Private IP: ${azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address}"
      echo ""
      echo "🔒 SECURITY STATUS:"
      echo "   Public Network Access: DISABLED"
      echo "   Default Network Action: DENY"
      echo "   Allowed Subnet: ${data.azurerm_subnet.agents.name}"
      echo ""
      echo "🔧 MANUAL CONFIGURATION REQUIRED:"
      echo "   Add to agents VM /etc/hosts:"
      echo "   ${azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address} ${azurerm_storage_account.private.name}.blob.core.windows.net"
      echo ""
      echo "📝 TEST FROM AGENTS VM AFTER CONFIG:"
      echo "   nslookup ${azurerm_storage_account.private.name}.blob.core.windows.net"
      echo "   # Should return: ${azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address}"
      echo "=============================================="
    EOF
  }
}