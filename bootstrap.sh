#!/bin/bash

# ubuntu 22.04, kubernetes 1.25, CRIO
# https://andrewpage.tistory.com/234
# https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/install-cri-o-on-ubuntu-22-04.html

echo "[TASK 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[TASK 4] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

apt -qq update >/dev/null 2>&1
apt install -qq -y apt-transport-https ca-certificates curl gnupg2 software-properties-common >/dev/null 2>&1

echo "[TASK 5] Install CRIO runtime"
curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$1/Release.key | \
gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg >/dev/null 2>&1
curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$3/$1/Release.key | \
gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg >/dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$1/ /" | \
tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list >/dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$3/$1/ /" | \
tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$3.list >/dev/null 2>&1

apt update -qq >/dev/null 2>&1
apt install -qq -y cri-o cri-o-runc cri-tools >/dev/null 2>&1
systemctl daemon-reload
systemctl enable crio >/dev/null 2>&1
systemctl start crio >/dev/null 2>&1

echo "[TASK 6] Add apt repo for kubernetes"
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg >/dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list >/dev/null 2>&1

echo "[TASK 7] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt update -qq >/dev/null 2>&1
apt install -qq -y kubeadm=$2-00 kubelet=$2-00 kubectl=$2-00 >/dev/null 2>&1

echo "[TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 9] Set root password"
echo -e "root\nroot" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc
