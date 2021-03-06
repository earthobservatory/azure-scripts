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

# Create a virtual net and a subnet
echo
echo "➡️  Creating virtual net and subnet..."
az network vnet create --resource-group $AZ_RESOURCE_GROUP --name $AZ_VNET_NAME --address-prefix 10.1.0.0/16 --subnet-name $AZ_SUBNET_NAME --subnet-prefix 10.1.1.0/24

# Create a network security group
echo "➡️  Creating network security group..."
az network nsg create --resource-group $AZ_RESOURCE_GROUP --name $AZ_NSG_NAME

# Configure network security groups for SSH, HTTP and HTTPS inbound. You might want to tighten the security once all the servers are configured
az network nsg rule create --resource-group $AZ_RESOURCE_GROUP --nsg-name $AZ_NSG_NAME --name SSHAccess --access Allow --protocol Tcp --direction Inbound --priority 1000 --source-address-prefix Internet --source-port-range "*" --destination-port-range 22
az network nsg rule create --resource-group $AZ_RESOURCE_GROUP --nsg-name $AZ_NSG_NAME --name HTTPAccess --access Allow --protocol Tcp --direction Inbound --priority 1100 --source-address-prefix Internet --source-port-range "*" --destination-port-range 80
az network nsg rule create --resource-group $AZ_RESOURCE_GROUP --nsg-name $AZ_NSG_NAME --name HTTPSAccess --access Allow --protocol Tcp --direction Inbound --priority 1200 --source-address-prefix Internet --source-port-range "*" --destination-port-range 443
az network nsg rule create --resource-group $AZ_RESOURCE_GROUP --nsg-name $AZ_NSG_NAME --name HTTPAltAccess --access Allow --protocol Tcp --direction Inbound --priority 1300 --source-address-prefix Internet --source-port-range "*" --destination-port-range 8080
az network nsg rule create --resource-group $AZ_RESOURCE_GROUP --nsg-name $AZ_NSG_NAME --name QueueAccess --access Allow --protocol Tcp --direction Inbound --priority 1400 --source-address-prefix Internet --source-port-range "*" --destination-port-range 15672
az network nsg rule create --resource-group $AZ_RESOURCE_GROUP --nsg-name $AZ_NSG_NAME --name CeleryAccess --access Allow --protocol Tcp --direction Inbound --priority 1500 --source-address-prefix Internet --source-port-range "*" --destination-port-range 5555
az network nsg rule create --resource-group $AZ_RESOURCE_GROUP --nsg-name $AZ_NSG_NAME --name ElasticSearchAccess --access Allow --protocol Tcp --direction Inbound --priority 1600 --source-address-prefix Internet --source-port-range "*" --destination-port-range 9200


# Create public IPs
echo "➡️  Creating public IPs..."
az network public-ip create --name $AZ_MOZART_PUBIP --resource-group $AZ_RESOURCE_GROUP
az network public-ip create --name $AZ_METRICS_PUBIP --resource-group $AZ_RESOURCE_GROUP
az network public-ip create --name $AZ_GRQ_PUBIP --resource-group $AZ_RESOURCE_GROUP
az network public-ip create --name $AZ_FACTOTUM_PUBIP --resource-group $AZ_RESOURCE_GROUP
az network public-ip create --name $AZ_CI_PUBIP --resource-group $AZ_RESOURCE_GROUP

# Create network interfaces (NICs)
echo "➡️  Creating network interfaces..."
az network nic create --resource-group $AZ_RESOURCE_GROUP --name $AZ_MOZART_NIC --vnet-name $AZ_VNET_NAME --subnet $AZ_SUBNET_NAME --accelerated-networking true --public-ip-address $AZ_MOZART_PUBIP --network-security-group $AZ_NSG_NAME
az network nic create --resource-group $AZ_RESOURCE_GROUP --name $AZ_METRICS_NIC --vnet-name $AZ_VNET_NAME  --subnet $AZ_SUBNET_NAME  --accelerated-networking true --public-ip-address $AZ_METRICS_PUBIP  --network-security-group $AZ_NSG_NAME
az network nic create --resource-group $AZ_RESOURCE_GROUP --name $AZ_GRQ_NIC  --vnet-name $AZ_VNET_NAME  --subnet $AZ_SUBNET_NAME  --accelerated-networking true --public-ip-address $AZ_GRQ_PUBIP --network-security-group $AZ_NSG_NAME
az network nic create --resource-group $AZ_RESOURCE_GROUP --name $AZ_FACTOTUM_NIC  --vnet-name $AZ_VNET_NAME  --subnet $AZ_SUBNET_NAME  --accelerated-networking true --public-ip-address $AZ_FACTOTUM_PUBIP --network-security-group $AZ_NSG_NAME
az network nic create --resource-group $AZ_RESOURCE_GROUP --name $AZ_CI_NIC  --vnet-name $AZ_VNET_NAME  --subnet $AZ_SUBNET_NAME  --accelerated-networking true --public-ip-address $AZ_CI_PUBIP --network-security-group $AZ_NSG_NAME

# Create application insights
echo "➡️  Creating application insights..."
az resource create --resource-group $AZ_RESOURCE_GROUP --resource-type "Microsoft.Insights/components" --name $AZ_INSIGHTS_NAME --location southeastasia --properties '{"ApplicationId":"$AZ_INSIGHTS_NAME","Application_Type":"other", "Flow_Type":"Bluefield", "Request_Source":"rest"}'

# Create a storage account
echo "➡️  Creating a storage account..."
az storage account create --name $AZ_STORAGE_NAME --resource-group $AZ_RESOURCE_GROUP --kind StorageV2 --location southeastasia --access-tier Hot --sku Standard_LRS
export AZ_STORAGE_KEYS_JSON=$(az storage account keys list --resource-group $AZ_RESOURCE_GROUP --account-name $AZ_STORAGE_NAME)
# FIXME: THERE IS AN ERRATA IN THE CONTRACTOR'S DOCUMENT IN THE COMMAND ABOVE!!!
if [ $PYTHON_VERSION = "3" ]; then
  export AZ_STORAGE_KEY=`echo $AZ_STORAGE_KEYS_JSON | python -c "import sys, json; print(json.load(sys.stdin)[0]['value'])"`
else
  export AZ_STORAGE_KEY=`echo $AZ_STORAGE_KEYS_JSON | python -c "import sys, json; print json.load(sys.stdin)[0]['value']"`
fi

echo "➡️  Creating storage containers..."

az storage container create --name code --account-name $AZ_STORAGE_NAME --account-key $AZ_STORAGE_KEY --public-access container
az storage container create --name dataset --account-name $AZ_STORAGE_NAME --account-key $AZ_STORAGE_KEY --public-access container

echo
echo "✅  Tool Completed. Exiting..."
