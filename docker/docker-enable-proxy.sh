#!/usr/bin/env bash
# docker启用本地代理

set -o errexit
set -o nounset
set -o pipefail

cat > /etc/systemd/system/docker.service.d/http_proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=socks5://192.168.28.6:1080/"
Environment="HTTPS_PROXY=socks5://192.168.28.6:1080/"
Environment="NO_PROXY=localhost,127.0.0.1,m1empwb1.mirror.aliyuncs.com,registry.cn-hangzhou.aliyuncs.com,cluster.local"
EOF

systemctl daemon-reload 
systemctl restart docker.service
systemctl show --property=Environment docker
