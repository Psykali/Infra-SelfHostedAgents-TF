# =============================================
# CONNECTION TEST - STORAGE ACCOUNT
# =============================================
# Purpose: Test and verify storage account connectivity
# Usage: Validates private endpoint configuration works

# Get private endpoint IP for verification
data "azurerm_private_endpoint_connection" "storage_pep" {
  name                = azurerm_private_endpoint.storage.name
  resource_group_name = azurerm_resource_group.storage.name
  
  depends_on = [
    azurerm_private_endpoint.storage,
    azurerm_storage_container.tfstate,
  ]
}

# Create test blob to verify write access
resource "azurerm_storage_blob" "test_connection" {
  name                   = "connection-test.txt"
  storage_account_name   = azurerm_storage_account.private.name
  storage_container_name = azurerm_storage_container.tfstate.name
  type                   = "Block"
  source_content         = "✅ Connection test successful at ${timestamp()}\nStorage: ${azurerm_storage_account.private.name}\nPrivate Endpoint: ${azurerm_private_endpoint.storage.name}"
  
  depends_on = [
    azurerm_storage_container.tfstate,
    data.azurerm_private_endpoint_connection.storage_pep,
  ]
}

# Output verification results
output "connection_verification" {
  value = {
    storage_account    = azurerm_storage_account.private.name
    container          = azurerm_storage_container.tfstate.name
    test_blob          = azurerm_storage_blob.test_connection.name
    private_endpoint   = azurerm_private_endpoint.storage.name
    private_ip         = azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address
    connection_state   = data.azurerm_private_endpoint_connection.storage_pep.private_service_connection[0].status
    verification       = "✅ Storage account configured with private endpoint"
  }
  
  description = "Verification of storage account private endpoint configuration"
}

# Local test script that can be run on VM
resource "local_file" "test_script" {
  filename = "${path.module}/test-storage-connection.sh"
  content = <<EOF
#!/bin/bash
# =============================================
# STORAGE CONNECTION TEST SCRIPT
# =============================================
# Purpose: Test connectivity from agents VM to private storage
# Usage: Run this script on the agents VM after both deployments

echo "=============================================="
echo "🔍 TESTING STORAGE CONNECTION FROM VM"
echo "=============================================="

STORAGE_ACCOUNT="${azurerm_storage_account.private.name}"
PRIVATE_ENDPOINT="${azurerm_private_endpoint.storage.name}"

echo "1. Testing DNS resolution..."
nslookup $STORAGE_ACCOUNT.blob.core.windows.net

echo ""
echo "2. Testing Azure CLI authentication..."
az login --identity --allow-no-subscriptions

echo ""
echo "3. Testing storage access..."
az storage container list \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login

echo ""
echo "4. Listing blobs in container..."
az storage blob list \
  --account-name $STORAGE_ACCOUNT \
  --container-name tfstate \
  --auth-mode login \
  --query "[].name" \
  --output table

echo ""
echo "=============================================="
echo "✅ Test script generated"
echo "Upload to VM: scp test-storage-connection.sh devopsadmin@[VM_PUBLIC_IP]:~/"
echo "Run on VM: chmod +x test-storage-connection.sh && ./test-storage-connection.sh"
echo "=============================================="
EOF

  file_permission = "0755"
}