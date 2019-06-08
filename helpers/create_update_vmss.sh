#!/bin/bash

# This script allows you to create or update your Azure VMSS
# (virtual machine scale set) by defining a few constants
# This functionality should eventually be written into sdscli

QUEUE_NAME="aria-job_worker_small"              # Queue name which determines machine size
VMSS_SKU="Standard_F8s_v2"                      # Desired machine type
VM_SIZE="s"                                     # Size of VM, small or large (s/l) which will determine the usage of storage disks

# Define the parameters of your Azure system here
AZ_RESOURCE_GROUP="HySDS_Prod_Terra"            # Name of the resource group
BASE_VM_NAME="VerdiImageCreatorProdTerra"       # Name of the base VM used to create the image
STORAGE_ACCOUNT_NAME="hysdsprodterra"           # Name of the storage account
VMSS_NAME="$QUEUE_NAME"                         # Desired name of the scale set
AZURE_VNET="HySDS_VNet_Prod_Terra"              # The vnet of your cluster
SUBNET_NAME="HySDS_Subnet_Prod_Terra"           # The subnet of your cluster
NSG_NAME="HySDS_NSG_Prod_Terra"                 # The NSG of your cluster
VERDI_IMAGE_NAME="HySDS_Verdi_2019-02-06-rc3"   # The name for the image
SUBSCRIPTION_ID="{{ SUBSCRIPTION_ID }}"         # Get this from ~/.azure/azure_credentials.json

# Value of the public key derived from the private key, change id_rsa if necessary
SSH_PUBKEY_VAL=$(ssh-keygen -y -f ~/.ssh/id_rsa)

echo "HySDS Azure-specific tool, 🛠 Create/Update Virtual Machine Scale Set🛠 "
echo

read -r -e -p "⌨️  Create or update VMSS (c/u)? " OPTION

if [ "$OPTION" = "c" ]; then
  echo "Resource Group Name: $AZ_RESOURCE_GROUP"
  echo "Virtual Net Name: $AZURE_VNET"
  echo "Subnet Name: $SUBNET_NAME"
  echo "NSG Name: $NSG_NAME"
  echo
  echo "Verdi Image Creator VM Name: $BASE_VM_NAME"
  echo "Desired Verdi Image Name: $VERDI_IMAGE_NAME"
  echo "Desired Scale Set Name: $VMSS_NAME"
  echo "Desired Scale Set VM type: $VMSS_SKU"
  echo
  read -n 1 -s -r -p "⌨️  Check if the above information is correct and press any key to continue..."
  # Create the VMSS
  echo BUNDLE_URL=azure://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/code/$QUEUE_NAME-ops.tbz2 > bundleurl.txt
  if [ "$VM_SIZE" = "s" ]; then
    # A small VM will need a decently sized data disk
    az vmss create --custom-data bundleurl.txt --location southeastasia \
                   --resource-group "$AZ_RESOURCE_GROUP" --name "$VMSS_NAME" --vm-sku "$VMSS_SKU" \
                   --admin-username ops --authentication-type ssh --ssh-key-value "$SSH_PUBKEY_VAL" \
                   --instance-count 0 --single-placement-group true --priority low \
                   --data-disk-sizes-gb 128 --data-disk-caching ReadWrite --storage-sku StandardSSD_LRS \
                   --vnet-name "$AZURE_VNET" --subnet "$SUBNET_NAME" --nsg "$NSG_NAME" --public-ip-per-vm --lb "" \
                   --image "$VERDI_IMAGE_NAME" --eviction-policy delete
  elif [ "$VM_SIZE" = "l" ]; then
    # If the VM is big enough, skip data disk generation
    az vmss create --custom-data bundleurl.txt --location southeastasia \
                   --resource-group "$AZ_RESOURCE_GROUP" --name "$VMSS_NAME" --vm-sku "$VMSS_SKU" \
                   --admin-username ops --authentication-type ssh --ssh-key-value "$SSH_PUBKEY_VAL" \
                   --instance-count 0 --single-placement-group true --priority low --storage-sku StandardSSD_LRS \
                   --vnet-name "$AZURE_VNET" --subnet "$SUBNET_NAME" --nsg "$NSG_NAME" --public-ip-per-vm --lb "" \
                   --image "$VERDI_IMAGE_NAME" --eviction-policy delete
  fi
  rm -f bundleurl.txt
  echo "✅  Creation complete!"
elif [ "$OPTION" = "u" ]; then
  echo "Resource Group Name: $AZ_RESOURCE_GROUP"
  echo "Virtual Machine Scale Set Name: $VMSS_NAME"
  echo "Subscription ID: $SUBSCRIPTION_ID"
  echo
  echo "New Verdi Image Name: $VERDI_IMAGE_NAME"
  echo
  read -n 1 -s -r -p "⌨️  Check if the above information is correct and press any key to continue..."
  # Update the VMSS
  az vmss update --resource-group $AZ_RESOURCE_GROUP --name $VMSS_NAME --set virtualMachineProfile.storageProfile.imageReference.id=/subscriptions/"$SUBSCRIPTION_ID"/resourceGroups/$AZ_RESOURCE_GROUP/providers/Microsoft.Compute/images/$VERDI_IMAGE_NAME
  echo "✅  Update complete!"
else
  echo "Invalid input. Aborting"
fi
