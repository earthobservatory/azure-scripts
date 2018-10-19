#!/bin/sh

# Names of network resources
export AZ_RESOURCE_GROUP="HySDS_ZY"
export AZ_VNET_NAME="HySDS_VNet_ZY"
export AZ_SUBNET_NAME="HySDS_Subnet_ZY"
export AZ_NSG_NAME="HySDS_NSG_ZY"

# Name of storage assets
export AZ_STORAGE_NAME="hysdszy" # storage account names can only be numbers or lower case letters

# Name for base VM resources
export AZ_BASE_VM_NAME="BaseImageZY"
export AZ_BASE_IMAGE_NAME="HySDS_BaseImage_CentOS75_ZY"

# Names of the deployed VMs. You might want to change them
# These names can only contain alphanumerical characters
export AZ_MOZART_NAME="MozartZY"
export AZ_METRICS_NAME="MetricsZY"
export AZ_GRQ_NAME="GRQZY"
export AZ_FACTOTUM_NAME="FactotumZY"
export AZ_CI_NAME="CIZY"

# Names of the deployed NICs. Refer to Phase 1 for the names of the NICs created
export AZ_MOZART_NIC="MozartNIC_ZY"
export AZ_METRICS_NIC="MetricsNIC_ZY"
export AZ_GRQ_NIC="GRQNIC_ZY"
export AZ_FACTOTUM_NIC="FactotumNIC_ZY"
export AZ_CI_NIC="CINIC_ZY"

# Name of the insights
export AZ_INSIGHTS_NAME="HySDS_ZY_Insights"

# Names of the disks used on the VMs. You might want to change them
export AZ_MOZART_DISK="MozartDisk_ZY"
export AZ_METRICS_DISK="MetricsDisk_ZY"
export AZ_GRQ_DISK="GRQDisk_ZY"
export AZ_FACTOTUM_DISK="FactotumDisk_ZY"
export AZ_CI_DISK="CIDisk_ZY"

export PYTHON_VERSION=`python -c 'import sys; version=sys.version_info[:3]; print("{0}".format(*version))'`
