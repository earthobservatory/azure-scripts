# Phase 4: Creation of the Verdi image creator VM

# Public IP for the Verdi VM
resource "azurerm_public_ip" "verdi" {
  name                         = "${var.verdi_vm_ip}"
  location                     = "${azurerm_resource_group.hysds.location}"
  resource_group_name          = "${azurerm_resource_group.hysds.name}"
  domain_name_label            = "${lower(var.verdi_vm_name)}"
  public_ip_address_allocation = "dynamic"
}

# NIC for the Verdi VM
resource "azurerm_network_interface" "verdi" {
  name                = "VerdiNIC"
  location            = "${azurerm_resource_group.hysds.location}"
  resource_group_name = "${azurerm_resource_group.hysds.name}"

  ip_configuration {
    name                          = "VerdiNIC"
    subnet_id                     = "${azurerm_subnet.hysds.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.verdi.id}"
  }
}

# Verdi VM (base image creator)
resource "azurerm_virtual_machine" "verdi" {
  name                  = "${var.verdi_vm_name}"
  location              = "${azurerm_resource_group.hysds.location}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  network_interface_ids = ["${azurerm_network_interface.verdi.id}"]

  vm_size               = "${var.verdi_vm_type}"

  storage_image_reference {
    publisher = "${var.verdi_image_publisher}"
    offer     = "${var.verdi_image_offer}"
    sku       = "${var.verdi_image_sku}"
    version   = "${var.verdi_image_version}"
  }

  storage_os_disk {
    name          = "${var.verdi_vm_name}_Disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  delete_os_disk_on_termination = "true"

  os_profile {
    computer_name  = "${var.verdi_vm_name}"
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

resource "null_resource" "verdi" {
  provisioner "local-exec" {
      command = "sh configure_verdi_base.sh"
      environment {
          PUPPET_BRANCH     = "${var.puppet_branch_version}"
          PRIVATE_KEY_PATH  = "${var.ssh_key_dir}"
          PRIVATE_KEY_NAME  = "${basename(var.ssh_key_dir)}"
          VERDI_IP          = "${azurerm_public_ip.verdi.fqdn}"
          MOZART_IP         = "${azurerm_public_ip.mozart.fqdn}"
          AZ_RESOURCE_GROUP = "${var.resource_group}"
          VMSS              = "${var.vmss_group_name}"
      }
  }

  depends_on = ["azurerm_virtual_machine.verdi"]
}

output "Verdi FQDN / VERDI_FQDN" {
  value = "${azurerm_public_ip.verdi.fqdn}"
}

output "VMSS Group Name" {
  value = "${var.vmss_group_name}"
}

output "Z - Final notice 1" {
  value = "Do not forget to configure a service principal using \"az ad sp create-for-rbac --sdk-auth\", and retrieve the clientId, clientSecret, subscriptionId and tenantId from the output"
}

output "Z - Final notice 2" {
  value = "Please refer to the configuration guides in order to continue configuring the Verdi instances and autoscaling. The Verdi image creator VM is configured asynchronously, and may still be in the midst of configuring itself. Terraform only configures up to the Verdi image creator"
}
