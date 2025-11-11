# Create a dedicated subnet for private endpoints (best practice)
resource "azurerm_subnet" "private_endpoint" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = "client-devops-agents-network-rg"  
  virtual_network_name = data.azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]  # Different subnet than the VM subnet
  
  private_endpoint_network_policies = "Disabled"
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