# Phase 2: Creation of the Verdi image creator VM

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

# Verdi VM
resource "azurerm_virtual_machine" "verdi" {
  name                  = "${var.verdi_vm_name}"
  location              = "${azurerm_resource_group.hysds.location}"
  resource_group_name   = "${azurerm_resource_group.hysds.name}"
  network_interface_ids = ["${azurerm_network_interface.verdi.id}"]

  vm_size               = "Standard_B2s"
  # vm_size = "Standard_B4ms" # This is to increase the speed of installation

  storage_image_reference {
    id = "${azurerm_image.basevm.id}"
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
}

resource "null_resource" "verdi" {
  provisioner "local-exec" {
      command = "sh configure_verdi_base.sh"
      environment {
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

# Creation of the Base Image from the VM we just generalized
# resource "azurerm_image" "verdi" {
#   name                      = "${var.base_image_name}"
#   location                  = "${azurerm_resource_group.hysds.location}"
#   resource_group_name       = "${azurerm_resource_group.hysds.name}"
#   source_virtual_machine_id = "${azurerm_virtual_machine.verdi.id}"

#   depends_on = ["null_resource.verdi"]
# }


# # Null resource to run a script to configure the VM for imaging, and to deallocate and generalize the image 
# resource "null_resource" "verdi" {
#   provisioner "local-exec" {
#     command = "sh generalize_base_image.sh"
#     environment {
#       AZ_RESOURCE_GROUP  = "${var.resource_group}"
#       AZ_BASE_VM_NAME    = "${var.base_vm_name}"
#       PRIVATE_KEY_PATH   = "${var.ssh_key_dir}"
#       FQDN               = "${azurerm_public_ip.basevm.fqdn}"
#     }
#   }

#   depends_on = ["azurerm_virtual_machine.basevm"]
# }

# # Creation of the Base Image from the VM we just generalized
# resource "azurerm_image" "basevm" {
#   name                      = "${var.base_image_name}"
#   location                  = "${azurerm_resource_group.hysds.location}"
#   resource_group_name       = "${azurerm_resource_group.hysds.name}"
#   source_virtual_machine_id = "${azurerm_virtual_machine.basevm.id}"

#   depends_on = ["null_resource.basevm"]
# }
