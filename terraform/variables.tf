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

# Base VM and image

variable "base_vm_name" {
  description = "Name of the base VM to create a base image from"
}

variable "base_vm_ip" {
  description = "Name of the temporary public IP assigned to the base VM"
}


variable "base_image_name" {
  description = "Name of the base image based on the base VM"
}

variable "ssh_key_name" {
  description = "The filename of the master SSH private key without any directory information"
}

variable "ssh_key_dir" {
  description = "The path to the master SSH private key to use for the HySDS cluster"
}

variable "ssh_key_pub_dir" {
  description = "The path to the master SSH public key to use for the HySDS cluster"
}

###############################################################################
# VMs                                                                         #
###############################################################################

variable "mozart_instance" {
  description = "The name of the Mozart VM"
}

variable "metrics_instance" {
  description = "The name of the Metrics VM"
}

variable "grq_instance" {
  description = "The name of the GRQ VM"
}

variable "factotum_instance" {
  description = "The name of the Factotum instance"
}

variable "ci_instance" {
  description = "The name of the CI instance"
}
