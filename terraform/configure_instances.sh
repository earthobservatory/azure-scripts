#!/bin/sh

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

echo "HySDS provisioning script, configuration of instances"

echo "➡️  Configuring CI..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@$CI_IP <<'EOSSH'
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-cont_int/raw/master/install.sh > install_ci.sh
screen -d -m bash -c "bash install_ci.sh 2>&1 | tee install_ci.log"
EOSSH
echo

echo "➡️  Configuring Factotum..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@$FACTOTUM_IP <<'EOSSH'
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-factotum/raw/master/install.sh > install_factotum.sh
screen -d -m bash -c "bash install_factotum.sh 2>&1 | tee install_factotum.log"
EOSSH
echo

echo "➡️  Configuring Metrics..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@$METRICS_IP <<'EOSSH'
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-metrics/raw/master/install.sh > install_metric.sh
screen -d -m bash -c "bash install_metric.sh 2>&1 | tee install_metric.log"
EOSSH
echo

echo "➡️  Configuring GRQ..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@$GRQ_IP <<'EOSSH'
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-grq/raw/master/install.sh > install_grq.sh
curl -kL https://bitbucket.org/nvgdevteam/puppet-grq/raw/master/esdata.sh > install_esdata.sh
screen -d -m bash -c "bash install_grq.sh 2>&1 | tee install_grq.log; bash install_esdata.sh 2>&1 | tee install_esdata.log"
EOSSH
echo

echo "➡️  Copying private key to Mozart instance..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" "$PRIVATE_KEY_PATH" ops@$MOZART_IP:~/.ssh
echo

echo "➡️  Configuring Mozart..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@$MOZART_IP << EOSSH
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://bitbucket.org/nvgdevteam/puppet-mozart/raw/master/install.sh > install_mozart.sh
bash install_mozart.sh 2>&1 | tee install_mozart.log
exit
chmod 400 ~/.ssh/$PRIVATE_KEY_NAME
rm -rf ~/mozart
cd \$HOME
git clone https://bitbucket.org/nvgdevteam/hysds-framework.git
cd hysds-framework
./install.sh mozart -d
EOSSH
echo

echo "✅  Helper script complete. Exiting..."
