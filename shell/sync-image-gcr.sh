#!/bin/bash
# 同步 kubernetes的镜像

set -e
images=(
    k8s.gcr.io/kube-apiserver:v1.13.9
    k8s.gcr.io/kube-controller-manager:v1.13.9
    k8s.gcr.io/kube-scheduler:v1.13.9
    k8s.gcr.io/kube-proxy:v1.13.9
    k8s.gcr.io/pause:3.1
    k8s.gcr.io/etcd:3.2.24
    k8s.gcr.io/coredns:1.2.6
    k8s.gcr.io/kube-apiserver:v1.14.6
    k8s.gcr.io/kube-controller-manager:v1.14.6
    k8s.gcr.io/kube-scheduler:v1.14.6
    k8s.gcr.io/kube-proxy:v1.14.6
    k8s.gcr.io/kube-apiserver:v1.15.3
    k8s.gcr.io/kube-controller-manager:v1.15.3
    k8s.gcr.io/kube-scheduler:v1.15.3
    k8s.gcr.io/kube-proxy:v1.15.3
    k8s.gcr.io/etcd:3.3.10
    k8s.gcr.io/coredns:1.3.1
)

for image in ${images[@]}; do
    set $image
    if [[ $1 == *":v1"* ]]; then
        origin="mirrorgooglecontainers/"$(echo $1 | cut -d/ -f2 | sed 's/:/-amd64:/g')
    elif [[ $1 == *"coredns"* ]]; then
        origin="coredns/"$(echo $1 | cut -d/ -f2)
    else
        origin="mirrorgooglecontainers/"$(echo $1 | cut -d/ -f2)
    fi
    target=${2-"harbor.beautytiger.com/$1"}
    echo -e "from:" $image "\nto:" $origin "\nresult:" $target
    docker pull $origin
    docker tag $origin $target
    docker push $target
done
