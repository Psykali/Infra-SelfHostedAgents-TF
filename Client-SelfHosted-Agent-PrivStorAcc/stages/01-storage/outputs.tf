output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "storage_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "resource_group_name" {
  value = azurerm_resource_group.storage.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.storage.id
}