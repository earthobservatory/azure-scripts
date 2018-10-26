#!/bin/sh

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

echo "HySDS provisioning script, final setup and generalization of base VM"

echo "➡️  Configuring base VM for imaging..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@$FQDN <<'EOSSH'
sudo su -
rm -rf /var/lib/cloud/*
waagent -deprovision -force
EOSSH

echo
echo "➡️  Deallocating and generalizing the base VM..."
az vm deallocate --resource-group $AZ_RESOURCE_GROUP --name $AZ_BASE_VM_NAME
az vm generalize --resource-group $AZ_RESOURCE_GROUP --name $AZ_BASE_VM_NAME

echo "✅  Helper script complete. Exiting..."
