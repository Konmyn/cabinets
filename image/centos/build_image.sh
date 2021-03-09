#!/usr/bin/env bash

images=(
    'harbor.beautytiger.com/docker.io/centos:rich'
)
for image in ${images[@]}; do
    docker build -t "$image" .
    docker push "$image"
done
