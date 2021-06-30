require 'yaml'
config = YAML.load_file 'config.yaml'

#kubernetes variables
IMAGE_NAME = config['k8s_SETTINGS']['IMAGE_NAME']
MASTER_IP  = config['k8s_SETTINGS']['MASTER_IP']
NODE_IP    = config['k8s_SETTINGS']['NODE_IP']
MASTER_MEMORY  = config['VM_SETTINGS']['MASTER_MEMORY']
MASTER_CPU     = config['VM_SETTINGS']['MASTER_CPU']
NODE_MEMORY    = config['VM_SETTINGS']['NODE_MEMORY']
NODE_CPU       = config['VM_SETTINGS']['NODE_CPU']

#docker registry variables
REGISTRY_IP      = config['Docker_registry']['REGISTRY_IP']
USER_NAME        = config['Docker_registry']['USER_NAME']
USER_PASSWORD    = config['Docker_registry']['USER_PASSWORD']
REGISTRY_HOST    = config['Docker_registry']['HOST']


Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

    config.vm.define "docker_registry" do |docker|
       docker.vm.box = IMAGE_NAME
       docker.vm.network "private_network", ip: REGISTRY_IP
       docker.vm.hostname = "registry"
       docker.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
    end
       docker.vm.provision :shell, privileged: true, inline: $install_docker
       docker.vm.provision :shell, env: {"REGISTRY_IP" => REGISTRY_IP, "USER_NAME" => USER_NAME, "USER_PASSWORD" => USER_PASSWORD, "REGISTRY_HOST" => REGISTRY_HOST }, privileged: true, inline: $config_registry
end

    config.vm.define "node" do |node|
       node.vm.box = IMAGE_NAME
       node.vm.network "private_network", ip: NODE_IP
       node.vm.hostname = "node"
       node.vm.provider "virtualbox" do |v|
        v.memory = NODE_MEMORY
        v.cpus = NODE_CPU
    end
       node.vm.provision :shell, privileged: true, inline: $install_basic
       node.vm.provision :shell, env: {"NODE_IP" => NODE_IP,"REGISTRY_IP" => REGISTRY_IP}, privileged: true, inline: $setup_nodeIP
  end

    config.vm.define "master" do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network "private_network", ip: MASTER_IP
        master.vm.hostname = "master"
        master.vm.provider "virtualbox" do |v|
         v.memory = MASTER_MEMORY
         v.cpus = MASTER_CPU
    end
        master.vm.provision :shell, privileged: true, inline: $install_basic
        master.vm.provision :shell, env: {"MASTER_IP" => MASTER_IP,"NODE_IP" => NODE_IP}, privileged: false, inline: $install_master
        master.vm.provision :shell, env: {"MASTER_IP" => MASTER_IP,"REGISTRY_IP" => REGISTRY_IP}, privileged: true, inline: $setup_masterIP
    end

end

########################------------Kubernetes scripts---------##########################

$install_basic = <<-SCRIPT
echo "Updating apt-get"
sudo apt-get -qq update

echo "Installing packages"
sudo apt-get -y install \
apt-transport-https \
ca-certificates \
url \
gnupg \
lsb-release > /dev/null 2>&1

echo "Add Docker’s official GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null

echo "Set up the stable repository."
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker"
sudo apt-get update > /dev/null 2>&1
sudo apt-get -y install docker-ce docker-ce-cli containerd.io > /dev/null 2>&1

echo "Add vagrant user to docker group"
sudo usermod -aG docker vagrant

echo "Start docker service"
sudo service docker start

echo "Disable swap and remove from fstab"
swapoff -a
sed -i '/swap/d' /etc/fstab

echo "Download the Google Cloud public signing key"
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "Add the Kubernetes apt repository"
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "Installing packages"
sudo apt-get -qq update
sudo apt-get -y install \
kubelet \
kubeadm \
kubectl > /dev/null 2>&1

        cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker

SCRIPT

$install_master = <<-SCRIPT
echo "Creating cluster"
sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=10.244.0.0/16
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config
echo "install flannel"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
echo "set namespace"
kubectl config set-context --current --namespace=default
echo "save join command"
echo "install sshpass"
sudo apt-get install sshpass -y
echo "Adding worker node"
join=$(kubeadm token create --print-join-command)
sshpass -p vagrant ssh -tt -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@$NODE_IP << EOF
sudo $join
exit
EOF

SCRIPT


$setup_nodeIP = <<-SCRIPT
echo "Environment='KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP'" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sleep 20

echo "adding ca.crt"
sudo mkdir -p "/etc/docker/certs.d/$REGISTRY_IP:5000"
sudo cat /vagrant/registry/ca.crt > /etc/docker/certs.d/$REGISTRY_IP:5000/ca.crt

SCRIPT

$setup_masterIP = <<-SCRIPT
echo "Environment='KUBELET_EXTRA_ARGS=--node-ip=$MASTER_IP'" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sleep 20

echo "adding ca.crt"
sudo mkdir -p "/etc/docker/certs.d/$REGISTRY_IP:5000"
sudo cat /vagrant/registry/ca.crt > /etc/docker/certs.d/$REGISTRY_IP:5000/ca.crt

SCRIPT


########################------------Private Docker registry scripts---------##########################
$install_docker = <<-SCRIPT
echo "Updating apt-get"
sudo apt-get -qq update
echo "Installing packages"
sudo apt-get -y install \
apt-transport-https \
ca-certificates \
url \
gnupg \
lsb-release > /dev/null 2>&1
echo "Add Docker’s official GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
echo "Set up the stable repository."
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "Installing Docker"
sudo apt-get update > /dev/null 2>&1
sudo apt-get -y install docker-ce docker-ce-cli containerd.io > /dev/null 2>&1

echo "Start docker service"
sudo service docker start

SCRIPT

$config_registry = <<-SCRIPT
#!/bin/bash
OUTPUT_CA=/vagrant/registry/ca.crt

sudo sed -i "/v3_ca/a subjectAltName = IP:$REGISTRY_IP"  /etc/ssl/openssl.cnf

echo "Creating working dir"
mkdir /home/vagrant/registry
cd /home/vagrant/registry

echo "genereting certificate"
sudo openssl req -x509 -nodes -sha256 -newkey rsa:4096 -keyout registry.key -out registry.crt -days 14 -subj "/CN=$REGISTRY_IP" > /dev/null 2>&1

sudo cat registry.crt > ${OUTPUT_CA}

echo "copying certs"
sudo mkdir -p "/etc/docker/certs.d/$REGISTRY_IP:5000"
sudo cp /home/vagrant/registry/registry.crt "/etc/docker/certs.d/$REGISTRY_IP:5000"

echo "restarting docker"
sudo systemctl restart docker
sudo sleep 10


echo "creating credentials"
cd /home/vagrant/registry
sudo docker run --rm --entrypoint htpasswd registry:2.7.0 -Bbn $USER_NAME $USER_PASSWORD > htpasswd

echo "copying and config docker registry config"
sudo cp /vagrant/registry/config.yml /home/vagrant/registry
sudo sed -i "s/host:/host: $REGISTRY_HOST/" /home/vagrant/registry/config.yml

echo "copying Dockerfile"
sudo cp /vagrant/registry/Dockerfile /home/vagrant/registry

echo "Building registry"
cd /home/vagrant/registry
sudo docker build -t local-registry .

echo "run registry"
sudo docker run -d -p 5000:5000 --name registry --restart always local-registry
SCRIPT

