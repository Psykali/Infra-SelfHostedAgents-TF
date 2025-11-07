resource "azurerm_virtual_machine_extension" "ubuntu_devops_agent_setup" {
  name                 = "devops-agent-setup-ubuntu"
  virtual_machine_id   = azurerm_linux_virtual_machine.devops_agent.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  protected_settings = jsonencode({
    "script": base64encode(templatefile("${path.module}/scripts/ubuntu_devops_agent_setup.sh", {
      devops_org        = var.devops_org
      devops_pat        = var.devops_pat
      devops_agent_pool = var.devops_agent_pool
      devops_agent_name = var.ubuntu_agent_name
      admin_username    = var.admin_username
      storage_account_name = var.storage_account_name
      resource_group_name  = azurerm_resource_group.storage.name
    }))
  })

  tags = {
    Environment = "Production"
    OS          = "Ubuntu"
  }
}