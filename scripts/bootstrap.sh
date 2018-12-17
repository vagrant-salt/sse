#!/bin/bash
fqdn=$1
proxy=$2

echo "@@@ starting bootstrap computer: $fqdn"
sudo echo "$fqdn" > /etc/hostname
sudo echo "HOSTNAME=$fqdn" >> /etc/sysconfig/network
sudo hostname $fqdn
sudo service NetworkManager restart
if [[ $proxy ]]; then
    sudo echo "proxy=$proxy" >> /etc/yum.conf
fi
sudo yum install epel-release -y
sudo yum install git jq -y
#sudo yum update -y
if [[ $proxy ]]; then
    sudo git config --global http.proxy $proxy
fi
#sudo service firewalld stop
#sudo sed -i /etc/selinux/config -r -e 's/^SELINUX=.*/SELINUX=disabled/g'
echo "@@@ finished bootstrap computer: $fqdn"
