#!/bin/bash
#
#install style chmod +x install && ./install.sh

check() {

# 检测是否是root用户
if [[ $(id -u) != "0" ]]; then
    printf "Error: You must be root to run this install script.\n"
    exit 1
fi

# 检测是否是CentOS 7或者RHEL 7
local OS_SYSTEM=$(grep "release 7." /etc/redhat-release 2>/dev/null | wc -l)
if [[ $(OS_SYSTEM) -eq 0 ]]; then 
    printf "Error: Your OS is NOT CentOS 7 or RHEL 7.\n"
    printf "This install script is ONLY for CentOS 7 and RHEL 7.\n"
    exit 1
fi
#查看当前脚本所在目录，切换到当前目录
basepath=$(dirname $0)
cd ${basepath}

}

# ip address checkout
CheckIPAddr()
{
echo $1|grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" > /dev/null;
#IP地址必须为全数字
        if [ $? -ne 0 ]
        then
                return 1
        fi
        ipaddr=$1
        a=`echo $ipaddr|awk -F . '{print $1}'`  #以"."分隔，取出每个列的值
        b=`echo $ipaddr|awk -F . '{print $2}'`
        c=`echo $ipaddr|awk -F . '{print $3}'`
        d=`echo $ipaddr|awk -F . '{print $4}'`
        for num in $a $b $c $d
        do
                if [ $num -gt 255 ] || [ $num -lt 0 ]    #每个数值必须在0-255之间
                then
                        return 1
                fi
        done
                return 0
}

