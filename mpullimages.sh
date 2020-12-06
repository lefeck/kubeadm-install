#!/bin/bash
#source environment.sh
KUBE_VERSION=v${K8S_VERSION}
KUBE_PAUSE_VERSION=3.1
DASHBOARD_VERSION=1.8.3
username=registry.cn-hangzhou.aliyuncs.com/google_containers

K8S_VERSION_TMP=$(echo ${K8S_VERSION} | cut -d '.'  -f1,2)

if [ ${K8S_VERSION_TMP} = 1.17 ]; then
    DNS_VERSION=1.6.5
    ETCD_VERSION=3.4.3-0
elif [ ${K8S_VERSION_TMP} = 1.16 ]; then
    DNS_VERSION=1.6.2
    ETCD_VERSION=3.3.15-0
elif [ ${K8S_VERSION_TMP} = 1.15 ]; then
    DNS_VERSION=1.3.1
    ETCD_VERSION=3.3.10
elif [ ${K8S_VERSION_TMP} = 1.14 ]; then
    DNS_VERSION=1.3.1
    ETCD_VERSION=3.3.10
elif [ ${K8S_VERSION_TMP} = 1.13 ]; then
    DNS_VERSION=1.2.6
    ETCD_VERSION=3.2.24
elif [ ${K8S_VERSION_TMP} = 1.12 ]; then
    DNS_VERSION=1.2.2
    ETCD_VERSION=3.2.24
elif [ ${K8S_VERSION_TMP} = 1.11 ]; then
    DNS_VERSION=1.2.6
    ETCD_VERSION=3.2.24
else
    echo "k8s version is error"
fi


images=(
    kube-proxy:${KUBE_VERSION}
    kube-scheduler:${KUBE_VERSION}
    kube-controller-manager:${KUBE_VERSION}
    kube-apiserver:${KUBE_VERSION}
    pause:${KUBE_PAUSE_VERSION}
    etcd:${ETCD_VERSION}
    coredns:${DNS_VERSION}
    kubernetes-dashboard-amd64:v${DASHBOARD_VERSION}
    )

for image in ${images[@]}
do
    new_image=`echo k8s.gcr.io/${image} | awk -F : '{print $1}'`
	docker image ls | grep  ${new_image}
	if [ $? != 0 ];then
    	docker pull ${username}/${image} 
    	docker tag ${username}/${image} k8s.gcr.io/${image}
    	docker rmi ${username}/${image}
	else
        echo "docker ${image} is exist."
	fi
done
# List all images
docker images 