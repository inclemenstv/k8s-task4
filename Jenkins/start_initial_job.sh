#!/bin/bash
source /vagrant/.env


echo "Installing java"
sudo apt-get -y install openjdk-11-jdk > /dev/null 2>&1

echo "Starting initial job"
wget -q $JENKINS_HOST_URL/jnlpJars/jenkins-cli.jar
java -jar jenkins-cli.jar -s $JENKINS_HOST_URL -auth $ADMIN_USERNAME:$ADMIN_PASSWORD build $JOB_NAME