output "agent_pool_name" {
  value = azuredevops_agent_pool.client_pool.name
}

output "agent_pool_id" {
  value = azuredevops_agent_pool.client_pool.id
}

output "project_id" {
  value = azuredevops_project.main.id
}

output "organization_url" {
  value = "https://dev.azure.com/${var.ado_organization}"
}