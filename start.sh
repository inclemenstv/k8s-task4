#!/bin/bash


if [ -f ./Jenkins/.env ]
then
  source ./Jenkins/.env
  envsubst < ./Jenkins/job_config.xml.template > ./Jenkins/job_config.xml
  envsubst < ./Jenkins/Vagrantfile.template > Jenkins/Vagrantfile
  envsubst < ./Jenkins/groovy_scripts/init_script.groovy.template > Jenkins/groovy_scripts/init_script.groovy
  envsubst < ./Jenkins/credential.xml.template > Jenkins/credential.xml
else
  echo "You should copy create .env file"
fi


echo "Creating ssh keys"
ssh-keygen -q -N '' -f ./Jenkins/ssh_keys/id_rsa <<<y 2>&1 >/dev/null

if [ -f ./Jenkins/Vagrantfile ]
then
  echo "Creating Jenkins VM"
  cd Jenkins
  vagrant up
fi


echo "Creating kube and docker_registry vm's"
vagrant up