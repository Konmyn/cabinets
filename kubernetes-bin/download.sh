#! /bin/bash
# 下载指定版本的kubernetes组件和镜像
set -o errexit
set -o nounset
set -o pipefail

proxy='-x socks5h://127.0.0.1:1080'
info_file='completed.info'
IMAGE_FILE='images.txt'
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
# RELEASE="v1.15.12"
# RELEASE="v1.16.15"
# RELEASE="v1.17.12"
# RELEASE="v1.18.9"
# RELEASE="v1.19.2"
RELEASE="$(curl -sSL ${proxy} https://dl.k8s.io/release/stable.txt)"

function download_image() {
    for image in $(cat ${IMAGE_FILE}); do
        docker pull $image
    done
    docker save $(cat ${IMAGE_FILE}) | gzip >images.tgz
}

echo "${RELEASE}"
if [[ -d ${RELEASE} ]]; then
    echo "dir already exists"
else
    echo "make release dir"
    mkdir "${RELEASE}"
fi
pushd "${RELEASE}"
if [[ -f ${info_file} ]]; then
    echo "file already downloaded"
else
    echo "start download file"
    curl -L --remote-name-all ${proxy} https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
    chmod +x {kubeadm,kubelet,kubectl}
    ./kubeadm config images list --kubernetes-version=${RELEASE} >${IMAGE_FILE}
    download_image
    touch ${info_file}
fi
popd
