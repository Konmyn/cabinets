#!/usr/bin/env bash
# 从tekton的yaml定义中解析并同步镜像

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

REGISTRY_DOMAIN='harbor.beautytiger.com'
KEY_WORD='gcr.io'

IMAGE_LIST_FILE="tekton-images.txt"
TAG_PREFIX='tekton-v0.6.0-'
RAW_YAML_FILE='raw-tekton-v0.6.0.yaml'
TARGET_YAML_FILE='tekton-v0.6.0.yaml'

# 从yaml文件中抓取镜像列表,并输出到文件
function get_image_list_file() {
    grep $KEY_WORD $RAW_YAML_FILE | awk -F' ' '{ print $NF }' | uniq >$IMAGE_LIST_FILE
}

# 同步文件中的镜像列表:拉取镜像,并推送到本地harbor
function sync_image() {
    for image in $(cat ${IMAGE_LIST_FILE}); do
        new_image=$(new_image_name $image)
        echo "$image -> $new_image"
        docker pull $image
        docker tag $image $new_image
        docker push $new_image
    done
}

# 根据原镜像获取本地镜像名,需要原镜像的域名作为harbor的项目名,项目为公开
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

# 替换原yaml中的镜像为本地harbor中的镜像,生成新的yaml文件
function generate_new_yaml() {
    cp $RAW_YAML_FILE $TARGET_YAML_FILE
    for image in $(cat ${IMAGE_LIST_FILE}); do
        new_image=$(new_image_name $image)
        sed -i "s|${image}|${new_image}|g" $TARGET_YAML_FILE
    done
}

action=${1-default}
case $action in
sync)
    echo "Sync images in image list"
    sync_image
    ;;
image)
    echo "Generating image list from yaml"
    get_image_list_file
    ;;
yaml)
    echo "Replace new image from yaml into new yaml"
    generate_new_yaml
    ;;
*)
    echo "Not defined action"
    ;;
esac
