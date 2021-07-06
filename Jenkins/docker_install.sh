#!/bin/bash
source /vagrant/.env

echo "Updating apt-get"
sudo apt-get -qq update

echo "Installing packages"
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "Add Docker’s official GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Set up the stable repository."
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker"
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

user=`sudo cat /etc/passwd | awk -F ':' '{print $1}' | grep jenkins`

if [ "$user" = "jenkins" ]
then
echo "Adding jenkins user to group docker"
sudo usermod -a -G docker jenkins
sudo service jenkins restart
sleep 1m
fi


