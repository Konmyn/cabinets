#!/usr/bin/env bash
# kubernetes安装前的初始化
# 此脚本是幂等的，可重复运行
# 适用于 centos7.6

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

if [ $(id -u) -ne 0 ]; then
    echo "please run as root!"
    exit 1
fi

RELEASE="v1.19.2"

pushd ${RELEASE}

chmod a+x {kubeadm,kubelet,kubectl}
cp -f kubelet /usr/bin/kubelet
cp -f kubeadm /usr/bin/kubeadm
cp -f kubectl /usr/bin/kubectl

cat kubelet.service > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
cat 10-kubeadm.conf > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl enable kubelet && systemctl start kubelet

echo "192.168.28.95  harbor.beautytiger.com" >> /etc/hosts
echo "192.168.28.137 kubernetes.beautytiger.com" >> /etc/hosts

kubeadm config images pull --config kubeadm-config.yaml -v=10
# kubeadm init --config kubeadm-config.yaml --upload-certs -v=10
