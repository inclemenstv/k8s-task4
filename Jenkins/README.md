# PipelineWithDocker

### Purpose

1. Creating a test environment (Vagrantfile have 2 VM with Jenkins and VM for deploy)
2. Jenkins is automatically installed, as well as configuration and pipeline are created


### Preparation

1. Pre-install Vagrant (https://www.vagrantup.com/docs/installation)
2. Create .env files and copy the contents of .env.example into them
3. Set your values to variables in the .env file
4. You need to create a repository in dockerhub

### How to use

1. Use script to generate config files  ./create_config_files.sh
2. Use command vagrant up to create both VM
3. Login to Jenkins JENKINS_HOST:8080 use your credentials
   
