#!/usr/bin/env bash
# docker禁用本地代理

set -o errexit
set -o nounset
set -o pipefail

rm /etc/systemd/system/docker.service.d/http_proxy.conf

systemctl daemon-reload
systemctl restart docker
systemctl show --property=Environment docker
