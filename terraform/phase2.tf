# Phase 2: Creation of a base VM and image

# Public IP for the Base VM
resource "azurerm_public_ip" "basevm" {
  name                         = "${var.base_vm_ip}"
  location                     = "${azurerm_resource_group.hysds.location}"
  resource_group_name          = "${azurerm_resource_group.hysds.name}"
  domain_name_label            = "${lower(var.base_vm_name)}"
  public_ip_address_allocation = "dynamic"
}

# NIC for the Base VM
resource "azurerm_network_interface" "basevm" {
  name                = "BaseVMNIC"
  location            = "${azurerm_resource_group.hysds.location}"
  resource_group_name = "${azurerm_resource_group.hysds.name}"

  ip_configuration {
    name                          = "BaseVMIP"
    subnet_id                     = "${azurerm_subnet.hysds.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.basevm.id}"
  }
}

# Base VM
resource "azurerm_virtual_machine" "basevm" {
  name                  = "${var.base_vm_name}"
  location              = "${azurerm_resource_group.hysds.location}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  network_interface_ids = ["${azurerm_network_interface.basevm.id}"]

  vm_size               = "Standard_DS1_v2"
  # vm_size = "Standard_B4ms" # This is to increase the speed of installation

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "7.5.20180815"
  }

  storage_os_disk {
    name          = "${var.base_vm_name}_Disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.base_vm_name}"
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
      host        = "${azurerm_public_ip.basevm.fqdn}"
      type        = "ssh"
      user        = "ops"
      private_key = "${file(var.ssh_key_dir)}"
    }

    inline = [
      "sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config",
      "sudo yum install -y epel-release",
      # "sudo yum -y update",
      "sudo yum -y install puppet puppet-firewalld nscd ntp wget curl subversion git vim screen cloud-utils-growpart",
      "sudo yum clean all",
    ]
  }
}

# Null resource to run a script to configure the VM for imaging, and to deallocate and generalize the image 
resource "null_resource" "basevm" {
  provisioner "local-exec" {
    command = "sh generalize_base_image.sh"
    environment {
      AZ_RESOURCE_GROUP  = "${var.resource_group}"
      AZ_BASE_VM_NAME    = "${var.base_vm_name}"
      PRIVATE_KEY_PATH   = "${var.ssh_key_dir}"
      FQDN               = "${azurerm_public_ip.basevm.fqdn}"
    }
  }

  depends_on = ["azurerm_virtual_machine.basevm"]
}

# Creation of the Base Image from the VM we just generalized
resource "azurerm_image" "basevm" {
  name                      = "${var.base_image_name}"
  location                  = "${azurerm_resource_group.hysds.location}"
  resource_group_name       = "${azurerm_resource_group.hysds.name}"
  source_virtual_machine_id = "${azurerm_virtual_machine.basevm.id}"

  depends_on = ["null_resource.basevm"]
}
