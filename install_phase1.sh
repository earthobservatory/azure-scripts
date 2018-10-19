#!/bin/sh

# This bash script performs automatic provisioning of a HySDS system on Azure with test credentials and small scale virtual machines
# This bash script is PHASE 1, which creates base resources such as networking, IPs and subnets

# Prerequisites and warnings:
# You may want to switch account subscriptions before running these commands with the command `azure account set -s 76098c74-fc7a-4c42-aa84-1f8217bc1ec1`
# If the commands fail with "This subscription is not registered to use 'Microsoft.Network'" or similar errors, please manually register with the commands:
# `az provider register --namespace Microsoft.Network`
# `az provider register --namespace Microsoft.Compute`
# `az provider register --namespace Microsoft.Storage`
# Stopping this script while running may cause incomplete configurations! Please triple check all envvars before proceeding!

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

# Import envvars from external file
source envvars.sh

echo "HySDS provisioning tool, 📡PHASE 1 (provisioning of network resources)📡"
echo
echo "This tool assumes you have already created the resource group $AZ_RESOURCE_GROUP!"
read -n 1 -s -r -p "⌨  Press any key to continue or press Ctrl-C to abort..."

# Create a virtual net, HySDS_VNet_ZY and a subnet, HySDS_Subnet_ZY
echo
echo "➡️  Creating virtual net and subnet..."
az network vnet create --resource-group $AZ_RESOURCE_GROUP --name $AZ_VNET_NAME --address-prefix 10.1.0.0/16 --subnet-name $AZ_SUBNET_NAME --subnet-prefix 10.1.1.0/24

# Create a network security group, HySDS_NSG_ZY
echo "➡️  Creating network security group..."
az network nsg create --resource-group $AZ_RESOURCE_GROUP --name $AZ_NSG_NAME

# Configure network security groups for SSH inbound. You might want to alter this rule once all the servers are configured
az network nsg rule create --resource-group $AZ_RESOURCE_GROUP --nsg-name $AZ_NSG_NAME --name default-allow-ssh --access Allow --protocol Tcp --direction Inbound --priority 1000 --source-address-prefix Internet --source-port-range "*" --destination-port-range 22

# Create public IPs
echo "➡️  Creating public IPs..."
az network public-ip create --name MozartPubIP_ZY --resource-group $AZ_RESOURCE_GROUP
az network public-ip create --name MetricsPubIP_ZY --resource-group $AZ_RESOURCE_GROUP
az network public-ip create --name GRQPubIP_ZY --resource-group $AZ_RESOURCE_GROUP
az network public-ip create --name FactotumPubIP_ZY --resource-group $AZ_RESOURCE_GROUP
az network public-ip create --name CIPubIP_ZY --resource-group $AZ_RESOURCE_GROUP

# Create network interfaces (NICs)
echo "➡️  Creating network interfaces..."
az network nic create --resource-group $AZ_RESOURCE_GROUP --name MozartNIC_ZY --vnet-name $AZ_VNET_NAME --subnet $AZ_SUBNET_NAME --accelerated-networking true --public-ip-address MozartPubIP_ZY --network-security-group $AZ_NSG_NAME
az network nic create --resource-group $AZ_RESOURCE_GROUP --name MetricsNIC_ZY --vnet-name $AZ_VNET_NAME  --subnet $AZ_SUBNET_NAME  --accelerated-networking true --public-ip-address MetricsPubIP_ZY  --network-security-group $AZ_NSG_NAME
az network nic create --resource-group $AZ_RESOURCE_GROUP --name GRQNIC_ZY  --vnet-name $AZ_VNET_NAME  --subnet $AZ_SUBNET_NAME  --accelerated-networking true --public-ip-address GRQPubIP_ZY --network-security-group $AZ_NSG_NAME
az network nic create --resource-group $AZ_RESOURCE_GROUP --name FactotumNIC_ZY  --vnet-name $AZ_VNET_NAME  --subnet $AZ_SUBNET_NAME  --accelerated-networking true --public-ip-address FactotumPubIP_ZY  --network-security-group $AZ_NSG_NAME
az network nic create --resource-group $AZ_RESOURCE_GROUP --name CINIC_ZY  --vnet-name $AZ_VNET_NAME  --subnet $AZ_SUBNET_NAME  --accelerated-networking true --public-ip-address CIPubIP_ZY  --network-security-group $AZ_NSG_NAME

# Create application insights
echo "➡️  Creating application insights..."
az resource create --resource-group $AZ_RESOURCE_GROUP --resource-type "Microsoft.Insights/components" --name $AZ_INSIGHTS_NAME --location southeastasia --properties '{"ApplicationId":"hysds_zy","Application_Type":"other", "Flow_Type":"Bluefield", "Request_Source":"rest"}'

# Create a storage account
echo "➡️  Creating a storage account..."
az storage account create --name $AZ_STORAGE_NAME --resource-group $AZ_RESOURCE_GROUP --kind StorageV2 --location southeastasia --access-tier Hot --sku Standard_LRS
export AZ_STORAGE_KEYS_JSON=$(az storage account keys list --resource-group $AZ_RESOURCE_GROUP --account-name $AZ_STORAGE_NAME)
# FIXME: THERE IS AN ERRATA IN THE CONTRACTOR'S DOCUMENT IN THE COMMAND ABOVE!!!
if [ $PYTHON_VERSION = "3" ]; then
  export AZ_STORAGE_KEY_ONE=`echo $AZ_STORAGE_KEYS_JSON | python -c "import sys, json; print(json.load(sys.stdin)[0]['value'])"`
  export AZ_STORAGE_KEY_TWO=`echo $AZ_STORAGE_KEYS_JSON | python -c "import sys, json; print(json.load(sys.stdin)[1]['value'])"`
else
  export AZ_STORAGE_KEY_ONE=`echo $AZ_STORAGE_KEYS_JSON | python -c "import sys, json; print json.load(sys.stdin)[0]['value']"`
  export AZ_STORAGE_KEY_TWO=`echo $AZ_STORAGE_KEYS_JSON | python -c "import sys, json; print json.load(sys.stdin)[1]['value']"`
fi

echo "➡️  Creating storage containers..."

az storage container create --name code --account-name $AZ_STORAGE_NAME --account-key $AZ_STORAGE_KEY_ONE --public-access container
az storage container create --name dataset --account-name $AZ_STORAGE_NAME --account-key $AZ_STORAGE_KEY_TWO --public-access container

echo
echo "✅  Tool Completed. Exiting..."
