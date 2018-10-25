#!/bin/sh

# This bash script performs automatic provisioning of a HySDS system on Azure with test credentials and small scale virtual machines
# This bash script is PHASE 2, which creates the base VM image

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

# Import envvars from external file
source envvars.sh

echo "HySDS provisioning tool, 💿PHASE 2 (creation of base VM image)💿"

echo
read -e -p "⌨️  Please generate and paste the absolute path (with escape sequences) of a private key here and press enter: " PRIVATE_KEY_PATH
export PUBLIC_KEY=$(cat "$PRIVATE_KEY_PATH.pub")

echo
echo "➡️  Creating base virtual machine..."
if [ PYTHON_VERSION = "3" ]; then
  export BASE_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_BASE_VM_NAME --image OpenLogic:CentOS:7.5:7.5.20180815 --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print(json.load(sys.stdin)['publicIpAddress'])"` # Retrieves public IP address
else
  export BASE_IP=`az vm create --resource-group $AZ_RESOURCE_GROUP --name $AZ_BASE_VM_NAME --image OpenLogic:CentOS:7.5:7.5.20180815 --admin-username ops --ssh-key-value "$PUBLIC_KEY" | \
  python -c "import sys, json; print json.load(sys.stdin)['publicIpAddress']"` # Retrieves public IP address
fi

echo "➡️  Base virtual machine has the IP $BASE_IP"

echo
echo "➡️  Automatically configuring base virtual machine..."
ssh -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" -T ops@$BASE_IP <<'EOSSH'
sudo su -
sed -i 's/enforcing/disabled/g' /etc/selinux/config
yum install -y epel-release
yum -y update
yum -y install puppet puppet-firewalld nscd ntp wget curl subversion git vim screen cloud-utils-growpart
yum clean all
rm -rf /var/lib/cloud/*
waagent -deprovision -force
EOSSH

echo "➡️  FYI: You may now SSH into the machine using the command ssh -i \"$PRIVATE_KEY_PATH\" ops@$BASE_IP"
read -n 1 -s -r -p "⌨️  Check if the configuration procedures were successful. If successful, press any key to continue, else, SSH into the machine and reconfigure it manually..."

echo
echo "➡️  Creating an image of base VM and deleting the VM..."
az vm deallocate --resource-group $AZ_RESOURCE_GROUP --name $AZ_BASE_VM_NAME
az vm generalize --resource-group $AZ_RESOURCE_GROUP --name $AZ_BASE_VM_NAME
az image create --resource-group $AZ_RESOURCE_GROUP --name $AZ_BASE_IMAGE_NAME --source $AZ_BASE_VM_NAME

echo "✅  Tool Completed. Exiting..."