ConfigEnvironmentVariable() {
#configure virable argument

  SYSTEM_VERSION=$(grep "release 7." /etc/redhat-release | awk -F ' '  '{print $4}')
  # master node ip
  master=$(whiptail --title "kubernetes install" --inputbox "Please input the cluster master ip address." 10 60 3>&1 1>&2 2>&3)
  
  CheckIPAddr $master
  
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo " cluster master IP:" $master
  else
      echo "You chose Cancel."
  fi

  #  work node1 ip
  node1=$(whiptail --title "kubernetes install" --inputbox "Please input the cluster node1 ip address." 10 60 3>&1 1>&2 2>&3)
  
  CheckIPAddr $node1
  
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo " cluster node1 IP:" $node1
  else
      echo "You chose Cancel."
  fi
  
  # work node2 ip
  node2=$(whiptail --title "kubernetes install" --inputbox "Please input the cluster node2 ip address." 10 60 3>&1 1>&2 2>&3)
  
  CheckIPAddr $node2
  
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo " cluster node2 IP:" $node2
  else
      echo "You chose Cancel."
  fi
  
  # all nodes root login password.
  
  password=$(whiptail --title "kubernetes install" --passwordbox "Enter your all cluster login password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)
   
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo "Your password is:" $password
  else
      echo "You chose Cancel."
  fi
  
  # Nodes connection network interface name
  interface=$(whiptail --title "kubernetes install" --inputbox "Please input communication interface between clusters." 10 60 3>&1 1>&2 2>&3)
  
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo "input communication interface between clusters:" $interface
  else
      echo "You chose Cancel."
  fi
  
  # Nodes install docker version
  docker_version=$(whiptail --title "kubernetes install" --radiolist \
  "What is the k8s version of your choice?" 15 90 4 \
  "19.03.4-3.el7" "docker version 19.03.4-3.el7" ON  \
  "19.03.3-3.el7" "docker version 19.03.3-3.el7" OFF \
  "19.03.2-3.el7" "docker version 19.03.2-3.el7" OFF \
  "19.03.1-3.el7" "docker version 19.03.1-3.el7" OFF \
  "19.03.0-3.el7" "docker version 19.03.0-3.el7" OFF \
  "18.09.9-3.el7" "docker version 18.09.9-3.el7" OFF \
  "18.09.8-3.el7" "docker version 18.09.8-3.el7" OFF \
  "18.09.7-3.el7" "docker version 18.09.7-3.el7" OFF \
  "18.09.6-3.el7" "docker version 18.09.6-3.el7" OFF \
  "18.09.5-3.el7" "docker version 18.09.5-3.el7" OFF \
  "18.09.4-3.el7" "docker version 18.09.4-3.el7" OFF \
  "18.09.3-3.el7" "docker version 18.09.3-3.el7" OFF \
  "18.09.2-3.el7" "docker version 18.09.2-3.el7" OFF \
  "18.09.1-3.el7" "docker version 18.09.1-3.el7" OFF \
  "18.09.0-3.el7" "docker version 18.09.0-3.el7" OFF \
  "18.06.3.ce-3.el7" "docker version 18.06.3.ce-3.el7" OFF \
  "18.06.2.ce-3.el7" "docker version 18.06.2.ce-3.el7" OFF \
  "18.06.1.ce-3.el7" "docker version 18.06.1.ce-3.el7" OFF \
  "18.06.1.ce-3.el7" "docker version 18.06.1.ce-3.el7" OFF \
  "18.06.0.ce-3.el7" "docker version 18.06.0.ce-3.el7" OFF \
  "18.03.1.ce-1.el7.centos"  "docker version 18.03.1.ce-1.el7.centos" OFF 3>&1 1>&2 2>&3)
  
  
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo "input docker version:" $docker_version
  else
      echo "You chose Cancel."
  fi
  
  # Nodes k8s version
  k8s_version=$(whiptail --title "kubernetes install" --radiolist \
  "What is the k8s version of your choice?" 15 60 4 \
  "1.12.9" "k8s version 1.12.9" ON \
  "1.13.3" "k8s version 1.13.3" OFF \
  "1.14.4" "k8s version 1.14.4" OFF \
  "1.15.4" "k8s version 1.15.4" OFF \
  "1.16.3" "k8s version 1.16.3" OFF \
  "1.16.4" "k8s version 1.16.4" OFF \
  "1.16.5" "k8s version 1.16.5" OFF \
  "1.17.1" "k8s version 1.17.1" OFF \
  "1.17.2" "k8s version 1.17.2" OFF \
  "1.17.3" "k8s version 1.17.3" OFF \
  "1.17.4" "k8s version 1.17.4" OFF \
  "1.18.1" "k8s version 1.18.1" OFF \
  "1.18.10" "k8s version 1.18.10" OFF \
  "1.19.1" "k8s version 1.19.1" OFF \
  "1.19.4" "k8s version 1.19.4" OFF 3>&1 1>&2 2>&3)

  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo "input k8s version:" $k8s_version
  else
      echo "You chose Cancel."
      exit 1
  fi

  # Nodes install k8s CNI
  k8s_cni=$(whiptail --title "kubernetes install" --radiolist \
  "What is the k8s version of your choice?" 15 90 4 \
  "calico" "k8 CNI calico" ON  \
  "flannel" "k8s CNI flannel" OFF 3>&1 1>&2 2>&3)

  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo "input type of the k8s CNI:" ${k8s_cni}
  else
      echo "You chose Cancel."
      break
  fi
}

PrintEnvironmentVariable() {
# print Environment Variable
#cat << EOF > environment.sh
# all node for the cluster ip 
export ALL_NODE_IPS=( ${master} ${node1} ${node2} )

# node for the cluster ip 
export NODE_IPS=( ${node1} ${node2} )

# all nodes root login password
export PASSWORD=${password}

# master for the cluster ip 
export K8S_MASTER_IP=${master}

# Nodes interconnection network interface name
export IFACE="${interface}"

# cluster docker version
export DOCKER_VERSION=${docker_version}

# cluster k8s version
export K8S_VERSION=${k8s_version}

# cluster type of the k8s cni 
export K8S_CNI=${k8s_cni}
#EOF
#source environment.sh

cat << EOF
# The necessary prerequisites are as follows:
 ----------------------------------
|              |                   |
| Components   |       Version     |
|--------------|-------------------|
| Kubernetes   | ${K8S_VERSION}    |
| Contrail     | latest            |
| OS           | ${SYSTEM_VERSION} |
| Docker       | ${DOCKER_VERSION} |
 ----------------------------------
EOF
}

  
#ssh intertracsation host

Auto_Connect() {
yum install -y expect
#distribute public key
ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa
for i in ${ALL_NODE_IPS[@]};do
expect -c "
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$i
        expect {
                \"*yes/no*\" {send \"yes\r\"; exp_continue}
                \"*password*\" {send \"${PASSWORD}\r\"; exp_continue}
                \"*Password*\" {send \"${PASSWORD}\r\";}
        } "
done
}

Installdependpackage() {

  ssh root@${ALL_NODE_IPS[0]} "hostnamectl set-hostname master"
  ssh root@${ALL_NODE_IPS[1]} "hostnamectl set-hostname node1"
  ssh root@${ALL_NODE_IPS[2]} "hostnamectl set-hostname node2"

  cat << EOF >> /etc/hosts
${ALL_NODE_IPS[0]} master
${ALL_NODE_IPS[1]}  node1
${ALL_NODE_IPS[2]}  node2
EOF

  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
  	  scp /etc/hosts root@${node_ip}:/etc/hosts
  done

  grep "nameserver" /etc/resolv.conf || cat << EOF >> /etc/resolv.conf
namaserver 114.114.114.114
EOF
 
  #Turn off the swap functionality on all nodes
  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
  	ssh root@${node_ip} "swapoff -a"
  	ssh root@${node_ip} "sed -ri 's/.*swap.*/#&/' /etc/fstab"
  done

  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
  	scp /etc/resolv.conf root@${node_ip}:/etc/resolv.conf
  done

  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
  	### 3.3 Disable Selinux and firewalld
  	ssh root@${node_ip} "systemctl stop firewalld; systemctl disable firewalld"
  	ssh root@${node_ip} "setenforce 0"
  	ssh root@${node_ip} "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"
  	ssh root@${node_ip} "getenforce"
   done

  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
  	ssh root@${node_ip} "yum install ipset ipvsadm conntrack-tools.x86_64 -y"
   done

  cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
ipvs_modules="ip_vs ip_vs_lc ip_vs_wlc ip_vs_rr ip_vs_wrr ip_vs_lblc ip_vs_lblcr ip_vs_dh ip_vs_sh ip_vs_fo ip_vs_nq ip_vs_sed ip_vs_ftp nf_conntrack_ipv4"
for kernel_module in \${ipvs_modules}; do
 /sbin/modinfo -F filename \${kernel_module} > /dev/null 2>&1
 if [ $? -eq 0 ]; then
 /sbin/modprobe \${kernel_module}
 fi
done
EOF

  chmod 755 /etc/sysconfig/modules/ipvs.modules

  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
  	ssh root@${node_ip} "source /etc/sysconfig/modules/ipvs.modules && lsmod | grep ip_vs"
   done

  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
  	### 3.4 Install the required tools and dependencies
  	ssh root@${node_ip} "yum -y install ntp wget vim net-tools sshpass"
  	ssh root@${node_ip} "systemctl enable ntpd"
  	ssh root@${node_ip} "sed -i '/0.centos.pool.ntp.org/i\server ntp1.aliyun.com iburst' /etc/ntp.conf"
  	ssh root@${node_ip} "sed -i '/centos.pool.ntp.org/d' /etc/ntp.conf"
  	ssh root@${node_ip} "systemctl start ntpd"
  done

  cat << EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
EOF

  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
      scp /etc/sysctl.d/k8s.conf root@${node_ip}:/etc/sysctl.d/k8s.conf
      ssh root@${node_ip} "sysctl -p /etc/sysctl.d/k8s.conf"
  done

}

### Install Docker Engine
InstallDocker() {
  #source environment.sh
  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
      ssh root@${node_ip} "yum install -y yum-utils device-mapper-persistent-data lvm2"
  	  ssh root@${node_ip} "wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo"
  	  ssh root@${node_ip} "yum -y install epel-release"
  	  ssh root@${node_ip} "yum -y install docker-ce-${DOCKER_VERSION}"
  	  ssh root@${node_ip} "systemctl enable docker && systemctl start docker"
      sleep 1
  	  ssh root@${node_ip} "docker -v"
  done

  cat << eof > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://v5d7kh0f.mirror.aliyuncs.com"]
}
eof

  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
  	  scp  /etc/docker/daemon.json root@${node_ip}:/etc/docker/daemon.json
  	  ssh root@${node_ip} "systemctl daemon-reload && systemctl restart docker"
  done
}

