resource "azuredevops_agent_pool" "client_pool" {
  name           = "BSE-${var.client_name}-Pool"
  auto_provision = false
  auto_update    = true
}

