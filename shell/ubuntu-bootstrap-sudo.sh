#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run use sudo "
    exit
fi

echo "user:" $(id)
echo "home:" $HOME

# change apt source manually
# apt update && apt install git -y
#ls /etc/apt/sources.list.backup &> /dev/null || ( echo "backup apt sources" && cp /etc/apt/sources.list /etc/apt/sources.list.backup )
#grep -E "security.ubuntu.com|cn.archive.ubuntu.com" /etc/apt/sources.list && ( sed -i 's/cn.archive.ubuntu.com/mirrors.cn99.com/g' /etc/apt/sources.list && sed -i 's/security.ubuntu.com/mirrors.cn99.com/g' /etc/apt/sources.list )

apt update && apt upgrade -y
apt autoclean
apt clean
apt autoremove
apt install open-vm-tools-desktop vim openssh-server curl zsh python3-pip tree htop glances -y

cat >/etc/pip.conf <<EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
EOF

pip3 install ipython

sudo -u matrix ./ubuntu-bootstrap.sh
