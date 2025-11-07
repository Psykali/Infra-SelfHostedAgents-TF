output "test_blob_url" {
  value = azurerm_storage_blob.test.url
}

output "test_resource_group" {
  value = azurerm_resource_group.test.name
}