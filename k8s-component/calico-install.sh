#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

HARBOR_URL='harbor.beautytiger.com'

# https://docs.projectcalico.org/maintenance/troubleshoot/troubleshooting#configure-networkmanager
cat > /etc/NetworkManager/conf.d/calico.conf <<EOF
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
EOF

sed -i "s#image: calico#image: ${HARBOR_URL}/calico#g" calico.yaml
kubectl apply -f calico.yaml
