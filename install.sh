#!/bin/bash
#jtl server install script for Centos 7/8
servername=$(hostname)

if (( $EUID != 0 )); then
    echo "Please run this script as root"
    exit 0
fi

rm -f /root/.ssh/id_ed25519
rm -f /root/.ssh/id_ed25519.pub
ssh-keygen -o -a 200 -t ed25519 -f /root/.ssh/id_ed25519 -q -N "" -C "${servername} github puppet deployment"

echo "Enter the following pub key to https://github.com/joseftsch/puppet/settings/keys:"
cat /root/.ssh/id_ed25519.pub
echo ""
read -p "Press any key once key added to continue with setup .. " -n1 -s
echo ""

yum clean all
#lets not use puppet6 for now ...
#rpm -Uvh https://yum.puppet.com/puppet6-release-el-8.noarch.rpm
rpm -Uvh https://yum.puppet.com/puppet5-release-el-8.noarch.rpm
yum install puppet-agent git -y

rm -rf /etc/puppetlabs/code
cd /etc/puppetlabs/
git clone git@github.com:joseftsch/puppet.git code

#run puppet
while true; do
    read -p "Do you wish to run puppet? (y/n)" yn
    case $yn in
        [Yy]* ) /opt/puppetlabs/bin/puppet apply -l /var/log/puppetlabs/puppet/puppet.log < /dev/null; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#reboot
while true; do
    read -p "Do you wish to reboot? (y/n)" yn
    case $yn in
        [Yy]* ) reboot; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done