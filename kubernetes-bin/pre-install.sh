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

# 设置ulimit
cat >/etc/security/limits.d/default-limits.conf <<EOF
root soft nofile 1000000
root hard nofile 1000000
* soft nofile 1000000
* hard nofile 1000000
EOF

# 关闭防火墙
systemctl stop firewalld || echo "no firewalld"
systemctl disable firewalld || echo "no firewalld"

# 关闭selinux
# https://stackoverflow.com/questions/8822097/how-to-replace-a-whole-line-with-sed
setenforce 0 && sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config

# 关闭swap内存
swapoff -a
sed -i '/ swap / s/^#*/#/' /etc/fstab

# 设置 sysctl 参数
echo "modify sysctl options"
cat >/etc/sysctl.d/k8s.conf <<-EOF
vm.swappiness = 0
fs.inotify.max_user_watches=524288
vm.max_map_count=1000000
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
net.netfilter.nf_conntrack_max=1000000
EOF

lsmod | grep conntrack || modprobe ip_conntrack

sysctl --system

# 为docker 和kubelet设置单独日志文件
# echo "config rsyslog, seperate docker and kubelet logs"
cat >/etc/rsyslog.d/30-kubernetes.conf <<-EOF
:programname, isequal, "dockerd" /var/log/dockerd.log
:programname, isequal, "kubelet" /var/log/kubelet.log
:programname, isequal, "dockerd"   ~
:programname, isequal, "kubelet"   ~
EOF
