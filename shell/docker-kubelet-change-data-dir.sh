#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# move into script dir
DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

systemctl stop docker
systemctl stop kubelet

mkdir -p /u01/var/lib/docker
sed -i 's#"json-file",#"json-file",\n  "data-root": "/u01/var/lib/docker",#' /etc/docker/daemon.json
rsync -aP /var/lib/docker/ /u01/var/lib/docker
# mv /var/lib/docker /var/lib/docker.old

mkdir -p /u01/var/lib/kubelet
sed -i 's#$KUBELET_EXTRA_ARGS#$KUBELET_EXTRA_ARGS --root-dir=/u01/var/lib/kubelet#' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
rsync -aP /var/lib/kubelet /u01/var/lib/kubelet

systemctl daemon-reload

systemctl start docker
systemctl start kubelet

systemctl status docker
systemctl status kubelet
