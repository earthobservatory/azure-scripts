#!/bin/sh

# Trap for ctrl-c
trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

echo "HySDS provisioning script, autoconfiguration of instances"

echo "➡️  Configuring CI..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@"$CI_IP" << EOSSH
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://github.com/earthobservatory/puppet-cont_int/raw/$PUPPET_BRANCH/install.sh > install_ci.sh
screen -d -m bash -c "yum -y update; bash install_ci.sh 2>&1 | tee install_ci.log"
EOSSH
echo

echo "➡️  Configuring Factotum..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@"$FACTOTUM_IP" << EOSSH
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://github.com/earthobservatory/puppet-factotum/raw/$PUPPET_BRANCH/install.sh > install_factotum.sh
screen -d -m bash -c "yum -y update; bash install_factotum.sh 2>&1 | tee install_factotum.log"
EOSSH
echo

echo "➡️  Configuring Metrics..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@"$METRICS_IP" << EOSSH
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://github.com/earthobservatory/puppet-metrics/raw/$PUPPET_BRANCH/install.sh > install_metric.sh
screen -d -m bash -c "yum -y update; bash install_metric.sh 2>&1 | tee install_metric.log"
EOSSH
echo

echo "➡️  Configuring GRQ..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@"$GRQ_IP" << EOSSH
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://github.com/earthobservatory/puppet-grq/raw/$PUPPET_BRANCH/install.sh > install_grq.sh
screen -d -m bash -c "yum -y update; bash install_grq.sh 2>&1 | tee install_grq.log"
EOSSH
echo

echo "➡️  Copying private key to Mozart instance..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" "$PRIVATE_KEY_PATH" ops@"$MOZART_IP":~/.ssh
echo

echo "➡️  Copying auto setup script to Mozart instance..."
sed "s/PRIVATE_KEY_NAME/${PRIVATE_KEY_NAME}/g" mozart_init_template.sh > mozart_init.sh
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" mozart_init.sh ops@"$MOZART_IP":~
rm mozart_init.sh
echo

echo "➡️  Copying HTTPS automatic setup script to Mozart instance..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" ../shell/https_autoconfig.sh ops@"$MOZART_IP":~
echo

echo "➡️  Copying HTTPS automatic setup script to GRQ instance..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" ../shell/https_autoconfig.sh ops@"$GRQ_IP":~
echo

echo "➡️  Copying HTTPS automatic setup script to Metrics instance..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" ../shell/https_autoconfig.sh ops@"$METRICS_IP":~
echo

echo "➡️  Configuring Mozart..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$PRIVATE_KEY_PATH" -T ops@"$MOZART_IP" << EOSSH
sudo su -
growpart /dev/sda 2
xfs_growfs -d /dev/sda2
curl -kL https://github.com/earthobservatory/puppet-mozart/raw/$PUPPET_BRANCH/install.sh > install_mozart.sh
screen -d -m bash -c "yum -y update; bash install_mozart.sh 2>&1 | tee install_mozart.log; su -c \"sh /home/ops/mozart_init.sh >> /home/ops/mozart_init.log\" - ops"
EOSSH
echo

echo "✅  Helper script complete. Do note the VMs are STILL being configured asynchronously. Please further configure the cluster after the automated configuration has finished"
