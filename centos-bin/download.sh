#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

# 基础配置
RELEASE='v1.15.4'
DOCKER_VERSION='18.09.9'
OS_VERSION='centos:7.6.1810'
OS_IMAGE_VERSION='centos:7.6.1810'
CALICO_VERSION='v3.9'
HARBOR_VERSION='1.9.3'
DASHBOARD_VERSION='v1.10.1'

OUT_BASEDIR="k8s_$RELEASE"
SCRIPT_DIR=$(pwd)

docker version >/dev/null 2>&1 || (echo "need install docker first" && exit 1)

function download_bin() {
    mkdir -p system-rpm
    pushd system-rpm
    cp ${SCRIPT_DIR}/Dockerfile-rpm Dockerfile
    docker build -t centos:system-rpm -f Dockerfile .
    docker run --rm -v $(pwd):/tmp centos:system-rpm bash -c "rm -rf /tmp/*; cp -r /data/bin/* /tmp/"
    rm -rf Dockerfile
    popd
}

function download_docker() {
    mkdir -p docker
    pushd docker
    cp -rf ${SCRIPT_DIR}/Dockerfile-docker Dockerfile
    docker build -t centos:docker -f Dockerfile .
    docker run --rm -v $(pwd):/tmp centos:docker bash -c "rm -rf /tmp/*; cp -r /data/docker/* /tmp/"
    rm -rf Dockerfile
    popd
}

# download_bin
download_docker
