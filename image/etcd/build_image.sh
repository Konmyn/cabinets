#!/usr/bin/env bash

images=(
    'harbor.beautytiger.com/k8s.gcr.io/etcd:3.4.13-centos'
)
for image in ${images[@]}; do
    docker build -t "$image" .
    docker push "$image"
done
