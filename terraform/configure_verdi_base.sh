#!/bin/sh

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

echo "HySDS provisioning script, configuration of Verdi base image"

# In the future, this script should be automatically handled on Mozart's side
# using the sds update command, after the initial installation

echo "➡️  Configuring Verdi..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@"$VERDI_IP" << EOSSH
sudo su -
curl -kL https://github.com/earthobservatory/puppet-autoscale/raw/$PUPPET_BRANCH/install.sh > install_autoscale.sh

screen -dmS queue
screen -S queue -X stuff "yum -y update
"
screen -S queue -X stuff "sh install_autoscale.sh 2>&1 | tee install_autoscale.log
"
screen -S queue -X stuff "sed -i '/DefaultEnvironment/c\DefaultEnvironment=\"AZURE_AUTH_LOCATION=/home/ops/.azure/azure_credentials.json\"' /etc/systemd/system.conf
"
screen -S queue -X stuff "exit
"
EOSSH
echo

# echo "➡️  Pushing Mozart Azure credentials to Verdi..."
# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@"$MOZART_IP" << EOSSH
# scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "~/.ssh/$PRIVATE_KEY_NAME" ~/.azure/azure_credentials.json ops@$VERDI_IP:~/.azure
# scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "~/.ssh/$PRIVATE_KEY_NAME" ~/.azure/config ops@$VERDI_IP:~/.azure
# EOSSH
# echo

echo "➡️  Verdi image creator FQDN is: $VERDI_IP"

echo "✅  Helper script complete. Please verify that the Verdi instance is configured correctly. Exiting..."
