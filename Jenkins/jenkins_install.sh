#!/bin/bash
source /vagrant/.env

echo "Updating apt-get"
sudo apt-get -qq update > /dev/null 2>&1

echo "Installing java"
sudo apt-get -y install openjdk-11-jdk > /dev/null 2>&1

echo "Installing git"
sudo apt-get -y install git > /dev/null 2>&1

echo "Installing jenkins"
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update > /dev/null 2>&1
sudo apt-get -y install jenkins > /dev/null 2>&1


echo "Skipping the initial setup"
echo 'JAVA_ARGS="-Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/home/vagrant/jenkins.yml"' >> /etc/default/jenkins


echo "Setting up users"
sudo rm -rf /var/lib/jenkins/init.groovy.d
sudo mkdir /var/lib/jenkins/init.groovy.d
sudo cp /vagrant/groovy_scripts/init_script.groovy /var/lib/jenkins/init.groovy.d/
sudo cp /vagrant/job_config.xml /home/vagrant
sudo cp /vagrant/credential.xml /home/vagrant
sudo mkdir /var/lib/jenkins/.ssh
sudo cp /vagrant/ssh_keys/id_rsa /var/lib/jenkins/.ssh
sudo cp /vagrant/ssh_keys/id_rsa.pub /var/lib/jenkins/.ssh
sudo chmod 600 /var/lib/jenkins/.ssh/*
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh/


echo "install sshpass"
sudo apt-get install sshpass -y

sudo service jenkins start
sleep 1m


echo "Installing jenkins plugins"
JENKINSPWD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
rm -f jenkins_cli.jar.*
wget -q $JENKINS_HOST_URL/jnlpJars/jenkins-cli.jar
while IFS= read -r line
do
  list=$list' '$line
done < /vagrant/jenkins-plugins.txt
java -jar jenkins-cli.jar -s $JENKINS_HOST_URL -auth $ADMIN_USERNAME:$ADMIN_PASSWORD install-plugin $list

echo "Restarting Jenkins"
sudo service jenkins restart
sleep 1m

echo "create job"
sudo su - jenkins
java -jar jenkins-cli.jar -s $JENKINS_HOST_URL -auth $ADMIN_USERNAME:$ADMIN_PASSWORD create-job $JOB_NAME < job_config.xml
echo "add credential"
java -jar jenkins-cli.jar -s $JENKINS_HOST_URL -auth $ADMIN_USERNAME:$ADMIN_PASSWORD create-credentials-by-xml system::system::jenkins _  < credential.xml
