# Create a dedicated subnet for private endpoints (best practice)
resource "azurerm_subnet" "private_endpoint" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = "client-devops-agents-network-rg"  
  virtual_network_name = data.azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]  # Different subnet than the VM subnet
  
  # Required for private endpoints
  private_endpoint_network_policies = "Disabled"
  private_link_service_network_policies = "Disabled"
}

# Resource Group for Storage
resource "azurerm_resource_group" "storage" {
  name     = var.storage_rg_name
  location = var.location
}

resource "azurerm_storage_account" "private" {
  name                     = var.private_storage_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Enable private network access
  public_network_access_enabled = false

  tags = {
    environment = "devops"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.tfstate_container_name
  storage_account_name  = azurerm_storage_account.private.name
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "storage" {
  name                = var.private_endpoint_name
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
  subnet_id           = azurerm_subnet.private_endpoint.id  

  private_service_connection {
    name                           = var.private_endpoint_connection_name
    private_connection_resource_id = azurerm_storage_account.private.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.storage.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "storage-dns-link"
  resource_group_name   = azurerm_resource_group.storage.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = data.azurerm_virtual_network.main.id 
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}