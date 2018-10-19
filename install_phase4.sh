#!/bin/sh

# This bash script performs configuration of the HySDS cluster
# This bash script is PHASE 4, which configures individual HySDS components

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

# Import envvars from external file
source envvars.sh

echo "HySDS provisioning tool, 🛠 PHASE 4 (configuration of the HySDS cluster)🛠 "

echo
read -e -p "⌨️  Please paste the absolute path (with escape sequences) of the private key here and press enter: " PRIVATE_KEY_PATH
export PUBLIC_KEY=$(cat "$PRIVATE_KEY_PATH.pub")

read -e -p "⌨️  Please paste the IP address of the Mozart instance here and press enter: " MOZART_IP
read -e -p "⌨️  Please paste the IP address of the Metrics instance here and press enter: " METRICS_IP
read -e -p "⌨️  Please paste the IP address of the GRQ instance here and press enter: " GRQ_IP
read -e -p "⌨️  Please paste the IP address of the Factotum instance here and press enter: " FACTOTUM_IP
read -e -p "⌨️  Please paste the IP address of the CI instance here and press enter: " CI_IP

echo
echo "➡️  Configuring Puppet modules for Metrics..."
ssh -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" -T ops@$METRICS_IP <<'EOSSH'
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-metrics/raw/master/install.sh > install_metric.sh
screen -d -m bash -c "bash install_metric.sh 2>&1 | tee install_metric.log"
EOSSH

echo "➡️  FYI: You may now SSH into the machine using the command ssh -i \"$PRIVATE_KEY_PATH\" ops@$METRICS_IP"
read -n 1 -s -r -p "⌨️  Metrics configuration complete, please check the VM manually if necessary, and press any key to continue..."

echo
echo "➡️  Configuring Puppet modules for GRQ..."
ssh -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" -T ops@$GRQ_IP <<'EOSSH'
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-grq/raw/master/install.sh > install_grq.sh
curl -kL https://bitbucket.org/nvgdevteam/puppet-grq/raw/master/esdata.sh > install_esdata.sh
screen -d -m bash -c "bash install_grq.sh 2>&1 | tee install_grq.log; bash install_esdata.sh 2>&1 | tee install_esdata.log"
EOSSH

echo "➡️  FYI: You may now SSH into the machine using the command ssh -i \"$PRIVATE_KEY_PATH\" ops@$GRQ_IP"
read -n 1 -s -r -p "⌨️  GRQ configuration complete, please check the VM manually if necessary, and press any key to continue..."

echo
echo "➡️  Configuring Puppet modules for Factotum..."
ssh -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" -T ops@$FACTOTUM_IP <<'EOSSH'
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-factotum/raw/master/install.sh > install_factotum.sh
screen -d -m bash -c "bash install_factotum.sh 2>&1 | tee install_factotum.log"
EOSSH

echo "➡️  FYI: You may now SSH into the machine using the command ssh -i \"$PRIVATE_KEY_PATH\" ops@$FACTOTUM_IP"
read -n 1 -s -r -p "⌨️  Factotum configuration complete, please check the VM manually if necessary, and press any key to continue..."

echo
echo "➡️  Configuring Puppet modules for CI..."
ssh -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" -T ops@$CI_IP <<'EOSSH'
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-cont_int/raw/master/install.sh > install_ci.sh
screen -d -m bash -c "bash install_ci.sh 2>&1 | tee install_ci.log"
EOSSH

echo "➡️  FYI: You may now SSH into the machine using the command ssh -i \"$PRIVATE_KEY_PATH\" ops@$CI_IP"
read -n 1 -s -r -p "⌨️  CI configuration complete, please check the VM manually if necessary, and press any key to continue..."

echo
echo "➡️  Copying private key to Mozart instance..."
scp -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" "$PRIVATE_KEY_PATH" ops@$MOZART_IP:~/.ssh
echo "➡️  Configuring Puppet modules for Mozart..."
ssh -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" -T ops@$MOZART_IP <<'EOSSH'
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-mozart/raw/master/install.sh > install_mozart.sh
bash install_mozart.sh 2>&1 | tee install_mozart.log
EOSSH

echo "➡️  FYI: You may now SSH into the machine using the command ssh -i \"$PRIVATE_KEY_PATH\" ops@$MOZART_IP"
read -n 1 -s -r -p "⌨️  Mozart configuration complete, please check the VM manually if necessary, and press any key to continue (warning: next section may take 10 minutes or more!)..."

# The following code below is just for reference. Don't uncomment it.
# echo "All VMs created. Please SSH into every VM using \"ssh -i $PRIVATE_KEY_PATH ops@[HYSDS_COMPONENT_IP]\" (without quotes) and execute the following commands on the remote machines: "
# echo "$ sudo su -"
# echo "# growpart /dev/sda 2"
# echo "# xfs_growfs -d /dev/sda2"
# echo "Additionally, for each instance, manually provision Puppet modules with: "
# echo "Mozart: bash < <(curl -skL https://bitbucket.org/nvgdevteam/puppet-mozart/raw/master/install.sh)"
# echo "Metrics: bash < <(curl -skL https://bitbucket.org/nvgdevteam/puppet-metrics/raw/master/install.sh)"
# echo "GRQ: bash < <(curl -skL https://bitbucket.org/nvgdevteam/puppet-grq/raw/master/install.sh); bash < <(curl -skL https://bitbucket.org/nvgdevteam/puppet-grq/raw/master/esdata.sh)"
# echo "Factotum: bash < < curl -skL https://bitbucket.org/nvgdevteam/puppet-factotum/raw/master/install.sh)"
# echo "CI: bash < <(curl -skL https://bitbucket.org/nvgdevteam/puppet-cont_int/raw/master/install.sh)"
# echo "...and disconnect from the machines."
# read -n 1 -s -r -p "Press any key to continue after disconnecting from all of the remote machines..."

echo "➡️  Installing HySDS framework on Mozart..."
export PRIVATE_KEY_NAME=$(basename "$PRIVATE_KEY_PATH")
ssh -o StrictHostKeyChecking=no -i "$PRIVATE_KEY_PATH" -T ops@$MOZART_IP << EOSSH
chmod 400 ~/.ssh/$PRIVATE_KEY_NAME
rm -rf ~/mozart
cd \$HOME
git clone https://bitbucket.org/nvgdevteam/hysds-framework.git
cd hysds-framework
./install.sh mozart -d
EOSSH

echo "➡️  Command to access Mozart is ssh -i \"$PRIVATE_KEY_PATH\" ops@$MOZART_IP"
echo "⌨️  HySDS framework installation complete. Please configure the HySDS cluster manually with the following commands: "
echo "$ cd ~"
echo "$ source ~/mozart/bin/activate"
echo "$ sds configure"
echo "...and refer to the NTU-EOS_HySDS-Installation-on-Azure document on specific parameters to fill in."
echo

echo "✅  Tool Completed. Exiting..."
