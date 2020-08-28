#! /usr/bin/env bash
# 推送镜像到指定的仓库，必须在installer目录底下执行， sh push.sh <registry> <repository>
# export REGISTRY=harbor.beautytiger.com
# export REPOSITORY=library
# push.sh $REGISTRY $REPOSITORY

set -o errexit
set -o nounset
set -o pipefail

image_dir=/data
registry=$1
repository=$2

mkdir -p $image_dir
tar xvzf images.tgz -C $image_dir
docker load <$image_dir/images/registry.tgz
docker run -d -v $image_dir/images:/var/lib/registry -p 5000:5000 --restart=always --name registry docker.io/registry:2
docker_registry_dir=$image_dir/images/docker/registry/v2/repositories
for repo in $(ls $docker_registry_dir); do
    for name in $(ls $docker_registry_dir/$repo/); do
        for tag in $(ls $docker_registry_dir/$repo/$name/_manifests/tags); do
            docker pull 127.0.0.1:5000/$repo/$name:$tag
            docker tag 127.0.0.1:5000/$repo/$name:$tag $registry/$repository/$name:$tag
            docker push $registry/$repository/$name:$tag
        done
    done
done
docker rm -f registry
