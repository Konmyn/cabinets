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
sed -i '/swap / s/^#*/#/' /etc/fstab

# 设置 sysctl 参数
echo "modify sysctl options"
cat >/etc/sysctl.d/k8s.conf <<-EOF
vm.swappiness=0
fs.inotify.max_user_watches=524288
fs.inotify.max_user_instances=8192
net.netfilter.nf_conntrack_max=1000000
vm.max_map_count=1000000
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6=1
EOF

# 其他可能需要调节的参数：
# vm.overcommit_memory=1
# net.ipv4.tcp_tw_recycle=0
# vm.panic_on_oom=0
# fs.file-max=52706963
# fs.nr_open=52706963
# 以上的值默认就是或者设置的已经比较大了
# net.ipv4.neigh.default.gc_thresh1=1024
# net.ipv4.neigh.default.gc_thresh2=2048
# net.ipv4.neigh.default.gc_thresh3=4096

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
