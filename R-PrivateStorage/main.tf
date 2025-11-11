
#  Variables
variable "private_storage_name" {
  description = "Name of the resource group"
  default     = "clienttfprivstacc"
}

variable "rg_name" {
  description = "Name of the resource group"
  default     = "rg-client-tf-storage"
}

variable "location" {
  description = "Azure region"
  default     = "francecentral"
}

variable "tfstate_container_name" {
  description = "tfstate_container_name"
  default     = "client_tfstate"
}

variable "private_endpoint_name" {
  description = "Private Endpoint Name"
  default     = "client-storage-private-endpoint"
}

variable "private_endpoint_connection_name" {
  description = "Private Endpoint Name"
  default     = "client-storage-private-connection"
}


# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.rg_name
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
  virtual_network_id    = azurerm_virtual_network.storage.id
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}