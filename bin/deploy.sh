#!/bin/bash
# ------------------------
# 发布镜像
# bin/deploy.sh [-n NAMESPACE] [-v VERSION]
#   -n docker hub 的命名空间
#   -v 镜像版本号
# ------------------------

NAMESPACE="expm02"
VERSION=$(date "+%Y%m%d%H")

set -- `getopt n:v: "$@"`
while [ -n "$1" ]
do
  case "$1" in
    -n) NAMESPACE="$2"
        shift ;;
    -v) VERSION="$2"
        shift ;;
  esac
  shift
done

function deploy_image {
    image_name=$1
    remote_url=${NAMESPACE}/${image_name}
    docker tag ${image_name} ${remote_url}:${VERSION}
    docker push ${remote_url}:${VERSION}
    docker tag ${image_name} ${remote_url}:latest
    docker push ${remote_url}:latest
    echo "Pushed to ${remote_url}"
}


echo "Login to docker hub ..."
docker login

docker tag chatgpt-docker_chatgpt-web:latest chatgpt-web-docker:latest
deploy_image "chatgpt-web-docker"

docker tag chatgpt-docker_chatgpt-nginx:latest chatgpt-nginx-docker:latest
deploy_image "chatgpt-nginx-docker"

docker images | grep chatgpt
echo "finish ."