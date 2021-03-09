#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

DOCKER_VERSION='19.03.14'
CENTOS_VERSION='7.9.2009'
# CENTOS_VERSION='8.2.2004'
# CENTOS_VERSION='8.3.2011'

OS_BASED_PATH="${CENTOS_VERSION}/${DOCKER_VERSION}"
cd ${OS_BASED_PATH}

echo "installing harbor"

mkdir -p /data /app

chmod a+x harbor/docker-compose
mv harbor/docker-compose /usr/local/bin/docker-compose
tar xf harbor/harbor-offline-installer-v2.1.3.tgz -C /app

cd /app/harbor/
cp harbor.yml.tmpl harbor.yml

# 替换启动域名，其他配置需要手动修改
sed -i 's/reg.mydomain.com/harbor.centos79.beautytiger.com/g' harbor.yml

./install.sh

cat > harbor.service <<-EOF
[Unit]
Description="Harbor (container registry) service by docker-compose"
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
WorkingDirectory=/app/harbor
ExecStart=/usr/local/bin/docker-compose up -d --remove-orphans
ExecStop=/usr/local/bin/docker-compose down

[Install]
WantedBy=multi-user.target
EOF
