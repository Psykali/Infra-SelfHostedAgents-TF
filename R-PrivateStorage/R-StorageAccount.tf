variable "allowed_ip" {
  description = "Your allowed IP address"
  default     = "176.147.43.231"
}

# Storage Account with public access enabled (for firewall rules to work)
resource "azurerm_storage_account" "private" {
  name                     = var.private_storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = true
  tags = {
    environment = "devops"
  }
}

resource "azurerm_storage_account_network_rules" "private" {
  storage_account_id = azurerm_storage_account.private.id
  
  # DENY all traffic by default
  default_action = "Deny"
  
  # Allow only your specific IP
  ip_rules = [var.allowed_ip]
  
  # Allow private endpoint subnet
  virtual_network_subnet_ids = [azurerm_subnet.private_endpoint.id]
  
  # Allow Azure services (required for private endpoints and other Azure services)
  bypass = ["AzureServices"]
}


resource "null_resource" "wait_for_full_setup" {
  depends_on = [
    azurerm_private_endpoint.storage,
    azurerm_private_dns_zone_virtual_network_link.storage
  ]

  provisioner "local-exec" {
    command = <<EOF
      echo "Waiting for private endpoint and DNS to be fully operational..."
      
      # Initial wait for Azure to provision
      sleep 60
      
      # Then test connectivity
      max_retries=20
      count=0
      storage_url="https://${azurerm_storage_account.private.name}.blob.core.windows.net/"
      
      while [ $count -lt $max_retries ]; do
        # Escape the curly braces with another %
        if curl -s -o /dev/null -w "%%{http_code}" $storage_url --connect-timeout 10 | grep -q "40[13]"; then
          echo "✓ Storage account is accessible via private endpoint"
          break
        else
          echo "Testing connectivity... ($((count+1))/$max_retries)"
          sleep 10
          count=$((count+1))
        fi
      done
      
      echo "Private endpoint setup completed"
    EOF
    
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.tfstate_container_name
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"

  depends_on = [null_resource.wait_for_full_setup]
}