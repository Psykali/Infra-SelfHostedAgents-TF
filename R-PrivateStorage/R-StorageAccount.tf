# =============================================
# PRIVATE STORAGE ACCOUNT FOR TERRAFORM STATE
# =============================================
# Purpose: Create private storage account for Terraform state
# Approach: Use Azure CLI to create container after private endpoint is ready
# Security: NO PUBLIC ACCESS EVER - private endpoint only
# =============================================

resource "azurerm_storage_account" "private" {
  name                     = local.private_storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  # CRITICAL: NO PUBLIC ACCESS - PRIVATE ENDPOINT ONLY
  public_network_access_enabled = false
  
  # Enable blob storage
  account_kind = "StorageV2"
  
  tags = local.common_tags
}

# Create dedicated subnet for private endpoint (10.0.0.32/27)
resource "azurerm_subnet" "private_endpoint" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = local.networking_rg_name
  virtual_network_name = local.vnet_name
  address_prefixes     = ["10.0.0.32/27"]
  
  # Enable private endpoints
  private_endpoint_network_policies = "Enabled"
  
  # Service endpoint for storage
  service_endpoints = ["Microsoft.Storage"]
}

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

# Verify container was created
resource "null_resource" "verify_container" {
  depends_on = [null_resource.create_container_via_private_endpoint]

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