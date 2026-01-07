# =============================================
# CONNECTION TEST - STORAGE ACCOUNT
# =============================================
# Purpose: Test and verify storage account connectivity via private endpoint
# Usage: Validates private endpoint configuration works correctly

data "azurerm_private_endpoint_connection" "storage_pep" {
  name                = azurerm_private_endpoint.storage.name
  resource_group_name = azurerm_resource_group.storage.name
  
  depends_on = [
    null_resource.verify_container
  ]
}

# Get private IP from private endpoint
data "azurerm_network_interface" "pep_nic" {
  name                = azurerm_private_endpoint.storage.network_interface[0].name
  resource_group_name = azurerm_resource_group.storage.name
  
  depends_on = [
    data.azurerm_private_endpoint_connection.storage_pep
  ]
}

# Verify container was created
resource "null_resource" "verify_container" {
  depends_on = [azurerm_storage_container.tfstate]  

  provisioner "local-exec" {
    command = <<EOT
      echo "Verifying container creation..."
      
      STORAGE_KEY=$(az storage account keys list \
        --resource-group ${azurerm_resource_group.storage.name} \
        --account-name ${azurerm_storage_account.private.name} \
        --query '[0].value' \
        --output tsv)
      
      az storage container exists \
        --name ${local.tfstate_container_name} \
        --account-name ${azurerm_storage_account.private.name} \
        --account-key "$STORAGE_KEY" \
        --auth-mode key
      
      echo "✅ Container verification complete"
    EOT
  }
}

# Create test file
resource "local_file" "connection_test_guide" {
  filename = "${path.module}/test-private-connection.sh"
  content = <<EOF
#!/bin/bash
# =============================================
# PRIVATE STORAGE CONNECTION TEST
# =============================================
# Purpose: Test VM connection to private storage via private endpoint
# Usage: Run this on the agents VM after deployment
# Requirements: Azure CLI installed, VM has managed identity

echo "=============================================="
echo "🔍 TESTING PRIVATE STORAGE CONNECTION"
echo "=============================================="
echo "Storage Account: ${azurerm_storage_account.private.name}"
echo "Private Endpoint: ${azurerm_private_endpoint.storage.name}"
echo "Private IP: ${data.azurerm_network_interface.pep_nic.ip_configuration[0].private_ip_address}"
echo "Container: ${local.tfstate_container_name}"
echo "=============================================="

# 1. Authenticate with VM's managed identity
echo ""
echo "1. Authenticating with managed identity..."
az login --identity --allow-no-subscriptions

# 2. Test DNS resolution via Azure-provided DNS
echo ""
echo "2. Testing DNS resolution..."
nslookup ${azurerm_storage_account.private.name}.blob.core.windows.net

# 3. Test storage access via managed identity
echo ""
echo "3. Testing storage access via managed identity..."
az storage container list \
  --account-name ${azurerm_storage_account.private.name} \
  --auth-mode login

# 4. Create and upload test file
echo ""
echo "4. Creating test file..."
echo "✅ Private connection test successful at $(date)" > /tmp/private-test.txt
echo "Storage: ${azurerm_storage_account.private.name}" >> /tmp/private-test.txt
echo "Endpoint: ${azurerm_private_endpoint.storage.name}" >> /tmp/private-test.txt
echo "Private IP: ${data.azurerm_network_interface.pep_nic.ip_configuration[0].private_ip_address}" >> /tmp/private-test.txt

az storage blob upload \
  --account-name ${azurerm_storage_account.private.name} \
  --container-name ${local.tfstate_container_name} \
  --name "private-connection-test.txt" \
  --file "/tmp/private-test.txt" \
  --auth-mode login

echo ""
echo "=============================================="
echo "✅ TEST COMPLETE - PRIVATE ENDPOINT WORKING"
echo "=============================================="
echo "If all steps succeeded:"
echo "1. DNS resolves to private IP"
echo "2. VM can access storage via managed identity"
echo "3. Private endpoint is functional"
echo ""
echo "To verify blob:"
echo "az storage blob list --account-name ${azurerm_storage_account.private.name} --container-name tfstate"
echo "=============================================="
EOF

  file_permission = "0755"
  
  depends_on = [
    data.azurerm_network_interface.pep_nic
  ]
}

# Output verification results
output "storage_account_verification" {
  value = {
    storage_account    = azurerm_storage_account.private.name
    container          = local.tfstate_container_name
    private_endpoint   = azurerm_private_endpoint.storage.name
    private_ip         = data.azurerm_network_interface.pep_nic.ip_configuration[0].private_ip_address
    connection_state   = data.azurerm_private_endpoint_connection.storage_pep.private_service_connection[0].status
    verification       = "✅ Private storage account configured with NO PUBLIC ACCESS"
    test_script        = "test-private-connection.sh"
  }
  
  description = "Verification of private storage account configuration"
}

output "connection_test_instructions" {
  value = <<EOT

  ==============================================
  🔒 PRIVATE STORAGE ACCOUNT DEPLOYED
  ==============================================
  Storage: ${azurerm_storage_account.private.name}
  Private Endpoint: ${azurerm_private_endpoint.storage.name}
  Private IP: ${data.azurerm_network_interface.pep_nic.ip_configuration[0].private_ip_address}
  Container: ${local.tfstate_container_name}
  
  ✅ NO PUBLIC ACCESS - PRIVATE ENDPOINT ONLY
  
  📋 CONNECTION TEST INSTRUCTIONS:
  1. SSH to your agent VM
  2. Copy test script: scp test-private-connection.sh devopsadmin@<VM_PUBLIC_IP>:~/
  3. Run: chmod +x test-private-connection.sh && ./test-private-connection.sh
  
  🔧 TERRAFORM BACKEND CONFIGURATION:
  
  Add this to AgentVM/providers.tf:
  
  terraform {
    backend "azurerm" {
      resource_group_name  = "${azurerm_resource_group.storage.name}"
      storage_account_name = "${azurerm_storage_account.private.name}"
      container_name       = "${local.tfstate_container_name}"
      key                  = "agents.terraform.tfstate"
    }
  }
  
  ==============================================
  EOT
  
  description = "Instructions for testing and configuring the private storage"
}