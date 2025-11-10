# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  size                = var.vm_size
  admin_username      = "devopsadmin"
  admin_password      = "FGHJfghj1234"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.common_tags, {
    Description     = "Ubuntu VM hosting Azure DevOps self-hosted agents"
    Component       = "compute"
    OS              = "Ubuntu-22.04-LTS"
    VM-Size         = var.vm_size
    AutoPatch       = "false"
    Backup          = "false"
    Monitoring      = "basic"
  })
}

# Get the public IP address after allocation
data "azurerm_public_ip" "vm_ip" {
  name                = azurerm_public_ip.main.name
  resource_group_name = azurerm_resource_group.network_rg.name
  
  depends_on = [
    azurerm_linux_virtual_machine.main,
    azurerm_public_ip.main
    ]
}

# Create a null_resource with local-exec provisioner
resource "null_resource" "setup_devops_agents" {
  depends_on = [
    azurerm_linux_virtual_machine.main,
    data.azurerm_public_ip.vm_ip
  ]

  triggers = {
    vm_id         = azurerm_linux_virtual_machine.main.id
    public_ip     = data.azurerm_public_ip.vm_ip.ip_address
    script_hash   = filesha256("${path.module}/agent-setup.sh")
  }

  # Wait for SSH to be available first - FIXED VERSION
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for VM to be ready..."
      sleep 30
      until nc -z ${data.azurerm_public_ip.vm_ip.ip_address} 22; do
        echo "Waiting for SSH on ${data.azurerm_public_ip.vm_ip.ip_address}:22..."
        sleep 10
      done
      echo "VM is ready for SSH connections"
    EOT
    
    # Use Unix-style interpreter
    interpreter = ["/bin/bash", "-c"]
  }

  # Connection configuration for SSH
  connection {
    type     = "ssh"
    user     = azurerm_linux_virtual_machine.main.admin_username
    password = azurerm_linux_virtual_machine.main.admin_password
    host     = data.azurerm_public_ip.vm_ip.ip_address
    timeout  = "10m"
  }

  # Copy the script to the VM
  provisioner "file" {
    source      = "${path.module}/agent-setup.sh"
    destination = "/tmp/agent-setup.sh"
  }

  # Execute the script on the VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/agent-setup.sh",
      "sudo /tmp/agent-setup.sh",
      "echo 'Agent setup completed successfully'"
    ]
  }
}