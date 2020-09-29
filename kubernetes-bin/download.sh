#! /bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
echo "${RELEASE}"
mkdir "${RELEASE}"
pushd "${RELEASE}"
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}
popd
