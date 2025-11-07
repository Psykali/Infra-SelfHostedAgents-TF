resource "azurerm_private_dns_zone" "storage" {
  provider = azurerm.state_storage
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.state_storage.name
}

resource "azurerm_private_endpoint" "storage" {
  provider = azurerm.state_storage
  name                = "pe-storage-state"
  resource_group_name = azurerm_resource_group.state_storage.name
  location            = azurerm_resource_group.state_storage.location
  subnet_id           = data.azurerm_subnet.vm.id

  private_service_connection {
    name                           = "psc-storage-state"
    private_connection_resource_id = azurerm_storage_account.state.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage.id]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  provider = azurerm.state_storage
  name                  = "vnet-link-storage"
  resource_group_name   = azurerm_resource_group.state_storage.name
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  virtual_network_id    = data.azurerm_virtual_network.spoke.id
}