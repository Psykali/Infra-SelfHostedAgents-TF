# Create agent pool using Azure DevOps provider
resource "azuredevops_agent_pool" "client_pool" {
  name           = "BSE-${var.client_name}-Pool"
  auto_provision = false
  auto_update    = true
}

# Create project if it doesn't exist
resource "azuredevops_project" "main" {
  name               = var.ado_project
  description        = "Project for ${var.client_name}"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

# Create variable group for agent configuration
resource "azuredevops_variable_group" "agent_config" {
  project_id   = azuredevops_project.main.id
  name         = "BSE-${var.client_name}-Agent-Config"
  description  = "Configuration for ${var.client_name} self-hosted agents"

  variable {
    name  = "AGENT_POOL_NAME"
    value = azuredevops_agent_pool.client_pool.name
  }

  variable {
    name  = "ORGANIZATION_URL"
    value = "https://dev.azure.com/${var.ado_organization}"
  }
}

# Use null_resource to call Python script for PAT creation
resource "null_resource" "create_ado_pat" {
  triggers = {
    client_name = var.client_name
    project     = var.ado_project
    organization = var.ado_organization
  }

  provisioner "local-exec" {
    command = <<EOT
      python3 ${path.module}/../../scripts/create_ado_resources.py \
        "${var.ado_organization}" \
        "${var.ado_project}" \
        "${var.client_name}" \
        "${var.devops_admin_pat}"
    EOT

    environment = {
      AZURE_DEVOPS_PAT = var.devops_admin_pat
    }
  }

  depends_on = [azuredevops_agent_pool.client_pool, azuredevops_project.main]
}

resource "local_file" "agent_config" {
  filename = "${path.module}/agent-config.json"
  content = jsonencode({
    organization = var.ado_organization
    project      = var.ado_project
    client_name  = var.client_name
    pool_name    = azuredevops_agent_pool.client_pool.name
    pool_id      = azuredevops_agent_pool.client_pool.id
  })

  depends_on = [null_resource.create_ado_pat]
}