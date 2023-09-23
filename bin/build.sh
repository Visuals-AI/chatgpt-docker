#!/bin/bash
# ------------------------
# 构建基础镜像
# bin/base_build.sh
# ------------------------


echo "build image ..."
docker-compose build

docker image ls | grep "${IMAGE_NAME}"
echo "finish ."
