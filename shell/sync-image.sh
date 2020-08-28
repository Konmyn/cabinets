#!/bin/bash
# 从远端同步镜像至harbor

set -e
if [[ "$1" == "" ]]; then
    echo "$0 origin_image target_image"
    echo "$0 quay.io/k8scsi/csi-attacher:v0.3.0 harbor.beautytiger.com/quay.io/k8scsi/csi-attacher:v0.3.0"
    echo "default target_image=harbor.beautytiger.com/${origin_image}"
    exit 1
fi
origin_image=$1
if [[ $origin_image == *"/"* ]]; then
    target_image=${2-"harbor.beautytiger.com/${origin_image}"}
else
    target_image=${2-"harbor.beautytiger.com/docker.io/${origin_image}"}
fi
echo "${origin_image} ------> ${target_image}"

docker pull ${origin_image}
docker tag ${origin_image} ${target_image}
docker push ${target_image}
echo "finish ,you can pull image: ${target_image}"
