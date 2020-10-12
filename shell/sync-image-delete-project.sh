#!/bin/bash
# 从远端同步镜像至harbor,并删除镜像的项目名，统一为docker.io

set -e

origin_image=$1
short_image=$(echo "$1" | rev | cut -d/ -f1 | rev)
target_image=${2-"harbor.beautytiger.com/docker.io/${short_image}"}
echo "${origin_image} ------> ${target_image}"

docker pull ${origin_image}
docker tag ${origin_image} ${target_image}
docker push ${target_image}
echo "finish ,you can pull image: ${target_image}"
