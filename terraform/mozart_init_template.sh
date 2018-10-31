#!/bin/sh

chmod 400 ~/.ssh/PRIVATE_KEY_NAME
rm -rf ~/mozart
cd $HOME
git clone https://bitbucket.org/nvgdevteam/hysds-framework.git
cd hysds-framework
./install.sh mozart -d