#! /bin/bash
# 下载指定版本的kubernetes组件和镜像
set -o errexit
set -o nounset
set -o pipefail

proxy='-x socks5h://127.0.0.1:1080'
IMAGE_FILE='calico-images.txt'
IMAGE_TARBALL='calico-images.tgz'

function download_image() {
    for image in $(cat ${IMAGE_FILE}); do
        docker pull $image
    done
    docker save $(cat ${IMAGE_FILE}) | gzip >${IMAGE_TARBALL}
}

# https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-with-kubernetes-api-datastore-50-nodes-or-less
# curl ${proxy} https://docs.projectcalico.org/manifests/calico.yaml -O
grep image: calico.yaml | awk '{print $2}' > calico-images.txt
download_image
