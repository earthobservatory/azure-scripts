# Terraform for Azure
# Variables configuration file
# Alter this configuration file to suit your HySDS deployment environment

# Configure the Azure Provider as CLI based
provider "azurerm" { }

###############################################################################
# Networking Resources                                                        #
###############################################################################

variable "location" {
  description = "Location of the HySDS cluster. As this software is built in Singapore, this variable defaults to Southeast Asia"
}

variable "resource_group" {
  description = "The name of the Resource Group used by the HySDS cluster"
}

variable "virtual_net" {
  description = "The name of the Virtual Network used by the HySDS cluster"
}

variable "subnet" {
  description = "The name of the subnet used by the HySDS cluster, associated with the virtual net"
}

variable "network_security_group" {
  description = "The name of the Network Security Group used by the HySDS cluster"
}

variable "nic_mozart" {
  description = "Name of the NIC for Mozart"
}

variable "nic_metrics" {
  description = "Name of the NIC for Metrics"
}

variable "nic_grq" {
  description = "Name of the NIC for GRQ"
}

variable "nic_factotum" {
  description = "Name of the NIC for Factotum"
}

variable "nic_ci" {
  description = "Name of the NIC for CI"
}

variable "publicip_mozart" {
  description = "The public IP for the Mozart instance"
}

variable "publicip_metrics" {
  description = "The public IP for the Metrics instance"
}

variable "publicip_grq" {
  description = "The public IP for the GRQ instance"
}

variable "publicip_factotum" {
  description = "The public IP for the Factotum instance"
}

variable "publicip_ci" {
  description = "The public IP for the CI instance"
}

variable "insights" {
  description = "The name of the Insights analytics"
}


###############################################################################
# Cloud Storage                                                               #
###############################################################################

variable "storage_account_name" {
  description = "The name of the storage account used by the HySDS cluster"
}

variable "storage_code_container" {
  description = "The name of the code container used by the HySDS cluster"
  default = "code"
}

variable "storage_dataset_container" {
  description = "The name of the dataset container used by the HySDS cluster"
  default = "dataset"
}

###############################################################################
# Base VM and image                                                           #
###############################################################################

variable "base_image_name" {
  description = "Name of the base image based on the base VM"
}

###############################################################################
# Verdi Image Creator and Cluster management
###############################################################################

variable "verdi_vm_name" {
  description = "Name of the Verdi Image Creator VM"
}

variable "verdi_vm_ip" {
  description = "Name of the temporary public IP assigned to Verdi Image Creator VM"
}

variable "verdi_vm_type" {
  description = "SKU/VM Type of the Verdi VM for creating a Verdi base image. This is DIFFERENT from the VMSS instance type which is the machine type actually used in autoscaling!"
}

variable "verdi_image_publisher" {
  description = "The publisher of the OS image used to create the Verdi base image"
}

variable "verdi_image_offer" {
  description = "The offer (i.e. operating system) of the OS image used to create the Verdi base image"
}

variable "verdi_image_sku" {
  description = "The SKU of the OS image used to create the Verdi base image, typically the OS version"
}

variable "verdi_image_version" {
  description = "The version of the OS image used to create the Verdi base image, typically the OS build"
}

variable "vmss_instance_type" {
  description = "The instance SKU of the Verdi instances in the autoscale cluster"
}

variable "vmss_group_name" {
  description = "Name of the VMSS autoscaling group"
}

###############################################################################
# SSH Keys
###############################################################################

variable "ssh_key_dir" {
  description = "The path to the master SSH private key to use for the HySDS cluster"
}

variable "ssh_key_pub_dir" {
  description = "The path to the master SSH public key to use for the HySDS cluster"
}

###############################################################################
# Main VMs                                                                    #
###############################################################################

variable "puppet_branch_version" {
  description = "The branch name or version of the Puppet modules deployed on the servers"
}

variable "mozart_instance" {
  description = "The name of the Mozart VM"
}

variable "mozart_instance_type" {
  description = "The instance SKU of the Mozart VM"
}

variable "metrics_instance" {
  description = "The name of the Metrics VM"
}

variable "metrics_instance_type" {
  description = "The instance SKU of the Metrics VM"
}

variable "grq_instance" {
  description = "The name of the GRQ VM"
}

variable "grq_instance_type" {
  description = "The instance SKU of the GRQ VM"
}

variable "factotum_instance" {
  description = "The name of the Factotum instance"
}

variable "factotum_instance_type" {
  description = "The instance SKU of the Factotum VM"
}

variable "ci_instance" {
  description = "The name of the CI instance"
}

variable "ci_instance_type" {
  description = "The instance SKU of the CI VM"
}
