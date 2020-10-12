#!/usr/bin/env bash
# 从tekton dashboard的yaml定义同步镜像

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

IMAGE_LIST_FILE="tekton-dashboard-images.txt"
TAG_PREFIX='tekton-dashboard-v0.2.1-'
RAW_YAML_FILE='raw-tekton-dashboard-v0.2.1.yaml'
KEY_WORD='gcr.io'
REGISTRY_DOMAIN='harbor.beautytiger.com'

function get_image_list_file() {
    grep $KEY_WORD $RAW_YAML_FILE | awk -F' ' '{ print $NF }' >$IMAGE_LIST_FILE
}

function sync_image() {
    for image in $(cat ${IMAGE_LIST_FILE}); do
        new_image=$(new_image_name $image)
        echo "$image -> $new_image"
        docker pull $image
        docker tag $image $new_image
        docker push $new_image
    done
}

function new_image_name() {
    local new_image=''
    if [[ $image == *'@sha256:'* ]]; then
        repo="$(cut -d@ -f1 <<<${image})"
        img_name="$(awk -F/ '{ print $NF }' <<<${repo})"
        img_tag="${TAG_PREFIX}${img_name}"
        new_image="$REGISTRY_DOMAIN/$repo:$img_tag"
    else
        new_image="$REGISTRY_DOMAIN/$image"
    fi
    echo $new_image
}

sync_image
