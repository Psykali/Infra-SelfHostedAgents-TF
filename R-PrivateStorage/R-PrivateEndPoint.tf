# =============================================
# PRIVATE ENDPOINT CONNECTION (MVP)
# =============================================
# Purpose: Direct connection from VM subnet to storage
# Usage: VM uses this private endpoint to access storage

# Create private endpoint FIRST
resource "azurerm_private_endpoint" "storage" {
  name                = local.private_endpoint_name
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
  subnet_id           = azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = local.private_endpoint_connection_name
    private_connection_resource_id = azurerm_storage_account.private.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = local.common_tags
}

# Network rules - allow private endpoint subnet ONLY
resource "azurerm_storage_account_network_rules" "private" {
  storage_account_id = azurerm_storage_account.private.id
  
  # DENY all traffic by default
  default_action = "Deny"
  
  # Allow private endpoint subnet
  virtual_network_subnet_ids = [azurerm_subnet.private_endpoint.id]
  
  # Allow Azure services (required for private endpoint to work)
  bypass = ["AzureServices"]
  
  depends_on = [azurerm_private_endpoint.storage]
}

# Wait for private endpoint to be fully ready
resource "null_resource" "wait_for_private_endpoint" {
  depends_on = [
    azurerm_private_endpoint.storage,
    azurerm_storage_account_network_rules.private
  ]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for private endpoint to propagate (60 seconds)..."
      sleep 60
    EOT
  }
}

# Create container using Azure CLI via private endpoint
resource "null_resource" "create_container_via_private_endpoint" {
  depends_on = [null_resource.wait_for_private_endpoint]

  triggers = {
    storage_name = azurerm_storage_account.private.name
    endpoint_id  = azurerm_private_endpoint.storage.id
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "Creating container via private endpoint..."
      
      # Get storage account key
      STORAGE_KEY=$(az storage account keys list \
        --resource-group ${azurerm_resource_group.storage.name} \
        --account-name ${azurerm_storage_account.private.name} \
        --query '[0].value' \
        --output tsv)
      
      # Create container using private endpoint
      az storage container create \
        --name ${local.tfstate_container_name} \
        --account-name ${azurerm_storage_account.private.name} \
        --account-key "$STORAGE_KEY" \
        --auth-mode key \
        --fail-on-exist
      
      echo "✅ Container created successfully via private endpoint"
    EOT
  }
}

