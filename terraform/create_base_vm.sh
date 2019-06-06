#!/bin/bash

# This script semi-automatically creates, provisions and images the base VM

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

# Import envvars from external file
#source envvars.sh

# Define constants
# TODO: Please edit this section to suit your configuration!!
resource_group="HySDS_Prod_Terra"
base_vm_name="BaseImageDev"
base_image_name="HySDS_BaseImage_CentOS76_Dev"
os_image_publisher="OpenLogic"
os_image_offer="CentOS"
os_image_sku="7.6"
os_image_version="7.6.20190402"

echo "HySDS provisioning tool, 💿Automated creation of base VM image💿"

echo
read -r -e -p "⌨️  Please enter the absolute path (with escape sequences) of a private key here: " PRIVATE_KEY_PATH
read -r -e -p "⌨️  Please enter the absolute path (with escape sequences) of the corresponding public key here (default: $PRIVATE_KEY_PATH.pub): " PUBLIC_KEY_PATH
if [ "$PUBLIC_KEY_PATH" = "" ]; then
  PUBLIC_KEY_PATH="$PRIVATE_KEY_PATH.pub"
  PUBLIC_KEY=$(cat "$PRIVATE_KEY_PATH.pub")
else
  PUBLIC_KEY=$(cat "$PUBLIC_KEY_PATH")
fi

echo
echo "➡️  Validating keys..."
diff <(cut -d' ' -f 2 "$PUBLIC_KEY_PATH") <(ssh-keygen -y -f "$PRIVATE_KEY_PATH" | cut -d' ' -f 2)
key_valid=$?

if [ ! $key_valid = 0 ]; then
  echo
  echo "️️️️️➡️  Invalid keypair, please check your keys!"
  echo "➡️  The private key you supplied is: $PRIVATE_KEY_PATH"
  echo "➡️  The public key you supplied is: $PUBLIC_KEY_PATH"
  echo
  echo "❌  Tool failed. Exiting..."
  exit 1
else
  echo "✅  Keys validated"
fi


echo
echo "➡️  Creating base virtual machine..."
if [ "$PYTHON_VERSION" = "3" ]; then
  BASE_IP=$(az vm create --resource-group $resource_group --name $base_vm_name --image $os_image_publisher:$os_image_offer:$os_image_sku:$os_image_version --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])") # Retrieves public IP address
else
  BASE_IP=$(az vm create --resource-group $resource_group --name $base_vm_name --image $os_image_publisher:$os_image_offer:$os_image_sku:$os_image_version --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print json.load(sys.stdin)['publicIpAddress']") # Retrieves public IP address
fi

echo "➡️  Base virtual machine has the IP $BASE_IP"

echo
echo "➡️  Automatically configuring base virtual machine..."
ssh -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" -T ops@"$BASE_IP" <<'EOSSH'
sudo su -
sed -i 's/enforcing/disabled/g' /etc/selinux/config
yum install -y epel-release
yum -y install puppet puppet-firewalld nscd ntp wget curl subversion git vim screen cloud-utils-growpart
yum clean all
EOSSH

echo "➡️  FYI: You may now SSH into the machine using the command ssh -i \"$PRIVATE_KEY_PATH\" ops@$BASE_IP"
read -n 1 -s -r -p "⌨️  Check if the configuration procedures were successful. If successful, press any key to continue, else, SSH into the machine and reconfigure it manually..."

echo
echo "➡️  Preparing base virtual machine for imaging..."
ssh -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" -T ops@"$BASE_IP" <<'EOSSH'
sudo su -
rm -rf /var/lib/cloud/*
waagent -deprovision -force
EOSSH

echo
echo "➡️  Creating an image of base VM and deleting the VM..."
az vm deallocate --resource-group $resource_group --name $base_vm_name
az vm generalize --resource-group $resource_group --name $base_vm_name
az image create --resource-group $resource_group --name $base_image_name --source $base_vm_name

echo "✅  Tool Completed. Exiting..."
