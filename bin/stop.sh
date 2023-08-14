#!/bin/bash
#------------------------------------------------
# 停止 docker 服务
# bin/stop.sh
#       [--keepdb]      # 可选参数: 保留 DB 服务不停止
#------------------------------------------------

KEEP_DB=$1
if [ "x${KEEP_DB}" == "x--keepdb" ]; then
    docker ps | grep "vul-" | grep -v -e "redis" -e "mysql" | awk '{print $1}' | xargs docker stop

else
    MODULES_DOCKERFILES=`./bin/_load_modules.sh`
    docker-compose -f docker-compose.yml \
        ${MODULES_DOCKERFILES} \
        down

    echo "Docker is stopped ."
fi
