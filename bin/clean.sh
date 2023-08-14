#!/bin/bash
#------------------------------------------------
# 清理镜像、日志
# bin/clean.sh
#------------------------------------------------

echo "clean logs ..."
rm -rf logs

echo "clean sub modules ..."
bin/_clean_modules.sh

echo "clean images ..."
docker rmi -f $(docker images | grep "vulhub" | awk '{print $3}')
docker rmi -f $(docker images | grep "none" | awk '{print $3}')

echo "finish ."