# Install k8s
InstallK8s() {
  cat <<EOF > kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

  for node_ip in ${ALL_NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
      scp kubernetes.repo root@${node_ip}:/etc/yum.repos.d/kubernetes.repo
   done

  ### install kubeadm,kubelet,kubectl all of the nodes
  for node_ip in ${ALL_NODE_IPS[@]}
    do
    	echo ">>> ${node_ip}"
    ssh root@${node_ip} "yum install -y kubelet-${K8S_VERSION} kubeadm-${K8S_VERSION} kubectl-${K8S_VERSION}"
  	ssh root@${node_ip} "systemctl enable kubelet && systemctl start kubelet"
   done

  # master node is pull k8s images
  chmod +x mpullimages.sh
  ./mpullimages.sh
  
  # node node is pull k8s images
  for node_ip in ${NODE_IPS[@]}
    do
      echo ">>> ${node_ip}"
      scp npullimages.sh environment.sh root@${node_ip}:/root
      ssh root@${node_ip} ./npullimages.sh
   done

  # depoly k8s master
  sed -i "/advertiseAddress/s/:.*/: ${ALL_NODE_IPS[0]}/g" kubeadm-config.yaml
  sed -i "/kubernetesVersion/s/:.*/: ${K8S_VERSION}/g" kubeadm-config.yaml
  kubeadm init --config kubeadm-config.yaml > kubeadm.log
  sleep 1

  # use kubectl tools
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  while true; do
  sleep 1
  kubectl get nodes | grep "NotReady"
  if [ $? = 0 ]; then
    echo "the kubernetes cluster master node is not Ready"
    break
  fi
  done

  local string1=$(grep "kubeadm join"  kubeadm.log)
  local string2=${string1%\\}
  local string3=$(grep "discovery-token" kubeadm.log)
  #sed -i "s/\\\//g"   kubeconfig.log

  KUBADM=${string2}${string3}

  for node_ip in ${NODE_IPS[@]}
    do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "${KUBADM}"
    sleep 2
  done
  sleep 1

  # Check that the cluster state is normal
  while true; do
  sleep 1
  kubectl get cs | grep "Healthy"
  if [ $? = 0 ]; then
    echo "the kubernetes cluster is Healthy"
    break
  fi
  done

if [ ${K8S_CNI} = "calico" ] ; then
  # install calico CNI
  # 参考文档 https://docs.projectcalico.org/v3.8/getting-started/kubernetes/
  wget -c https://docs.projectcalico.org/v3.8/manifests/calico.yaml
  sed -i "s#192\.168\.0\.0/16#${POD_SUBNET}#" calico.yaml
  kubectl apply -f calico.yaml
  sleep 1

  while true; do
  sleep 1
  kubectl get pods -n kube-system | grep "calico" | grep "Running"
  if [ $? = 0 ]; then
    echo "the kubernetes calico CNI is Healthy"
    break
  fi
  done

elif [ ${K8S_CNI} = "flannel" ]; then
  # install flanneld CNI
  #wget -c https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  #sed -i 's/quay.io\/coreos/registry.cn-beijing.aliyuncs.com\/imcto/g' kube-flannel.yml
  kubectl apply -f kube-flannel.yml
  sleep 1

  while true; do
  sleep 1
  kubectl get pods -n kube-system | grep "kube-flannel" | grep "Running"
  if [ $? = 0 ]; then
    echo "the kubernetes flannel CNI is Healthy"
    break
  fi
  done

else
  echo "your choice is error"
fi
  kubectl get pod --all-namespaces -o wide
}

menu()
{
OPTION=$(whiptail --title "Menu Dialog" --menu "Choose your number" 15 60 4 \
"1" "install k8s" \
"2" "uninstall k8s" \
"3" "error output"  3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "your Choose number is:" $OPTION
    while true; do
        case $OPTION in
            1)
               check
               ConfigEnvironmentVariable $@
               PrintEnvironmentVariable
               Auto_Connect
               Installdependpackage
               InstallDocker 
               InstallK8s
               exit 0
               ;;
#            2)
#               uninstall
#               ;;

            *)
               echo "usage: 1 2"
               ;;
        esac
    done
else
    echo "You choice is error."
fi
}

menu

