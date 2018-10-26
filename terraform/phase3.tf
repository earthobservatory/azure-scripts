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

  provisioner "remote-exec" {
    connection {
      host        = "${azurerm_public_ip.ci.fqdn}"
      type        = "ssh"
      user        = "ops"
      private_key = "${file(var.ssh_key_dir)}"
    }

    inline = [
      "sudo growpart /dev/sda 2",
      "sudo xfs_growfs -d /dev/sda2",
      "curl -kL https://bitbucket.org/nvgdevteam/puppet-cont_int/raw/master/install.sh > install_ci.sh",
      "sudo bash /home/ops/install_ci.sh 2>&1 | tee /home/ops/install_ci.log"
    ]
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

  provisioner "remote-exec" {
    connection {
      host        = "${azurerm_public_ip.factotum.fqdn}"
      type        = "ssh"
      user        = "ops"
      private_key = "${file(var.ssh_key_dir)}"
    }

    inline = [
      "sudo growpart /dev/sda 2",
      "sudo xfs_growfs -d /dev/sda2",
      "curl -kL https://bitbucket.org/nvgdevteam/puppet-factotum/raw/master/install.sh > install_factotum.sh",
      "sudo sh /home/ops/install_factotum.sh 2>&1 | tee /home/ops/install_factotum.log"
    ]
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

  provisioner "remote-exec" {
    connection {
      host        = "${azurerm_public_ip.metrics.fqdn}"
      type        = "ssh"
      user        = "ops"
      private_key = "${file(var.ssh_key_dir)}"
    }

    inline = [
      "sudo growpart /dev/sda 2",
      "sudo xfs_growfs -d /dev/sda2",
      "curl -kL https://bitbucket.org/nvgdevteam/puppet-metrics/raw/master/install.sh > install_metric.sh",
      "sudo bash /home/ops/install_metric.sh 2>&1 | tee /home/ops/install_metric.log",
    ]
  }

  # This dependency delays the provisioning of GRQ and metrics to prevent too many SSH connections
  depends_on = ["azurerm_virtual_machine.ci", "azurerm_virtual_machine.factotum"]
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

  provisioner "remote-exec" {
    connection {
      host        = "${azurerm_public_ip.grq.fqdn}"
      type        = "ssh"
      user        = "ops"
      private_key = "${file(var.ssh_key_dir)}"
    }

    inline = [
      "sudo growpart /dev/sda 2",
      "sudo xfs_growfs -d /dev/sda2",
      "curl -kL https://bitbucket.org/nvgdevteam/puppet-grq/raw/master/install.sh > install_grq.sh",
      "curl -kL https://bitbucket.org/nvgdevteam/puppet-grq/raw/master/esdata.sh > install_esdata.sh",
      "sudo bash /home/ops/install_grq.sh 2>&1 | tee /home/ops/install_grq.log",
      "sudo bash /home/ops/install_esdata.sh 2>&1 | tee /home/ops/install_esdata.log",
    ]
  }

  # This dependency delays the provisioning of GRQ and metrics to prevent too many SSH connections
  depends_on = ["azurerm_virtual_machine.ci", "azurerm_virtual_machine.factotum"]
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

  provisioner "file" {
    connection {
      host        = "${azurerm_public_ip.mozart.fqdn}"
      type        = "ssh"
      user        = "ops"
      private_key = "${file(var.ssh_key_dir)}"
    }

    source = "${var.ssh_key_dir}"
    destination = "/home/ops/.ssh/${var.ssh_key_name}"
  }

  provisioner "remote-exec" {
    connection {
      host        = "${azurerm_public_ip.mozart.fqdn}"
      type        = "ssh"
      user        = "ops"
      private_key = "${file(var.ssh_key_dir)}"
    }

    inline = [
      "sudo growpart /dev/sda 2",
      "sudo xfs_growfs -d /dev/sda2",
      "curl -kL https://bitbucket.org/nvgdevteam/puppet-mozart/raw/master/install.sh > install_mozart.sh",
      "sudo bash /home/ops/install_mozart.sh 2>&1 | tee /home/ops/install_mozart.log",
      "chmod 400 ~/.ssh/${var.ssh_key_name}",
      "rm -rf ~/mozart",
      "cd $HOME",
      "git clone https://bitbucket.org/nvgdevteam/hysds-framework.git",
      "cd hysds-framework",
      "./install.sh mozart -d",
    ]
  }

  # This dependency makes sure that Mozart is set up last
  depends_on = ["azurerm_virtual_machine.metrics", "azurerm_virtual_machine.grq", "azurerm_virtual_machine.factotum", "azurerm_virtual_machine.ci"]
}
