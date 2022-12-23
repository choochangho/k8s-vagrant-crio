# -*- mode: ruby -*-
# vi: set ft=ruby :
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

OS_V = 'xUbuntu_20.04'                            # OS Version for CRI-O
K8S_V = '1.26.0'                                  # Kubernetes 
CRIO_V = '1.26'                                   # Container Runtine Interface
NODES = 3                                         # Worker Nodes 
APISERVER_ADVERTISE_ADDRESS = "192.168.142.10"    # apiserver address
POD_NETWORK_CIDR = "10.244.0.0/16"                # pod network cidr
MASTER_IP = "192.168.142.10"                      # master(control-plane) server ip

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh", args: [ OS_V, K8S_V, CRIO_V ]

  # Kubernetes Master Server
  config.vm.define "master.k8s" do |node|
    node.vm.box = "generic/ubuntu2204"
    node.vm.box_check_update = false
    node.vm.hostname = "master.k8s"
    node.vm.network "private_network", ip: MASTER_IP
  
    node.vm.provider "virtualbox" do |v|
      v.name = "master"
      v.memory = 4096
      v.cpus = 4
      v.customize ["modifyvm", :id, "--groups", "/k8s-#{K8S_V}-cri-#{CRIO_V}"]
    end
    node.vm.provision "shell", path: "bootstrap_master.sh", args: [ APISERVER_ADVERTISE_ADDRESS, POD_NETWORK_CIDR ]  
  end

  (1..NODES).each do |i|
    config.vm.define "node#{i}.k8s" do |node|
      node.vm.box = "generic/ubuntu2204"
      node.vm.box_check_update = false
      node.vm.hostname = "node#{i}.k8s"
      node.vm.network "private_network", ip: "192.168.142.1#{i}"

      node.vm.provider "virtualbox" do |v|
        v.name = "node#{i}"
        v.memory = 4096
        v.cpus = 2
        v.customize ["modifyvm", :id, "--groups", "/k8s-#{K8S_V}-cri-#{CRIO_V}"]
      end
      node.vm.provision "shell", path: "bootstrap_node.sh", args: [ MASTER_IP ]
    end
  end
end