#!/bin/bash

set -e

IMAGE_FILE='images.txt'

for image in $(cat ${IMAGE_FILE}); do
    target_image=${1-"harbor.beautytiger.com/${image#harbor.beautytiger.cn/}"}
    echo "${image} ------> ${target_image}"
    docker tag ${image} ${target_image}
    docker push ${target_image}
done
