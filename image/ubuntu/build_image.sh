#!/usr/bin/env bash

images=(
    'harbor.beautytiger.com/docker.io/ubuntu:rich'
)
for image in ${images[@]}; do
    docker build -t "$image" .
    docker push "$image"
done
