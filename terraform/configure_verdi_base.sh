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
curl -kL https://bitbucket.org/nvgdevteam/puppet-autoscale/raw/master/install.sh > install_autoscale.sh
screen -d -m bash -c "yum -y update; sh install_autoscale.sh 2>&1 | tee install_autoscale.log; sed -i \"s/c.virtual_machine_scale_sets.list('HySDS')/c.virtual_machine_scale_sets.list('$AZ_RESOURCE_GROUP')/g\" /etc/systemd/system/harikiri.d/harikiri.py; sed -i \"s/as_group = 'vmss'/as_group = '$VMSS'/g\" /etc/systemd/system/harikiri.d/harikiri.py; sed -i \"s/c.virtual_machine_scale_set_vms.delete('HySDS',as_group,id)/c.virtual_machine_scale_set_vms.delete('$AZ_RESOURCE_GROUP',as_group,id)/g\" /etc/systemd/system/harikiri.d/harikiri.py; sed -i \"s/instances = c.virtual_machine_scale_set_vms.list('HySDS',as_group)/instances = c.virtual_machine_scale_set_vms.list('$AZ_RESOURCE_GROUP',as_group)/g\" /etc/systemd/system/harikiri.d/harikiri.py"
EOSSH
echo

echo "➡️  Verdi image creator FQDN is: $VERDI_IP"

echo "✅  Helper script complete. Please verify that the Verdi instance is configured correctly. Exiting..."
