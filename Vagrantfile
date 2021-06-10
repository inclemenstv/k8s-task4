require 'yaml'
config = YAML.load_file 'config.yaml'

IMAGE_NAME = config['k8s_SETTINGS']['IMAGE_NAME']
MASTER_IP  = config['k8s_SETTINGS']['MASTER_IP']
NODE_IP    = config['k8s_SETTINGS']['NODE_IP']

VM_MEMORY  = config['VM_SETTINGS']['MEMORY']
VM_CPU     = config['VM_SETTINGS']['CPU']

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

    config.vm.provider "virtualbox" do |v|
        v.memory = VM_MEMORY
        v.cpus = VM_CPU
    end

    config.vm.define "k8s-master" do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network "private_network", ip: MASTER_IP
        master.vm.hostname = "k8s-master"
        master.vm.provision :shell, privileged: true, inline: $install_docker
        master.vm.provision :shell, privileged: true, inline: $install_master

    end

        config.vm.define "node-1" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: NODE_IP
            node.vm.hostname = "node-1"
  end
end

$install_docker = <<-SCRIPT
        echo "Updating apt-get"
        sudo apt-get -qq update

        echo "Installing packages"
        sudo apt-get -y install \
        apt-transport-https \
        ca-certificates \
        url \
        gnupg \
        lsb-release

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
SCRIPT

$install_master = <<-SCRIPT
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
        kubectl

        sudo kubeadm init --apiserver-advertise-address=$node_ip --pod-network-cidr=192.168.0.0/16

        echo "Configure kubectl"
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config


SCRIPT