resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage-tfstate"
  resource_group_name = azurerm_resource_group.spoke_networking.name
  location            = azurerm_resource_group.spoke_networking.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-storage-tfstate"
    private_connection_resource_id = azurerm_storage_account.tfstate.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage.id]
  }

  tags = {
    Environment = "Production"
    Purpose     = "Terraform-State-Access"
  }
}

resource "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.spoke_networking.name

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "vnet-link-storage"
  resource_group_name   = azurerm_resource_group.spoke_networking.name
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  virtual_network_id    = azurerm_virtual_network.spoke.id

  tags = {
    Environment = "Production"
  }
}