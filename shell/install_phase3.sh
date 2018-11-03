#!/bin/sh

# This bash script performs automatic provisioning of a HySDS system on Azure with test credentials and small scale virtual machines
# This bash script is PHASE 3, which provisions instances of HySDS cluster nodes

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

# Import envvars from external file
source envvars.sh

echo "HySDS provisioning tool, 🖥 PHASE 3 (deployment of HySDS cluster nodes)🖥"

echo
echo "➡️  Retrieving base image information..."
if [ PYTHON_VERSION = "3" ]; then
  export BASE_IMAGE_ID=`az image show -g $AZ_RESOURCE_GROUP -n $AZ_BASE_IMAGE_NAME -o json | \
  python -c "import sys, json; print(json.load(sys.stdin)['id'])"`
else
  export BASE_IMAGE_ID=`az image show -g $AZ_RESOURCE_GROUP -n $AZ_BASE_IMAGE_NAME -o json | \
  python -c "import sys, json; print json.load(sys.stdin)['id']"`
fi

echo "➡️  FYI: base image ID is $BASE_IMAGE_ID"

echo
read -e -p "⌨️  Please paste the absolute path (with escape sequences) of the private key here and press enter: " PRIVATE_KEY_PATH
export PUBLIC_KEY=$(cat "$PRIVATE_KEY_PATH.pub")

echo
echo "⌨️  Are you deploying for development or testing?"
read -e -p "Development/Testing (d/t): " DEPLOY_MODE

echo
echo "➡️  Creating virtual machines..."

# Old version, kept here as reference
# if [ "$DEPLOY_MODE" = "t" ]; then
#   # Minimum configuration for testing purposes
#   # Please note that we are using Standard_F2 instead of Standard_D2_v3 due to the fact that Standard_D2_v3 does not support accelerated networking
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_MOZART_NAME --nics $AZ_MOZART_NIC --os-disk-name $AZ_MOZART_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_METRICS_NAME --nics $AZ_METRICS_NIC --os-disk-name $AZ_METRICS_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_GRQ_NAME --nics $AZ_GRQ_NIC --os-disk-name $AZ_GRQ_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_FACTOTUM_NAME --nics $AZ_FACTOTUM_NIC --os-disk-name $AZ_FACTOTUM_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_CI_NAME --nics $AZ_CI_NIC --os-disk-name $AZ_CI_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
# elif [ "$DEPLOY_MODE" = "d" ]; then
#   # Development configuration
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_MOZART_NAME --nics $AZ_MOZART_NIC --os-disk-name $AZ_MOZART_DISK --os-disk-size-gb 128 --size Standard_E4_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_METRICS_NAME --nics $AZ_METRICS_NIC --os-disk-name $AZ_METRICS_DISK --os-disk-size-gb 128 --size Standard_E4_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_GRQ_NAME --nics $AZ_GRQ_NIC --os-disk-name $AZ_GRQ_DISK --os-disk-size-gb 128 --size Standard_E4_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_FACTOTUM_NAME --nics $AZ_FACTOTUM_NIC --os-disk-name $AZ_FACTOTUM_DISK --os-disk-size-gb 128 --size Standard_D4_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
#   az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_CI_NAME --nics $AZ_CI_NIC --os-disk-name $AZ_CI_DISK --os-disk-size-gb 128 --size Standard_D4_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY"
# else
#   echo "Invalid input, aborting tool."
#   return 0;
# fi

if [ "$DEPLOY_MODE" = "t" ]; then
  # Minimum configuration for testing purposes
  # Please note that we are using Standard_F2 instead of Standard_D2_v3 due to the fact that Standard_D2_v3 does not support accelerated networking
  export MOZART_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_MOZART_NAME --nics $AZ_MOZART_NIC --os-disk-name $AZ_MOZART_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
  export METRICS_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_METRICS_NAME --nics $AZ_METRICS_NIC --os-disk-name $AZ_METRICS_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
  export GRQ_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_GRQ_NAME --nics $AZ_GRQ_NIC --os-disk-name $AZ_GRQ_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
  export FACTOTUM_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_FACTOTUM_NAME --nics $AZ_FACTOTUM_NIC --os-disk-name $AZ_FACTOTUM_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
  export CI_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_CI_NAME --nics $AZ_CI_NIC --os-disk-name $AZ_CI_DISK --os-disk-size-gb 64 --size Standard_F2 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
elif [ "$DEPLOY_MODE" = "d" ]; then
  # Development configuration
  export MOZART_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_MOZART_NAME --nics $AZ_MOZART_NIC --os-disk-name $AZ_MOZART_DISK --os-disk-size-gb 128 --size Standard_E4_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
  export METRICS_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_METRICS_NAME --nics $AZ_METRICS_NIC --os-disk-name $AZ_METRICS_DISK --os-disk-size-gb 128 --size Standard_E4_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
  export GRQ_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_GRQ_NAME --nics $AZ_GRQ_NIC --os-disk-name $AZ_GRQ_DISK --os-disk-size-gb 128 --size Standard_E4_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
  export FACTOTUM_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_FACTOTUM_NAME --nics $AZ_FACTOTUM_NIC --os-disk-name $AZ_FACTOTUM_DISK --os-disk-size-gb 128 --storage-sku Premium_LRS --size Standard_D4s_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
  export CI_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_CI_NAME --nics $AZ_CI_NIC --os-disk-name $AZ_CI_DISK --os-disk-size-gb 128 --size Standard_D4_v3 --image $BASE_IMAGE_ID --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
else
  echo "Invalid input, aborting tool."
  return 0;
fi

echo "➡️  All VMs created. Please double check that all VMs are created properly. VM IP addresses are as follows:"
echo "🚀  Mozart: $MOZART_IP"
echo "🚀  Metrics: $METRICS_IP"
echo "🚀  GRQ: $GRQ_IP"
echo "🚀  Factotum: $FACTOTUM_IP"
echo "🚀  CI: $CI_IP"
echo
echo "✅  Tool Completed. Exiting..."
