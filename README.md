# k8s-task4


### Purpose

install Kubernetes and private Docker registry using Vagrant

### Preparation

1. Pre-install Vagrant (https://www.vagrantup.com/docs/installation)
4. Copy config.yaml.example and name config.yaml after set your values

### How to use

1. Use vagrant up

### Additional tasks:

1. Web application for deploy https://github.com/inclemenstv/web_app
2. CICD using Jenkins https://github.com/inclemenstv/Jenkins
3. After vm's created, need to copy openssl key to Jenkins VM using commands:
  - vagrant ssh jenkins 
  - sudo mkdir -p /etc/docker/certs.d/192.168.20.10:5000
  - sudo nano /etc/docker/certs.d/192.168.20.10\:5000/ca.crt and copy past key from /registry/ca.crt
4. In Jenkins dashboard use job webApp 
5. After web application delpoyed, you need to create database and table in Mysql Conteiner
  - ssh vagrant master
  - kubectl get pods
  - kubectl exec -it container_name -- mysql -uroot -padmin
      Commands in db:
      - CREATE DATABASE users;
      - use users;
      - CREATE TABLE `users` (
        `user_id` bigint COLLATE utf8mb4_unicode_ci NOT NULL AUTO_INCREMENT,
        `user_name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
        `user_email` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
         PRIMARY KEY (`user_id`)
        ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
6. After this steps you can check  
  - frontend http://192.168.50.11:30800/ 
  - backend http://192.168.50.11:30500/api/v1/users

