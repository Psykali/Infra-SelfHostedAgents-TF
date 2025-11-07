# Ubuntu VM Extensions for DevOps Agent Setup
resource "azurerm_virtual_machine_extension" "ubuntu_devops_agent_setup" {
  count                = 2
  name                 = "devops-agent-setup-ubuntu-${count.index + 1}"
  virtual_machine_id   = azurerm_linux_virtual_machine.devops_agents[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  protected_settings = jsonencode({
    "script": base64encode(templatefile("${path.module}/scripts/ubuntu_devops_agent_setup.sh", {
      devops_org        = var.devops_org
      devops_pat        = var.devops_pat
      devops_agent_pool = var.devops_agent_pool
      devops_agent_name = var.ubuntu_agent_names[count.index]
      admin_username    = var.admin_username
    }))
  })

  tags = {
    Environment = "Production"
    OS          = "Ubuntu"
  }
}

# Windows VM Extension for DevOps Agent Setup
resource "azurerm_virtual_machine_extension" "windows_devops_agent_setup" {
  name                 = "devops-agent-setup-windows"
  virtual_machine_id   = azurerm_windows_virtual_machine.devops_agent.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File \".\\windows_devops_agent_setup.ps1\" -DevOpsOrg \"${var.devops_org}\" -DevOpsPAT \"${var.devops_pat}\" -AgentPool \"${var.devops_agent_pool}\" -AgentName \"${var.windows_agent_name}\""
  })

  tags = {
    Environment = "Production"
    OS          = "Windows"
  }
}