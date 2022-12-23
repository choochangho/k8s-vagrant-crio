## 컴포넌트 버전 설정

Vagrantfile 에서 각 컴포넌트 버전과 설정 값 확인 및 수정

```ruby
OS_V = 'xUbuntu_20.04'                            # OS Version for CRI-O
K8S_V = '1.26.0'                                  # Kubernetes 
CRIO_V = '1.26'                                   # Container Runtine Interface
NODES = 3                                         # Worker Nodes 
APISERVER_ADVERTISE_ADDRESS = "192.168.142.10"    # apiserver address
POD_NETWORK_CIDR = "10.244.0.0/16"                # pod network cidr
MASTER_IP = "192.168.142.10"                      # master(control-plane) server ip
```

## 가상머신 프로비저닝

```bash
$ vagrant up
```

## Master 서버 접속

id와 password 는 vagrant/vagrant 이다.

```bash
$ ssh vagrant@192.168.142.10
The authenticity of host '192.168.142.10 (192.168.142.10)' can't be established.
ED25519 key fingerprint is SHA256:RCBQKPzOKXbaXb2DU5fGL8EHRD00p3/a7hV24GOQmsk.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.142.10' (ED25519) to the list of known hosts.
vagrant@192.168.142.10's password:
vagrant@master:~$
```

## kubectl 

```bash
vagrant@master:~$ sudo su -l
root@master:~# ls -alh
total 44K
drwx------  6 root root 4.0K Dec 23 14:45 .
drwxr-xr-x 19 root root 4.0K Dec 23 14:45 ..
-rw-r--r--  1 root root 3.1K Nov 19 20:24 .bashrc
drwx------  2 root root 4.0K Nov 19 20:12 .cache
drwxr-x---  3 root root 4.0K Dec 23 14:45 .kube
-rw-r--r--  1 root root 4.8K Dec 23 14:45 kubeinit.log
-rw-r--r--  1 root root  161 Jul  9  2019 .profile
drwx------  3 root root 4.0K Nov 19 20:12 snap
drwx------  2 root root 4.0K Nov 19 20:12 .ssh
-rw-r--r--  1 root root    0 Nov 19 20:25 truncate
-rw-r--r--  1 root root   13 Nov 19 20:24 .vimrc
root@master:~# cp /etc/kubernetes/admin.conf .kube/config
```

## node 정보 확인

```bash
root@master:~# kubectl get node -o wide
NAME     STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master   Ready    control-plane   10m     v1.26.0   10.0.2.15     <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   cri-o://1.26.0
node1    Ready    <none>          7m54s   v1.26.0   10.0.2.15     <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   cri-o://1.26.0
node2    Ready    <none>          5m6s    v1.26.0   10.0.2.15     <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   cri-o://1.26.0
node3    Ready    <none>          2m28s   v1.26.0   10.0.2.15     <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   cri-o://1.26.0
root@master:~#
```

## cri-o 테스트

```bash
root@master:~# crictl info
{
  "status": {
    "conditions": [
      {
        "type": "RuntimeReady",
        "status": true,
        "reason": "",
        "message": ""
      },
      {
        "type": "NetworkReady",
        "status": true,
        "reason": "",
        "message": ""
      }
    ]
  }
}
root@master:~# crictl ps
CONTAINER           IMAGE                                                                                                       CREATED             STATE               NAME                      ATTEMPT             POD ID              POD
2d7f55d7a802a       docker.io/calico/kube-controllers@sha256:2b6acd7f677f76ffe12ecf3ea7df92eb9b1bdb07336d1ac2a54c7631fb753f7e   11 minutes ago      Running             calico-kube-controllers   0                   2031536546dc4       calico-kube-controllers-7bdbfc669-nkbcr
8b3bd2e8eedb6       5185b96f0becf59032b8e3646e99f84d9655dff3ac9e2605e0dc77f9c441ae4a                                            11 minutes ago      Running             coredns                   0                   3213e177dff99       coredns-787d4945fb-fxsfs
065c56bd452a3       5185b96f0becf59032b8e3646e99f84d9655dff3ac9e2605e0dc77f9c441ae4a                                            11 minutes ago      Running             coredns                   0                   9863dd5d46e10       coredns-787d4945fb-k24hq
06871ea204421       54637cb36d4a1c029fb994c6fc88af04791c1f2dcbd12a24aa995c0bffaacdb1                                            11 minutes ago      Running             calico-node               0                   e080302ea46ad       calico-node-rvz27
8a8e81d978091       556768f31eb1d6673ce1d1fc0ace1e814fc40eee9923275ba3a82635159afc69                                            13 minutes ago      Running             kube-proxy                0                   43d4eb904addb       kube-proxy-blnrs
2c4da9bca96d0       a31e1d84401e66c2f4162d70fdbd7db2a43d34f85785911c9cd57402a3d8e761                                            14 minutes ago      Running             kube-apiserver            0                   4aeba763a3a39       kube-apiserver-master
7e8298bb182de       5d7c5dfd3ba18719c14d2126c91550a17016529590301b76fc08c04f64872339                                            14 minutes ago      Running             kube-controller-manager   0                   3f70ad80e585e       kube-controller-manager-master
8eb3cf78773b4       fce326961ae2d51a5f726883fd59d2a8c2ccc3e45d3bb859882db58e422e59e7                                            14 minutes ago      Running             etcd                      0                   3ce254ba0c2f5       etcd-master
36f1defa8022d       dafd8ad70b156eb8aaecfdc487b6dc89ba1c4313dbb72db6563f7640824c243e                                            14 minutes ago      Running             kube-scheduler            0                   788e28d152b80       kube-scheduler-master
root@master:~# crictl images
IMAGE                                     TAG                 IMAGE ID            SIZE
docker.io/calico/cni                      v3.24.5             628dd70880410       198MB
docker.io/calico/kube-controllers         v3.24.5             38b76de417d5d       71.4MB
docker.io/calico/node                     v3.24.5             54637cb36d4a1       229MB
registry.k8s.io/coredns/coredns           v1.9.3              5185b96f0becf       48.9MB
registry.k8s.io/etcd                      3.5.6-0             fce326961ae2d       301MB
registry.k8s.io/kube-apiserver            v1.26.0             a31e1d84401e6       135MB
registry.k8s.io/kube-controller-manager   v1.26.0             5d7c5dfd3ba18       125MB
registry.k8s.io/kube-proxy                v1.26.0             556768f31eb1d       67.2MB
registry.k8s.io/kube-scheduler            v1.26.0             dafd8ad70b156       57.7MB
registry.k8s.io/pause                     3.6                 6270bb605e12e       690kB
registry.k8s.io/pause                     3.9                 e6f1816883972       750kB
```
