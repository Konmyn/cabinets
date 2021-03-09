#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

IMAGE_FILE='calico-images.txt'
IMAGE_TAR='calico-images.tgz'
HARBOR_URL='harbor.beautytiger.com'

function load_and_push_image() {
    docker load <$IMAGE_TAR
    for image in $(cat ${IMAGE_FILE}); do
        if [[ $image == *"/"* ]]; then
            docker tag $image ${HARBOR_URL}/$image
            docker push ${HARBOR_URL}/$image
        else
            docker tag $image ${HARBOR_URL}/docker.io/$image
            docker push ${HARBOR_URL}/docker.io/$image
        fi
    done
}

load_and_push_image
