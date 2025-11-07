resource "azuredevops_agent_pool" "client_pool" {
  name           = "BSE-${var.client_name}-Pool"
  auto_provision = false
  auto_update    = true
}

resource "azuredevops_variable_group" "agent_variables" {
  project_id   = var.ado_project
  name         = "BSE-${var.client_name}-Variables"
  description  = "Variables for ${var.client_name} self-hosted agent"
  
  variable {
    name  = "CLIENT_NAME"
    value = var.client_name
  }
  
  variable {
    name  = "AGENT_POOL_NAME"
    value = azuredevops_agent_pool.client_pool.name
  }
}