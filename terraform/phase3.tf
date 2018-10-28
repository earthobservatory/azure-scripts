# Creation of HySDS cluster nodes

resource "azurerm_virtual_machine" "ci" {
  name                  = "${var.ci_instance}"
  location              = "${azurerm_resource_group.hysds.location}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  network_interface_ids = ["${azurerm_network_interface.ci.id}"]

  vm_size = "Standard_D4_v3"

  storage_image_reference {
    id = "${azurerm_image.basevm.id}"
  }

  storage_os_disk {
    name          = "${var.ci_instance}_Disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = "128"
  }

  delete_os_disk_on_termination = "true"

  os_profile {
    computer_name  = "${var.ci_instance}"
    admin_username = "ops"
  }

  os_profile_linux_config {
    disable_password_authentication = "true"

    ssh_keys = {
      key_data = "${file(var.ssh_key_pub_dir)}"
      path     = "/home/ops/.ssh/authorized_keys"
    }
  }
}
resource "azurerm_virtual_machine" "factotum" {
  name                  = "${var.factotum_instance}"
  location              = "${azurerm_resource_group.hysds.location}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  network_interface_ids = ["${azurerm_network_interface.factotum.id}"]

  vm_size = "Standard_D4_v3"

  storage_image_reference {
    id = "${azurerm_image.basevm.id}"
  }

  storage_os_disk {
    name          = "${var.factotum_instance}_Disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = "128"
  }

  delete_os_disk_on_termination = "true"

  os_profile {
    computer_name  = "${var.factotum_instance}"
    admin_username = "ops"
  }

  os_profile_linux_config {
    disable_password_authentication = "true"

    ssh_keys = {
      key_data = "${file(var.ssh_key_pub_dir)}"
      path     = "/home/ops/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_virtual_machine" "metrics" {
  name                  = "${var.metrics_instance}"
  location              = "${azurerm_resource_group.hysds.location}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  network_interface_ids = ["${azurerm_network_interface.metrics.id}"]

  vm_size = "Standard_E4_v3"

  storage_image_reference {
    id = "${azurerm_image.basevm.id}"
  }

  storage_os_disk {
    name          = "${var.metrics_instance}_Disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = "128"
  }

  delete_os_disk_on_termination = "true"

  os_profile {
    computer_name  = "${var.metrics_instance}"
    admin_username = "ops"
  }

  os_profile_linux_config {
    disable_password_authentication = "true"

    ssh_keys = {
      key_data = "${file(var.ssh_key_pub_dir)}"
      path     = "/home/ops/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_virtual_machine" "grq" {
  name                  = "${var.grq_instance}"
  location              = "${azurerm_resource_group.hysds.location}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  network_interface_ids = ["${azurerm_network_interface.grq.id}"]

  vm_size = "Standard_E4_v3"

  storage_image_reference {
    id = "${azurerm_image.basevm.id}"
  }

  storage_os_disk {
    name          = "${var.grq_instance}_Disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = "128"
  }

  delete_os_disk_on_termination = "true"

  os_profile {
    computer_name  = "${var.grq_instance}"
    admin_username = "ops"
  }

  os_profile_linux_config {
    disable_password_authentication = "true"

    ssh_keys = {
      key_data = "${file(var.ssh_key_pub_dir)}"
      path     = "/home/ops/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_virtual_machine" "mozart" {
  name                  = "${var.mozart_instance}"
  location              = "${azurerm_resource_group.hysds.location}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  network_interface_ids = ["${azurerm_network_interface.mozart.id}"]

  vm_size = "Standard_E4_v3"

  storage_image_reference {
    id = "${azurerm_image.basevm.id}"
  }

  storage_os_disk {
    name          = "${var.mozart_instance}_Disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = "128"
  }

  delete_os_disk_on_termination = "true"

  os_profile {
    computer_name  = "${var.mozart_instance}"
    admin_username = "ops"
  }

  os_profile_linux_config {
    disable_password_authentication = "true"

    ssh_keys = {
      key_data = "${file(var.ssh_key_pub_dir)}"
      path     = "/home/ops/.ssh/authorized_keys"
    }
  }
}

resource "null_resource" "vmautoconfig" {
  provisioner "local-exec" {
    command = "sh configure_instances.sh"
    environment {
      AZ_RESOURCE_GROUP  = "${var.resource_group}"
      AZ_BASE_VM_NAME    = "${var.base_vm_name}"
      PRIVATE_KEY_PATH   = "${var.ssh_key_dir}"
      PRIVATE_KEY_NAME   = "${var.ssh_key_name}"
      CI_IP              = "${azurerm_public_ip.ci.fqdn}"
      FACTOTUM_IP        = "${azurerm_public_ip.factotum.fqdn}"
      METRICS_IP         = "${azurerm_public_ip.metrics.fqdn}"
      GRQ_IP             = "${azurerm_public_ip.grq.fqdn}"
      MOZART_IP          = "${azurerm_public_ip.mozart.fqdn}"
    }
  }

  depends_on = ["azurerm_virtual_machine.mozart", "azurerm_virtual_machine.metrics", "azurerm_virtual_machine.grq", "azurerm_virtual_machine.factotum", "azurerm_virtual_machine.ci"]
}

output "Final notice" {
  value = "Do not forget to configure a service principal using \"az ad sp create-for-rbac --sdk-auth\", and retrieve the clientId, clientSecret, subscriptionId and tenantId from the output"
}
