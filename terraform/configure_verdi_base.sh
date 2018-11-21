#!/bin/sh

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

echo "HySDS provisioning script, configuration of Verdi base image"

echo "➡️  Configuring Verdi..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@$VERDI_IP << EOSSH
sudo su -
curl -kL https://github.com/d3lta-v/puppet-autoscale/raw/master/install.sh > install_autoscale.sh

screen -dmS queue
screen -S queue -X stuff "yum -y update
"
screen -S queue -X stuff "sh install_autoscale.sh 2>&1 | tee install_autoscale.log
"
screen -S queue -X stuff "sed -i \"s/c.virtual_machine_scale_sets.list('HySDS')/c.virtual_machine_scale_sets.list('$AZ_RESOURCE_GROUP')/g\" /etc/systemd/system/harikiri.d/harikiri.py
"
screen -S queue -X stuff "sed -i \"s/as_group = 'vmss'/as_group = '$VMSS'/g\" /etc/systemd/system/harikiri.d/harikiri.py
"
screen -S queue -X stuff "sed -i \"s/c.virtual_machine_scale_set_vms.delete('HySDS',as_group,id)/c.virtual_machine_scale_set_vms.delete('$AZ_RESOURCE_GROUP',as_group,id)/g\" /etc/systemd/system/harikiri.d/harikiri.py
"
screen -S queue -X stuff "sed -i \"s/instances = c.virtual_machine_scale_set_vms.list('HySDS',as_group)/instances = c.virtual_machine_scale_set_vms.list('$AZ_RESOURCE_GROUP',as_group)/g\" /etc/systemd/system/harikiri.d/harikiri.py
"
screen -S queue -X stuff "sed -i '/DefaultEnvironment/c\DefaultEnvironment=\"AZURE_AUTH_LOCATION=/home/ops/.azure/azure_credentials.json\"' /etc/systemd/system.conf
"
screen -S queue -X stuff "exit
"
EOSSH
echo

# echo "➡️  Pushing Mozart Azure credentials to Verdi..."
# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@$MOZART_IP << EOSSH
# scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "~/.ssh/$PRIVATE_KEY_NAME" ~/.azure/azure_credentials.json ops@$VERDI_IP:~/.azure
# scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "~/.ssh/$PRIVATE_KEY_NAME" ~/.azure/config ops@$VERDI_IP:~/.azure
# EOSSH
# echo

# Might want to add commands to push credentials from Mozart to Verdi

echo "➡️  Verdi image creator FQDN is: $VERDI_IP"

echo "✅  Helper script complete. Please verify that the Verdi instance is configured correctly. Exiting..."
