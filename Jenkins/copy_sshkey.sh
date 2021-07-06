#!/bin/bash

sudo cp /vagrant/ssh_keys/id_rsa.pub /home/vagrant
pubkey=`cat id_rsa.pub`
sudo echo "$pubkey" >> /home/vagrant/.ssh/authorized_keys

sudo sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
sudo systemctl restart sshd.service
echo "finished"