#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

proxy='-x socks5h://127.0.0.1:1080'
info_file='completed.info'

# https://sdk.operatorframework.io/docs/installation/install-operator-sdk/#install-from-github-release
RELEASE_VERSION=v1.0.1
echo "${RELEASE_VERSION}"
if [[ -d ${RELEASE_VERSION} ]]; then
    echo "dir already exists"
else
    echo "make release dir"
    mkdir "${RELEASE_VERSION}"
fi
pushd "${RELEASE_VERSION}"

if [[ -f ${info_file} ]]; then
    echo "file already downloaded"
else
    echo "start download file"
    curl -L ${proxy} https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu -o operator-sdk
    curl -L ${proxy} https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/ansible-operator-${RELEASE_VERSION}-x86_64-linux-gnu -o ansible-operator
    curl -L ${proxy} https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/helm-operator-${RELEASE_VERSION}-x86_64-linux-gnu -o helm-operator
    chmod a+x operator-sdk ansible-operator helm-operator
    # 复制到go bin path下
    cp * ~/go/bin/
    touch ${info_file}
fi
popd
