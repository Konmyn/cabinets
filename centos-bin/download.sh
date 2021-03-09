#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

# curl的代理设置
proxy='-x socks5h://127.0.0.1:1080'

# 基础配置
RELEASE='v1.15.4'
DOCKER_VERSION='19.03.14'
CENTOS_VERSION='7.9.2009'

OUT_BASEDIR="k8s_$RELEASE"
SCRIPT_DIR=$(pwd)
OS_BASED_PATH="${CENTOS_VERSION}/${DOCKER_VERSION}"

# rm -rf ${OS_BASED_PATH}
mkdir -p ${OS_BASED_PATH}

docker version >/dev/null 2>&1 || (echo "need install docker first" && exit 1)

function download_bin() {
    echo "download system bins"
    pushd ${OS_BASED_PATH}
    mkdir -p system-rpm
    pushd system-rpm

    # cp ${SCRIPT_DIR}/Dockerfile-rpm Dockerfile
    cat >Dockerfile <<-EOF
FROM harbor.beautytiger.com/docker.io/centos:${CENTOS_VERSION}
RUN yum install htop ca-certificates socat telnet tree conntrack --downloadonly --downloaddir=/data/bin --skip-broken --nogpgcheck -y && \\
    yum clean all
EOF
    docker build -t centos:system-rpm -f Dockerfile .
    docker run --rm -v $(pwd):/tmp centos:system-rpm bash -c "rm -rf /tmp/*; cp -r /data/bin/* /tmp/"

    popd
    popd
}

function download_docker() {
    echo "download docker bins"
    pushd ${OS_BASED_PATH}
    mkdir -p docker
    pushd docker

    # cp -rf ${SCRIPT_DIR}/Dockerfile-docker Dockerfile
    cat >Dockerfile <<-EOF
FROM harbor.beautytiger.com/docker.io/centos:${CENTOS_VERSION}
# 禁用yum的repo查找功能
RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf && \\
    # 删除默认repo，使用国内的repo源
    # https://developer.aliyun.com/mirror/centos
    rm /etc/yum.repos.d/CentOS-Base.repo && \\
    curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo && \\
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \\
    # 安装docker的repo源，直接使用国内的源
    yum install -y yum-utils --nogpgcheck && \\
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo && \\
    # 安装docker
    # 省去了containerd的版本要求， 依赖解决： containerd.io-1.2.13 
    yum install -y docker-ce-${DOCKER_VERSION} docker-ce-cli-${DOCKER_VERSION} --downloadonly --downloaddir=/data/docker --nogpgcheck && \\
    # 安装其他所需的包
    yum install --skip-broken nfs-utils lvm2 systemd-units xfsprogs device-mapper-persistent-data --nogpgcheck --downloadonly --downloaddir=/data/docker && \\
    # 清除yum缓存
    yum clean all
EOF
    docker build -t centos:docker -f Dockerfile .
    docker run --rm -v $(pwd):/tmp centos:docker bash -c "rm -rf /tmp/*; cp -r /data/docker/* /tmp/"

    popd
    popd
}

function download_harbor() {
    echo "download harbor bins"
    pushd ${OS_BASED_PATH}
    mkdir -p harbor
    pushd harbor

    docker_compose_url="https://github.com/docker/compose/releases/download/1.28.2/docker-compose-Linux-x86_64"
    harbor_offline_url="https://github.com/goharbor/harbor/releases/download/v2.1.3/harbor-offline-installer-v2.1.3.tgz"
    curl -L --remote-name-all ${proxy} ${docker_compose_url} -o docker-compose
    curl -L --remote-name-all ${proxy} ${harbor_offline_url}

    popd
    popd
}

function download_haproxy() {
    echo "download haproxy bins"
    pushd ${OS_BASED_PATH}
    mkdir -p haproxy
    pushd haproxy
    
    # psmisc for killall
    cat >Dockerfile <<-EOF
FROM harbor.beautytiger.com/docker.io/centos:${CENTOS_VERSION}
RUN yum install haproxy keepalived psmisc --downloadonly --downloaddir=/data/bin --skip-broken --nogpgcheck -y && \\
    yum clean all
EOF
    docker build -t centos:haproxy -f Dockerfile .
    docker run --rm -v $(pwd):/tmp centos:haproxy bash -c "rm -rf /tmp/*; cp -r /data/bin/* /tmp/"

    popd
    popd
}

# download_bin
# download_docker
# download_harbor
download_haproxy
