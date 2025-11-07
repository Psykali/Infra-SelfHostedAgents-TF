# Using local-exec to run the setup script
resource "null_resource" "devops_agent_setup" {
  depends_on = [
    azurerm_linux_virtual_machine.devops_agent,
    azurerm_private_endpoint.storage
  ]

  triggers = {
    vm_id = azurerm_linux_virtual_machine.devops_agent.id
  }

  provisioner "local-exec" {
    command = <<EOT
      chmod +x ./scripts/run_local_exec.sh && \
      ./scripts/run_local_exec.sh \
        "${azurerm_public_ip.ubuntu_vm.ip_address}" \
        "${var.admin_username}" \
        "${var.admin_password}" \
        "${var.devops_org}" \
        "${var.devops_pat}" \
        "${var.devops_agent_pool}" \
        "${var.devops_agent_name}"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "VM and DevOps agent are being destroyed. Agent should be automatically removed from pool."
    EOT
  }
}