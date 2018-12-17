#!/bin/sh
computer=$1
saltmasterDNS=$2
echo "@@@ starting setup up salt on $computer"
# use the latest stable Salt from repo.saltstack.com
yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm  -y
sudo yum clean expire-cache -y
sudo yum update -y
sudo yum install salt-minion -y
sudo echo "master: $saltmasterDNS" > /etc/salt/minion
sudo echo "master_alive_interval: 10" >> /etc/salt/minion
sudo service salt-minion restart || true
# setup top files to test the formula
sudo mkdir -p /srv/pillar
#sudo ln -s /srv/salt/pillar.example /srv/pillar/salt.sls
#sudo ln -s /srv/salt/dev/pillar_top.sls /srv/pillar/top.sls
# this file will be copied to make a running config. it should not be checked in.
#sudo cp /srv/salt/dev/state_top.sls /srv/salt/top.sls
# Accept all keys#
#sleep 15 #give the minion a few seconds to register
#sudo salt-key -y -A
echo "@@@ finished setup salt on $computer"
