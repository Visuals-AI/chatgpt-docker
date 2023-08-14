#!/bin/bash
# ------------------------
# 构建子模块镜像
# bin/build.sh --recompile
# ------------------------
# 由于子模块均依赖基础镜像，需要在 base_deploy.sh 之后执行
# ------------------------

BASE_DIR=`pwd`
VULHUB_DIR="vulhub"
VULBASE_DIR="${VULHUB_DIR}/vul-base"
TARGET_DIR="${VULBASE_DIR}/target"

# jar 包的解密密码，需要和 bin/run.sh 保持一致，请勿泄露给渗透测试人员或随意变更，否则无法解密
ENCRYPT_PASSWORD="6nMtd2sWQ6p3RMmTqyHh"


REBUILD=$1
if [ ! -d "${TARGET_DIR}" ]; then
    REBUILD="--recompile"
fi

# 预编译靶场后端代码
if [ "x${REBUILD}" = "x--recompile" ]; then

    # 打包依赖工程(父工程)
    echo "precompiled ${VULHUB_DIR} pom ..."
    cd "${VULHUB_DIR}"
    mvn "-Dmaven.test.skip=true" clean install -N
    cd "${BASE_DIR}"


    # 打包基础后端代码
    echo "precompiled ${VULBASE_DIR} code ..."
    cd "${VULBASE_DIR}"
    mvn "-Dmaven.test.skip=true" clean install -P toLibJar
    mvn "-Dmaven.test.skip=true" clean install -P toResWar
    mvn "-Dmaven.test.skip=true" "-Dencrypt.password=${ENCRYPT_PASSWORD}" clean package -P toFatJar
    cd "${BASE_DIR}"


    # 打包各个场景子模块
    bin/_build_modules.sh
fi


echo "load sub modules info ..."
MODULES_DOCKERFILES=`./bin/_load_modules.sh`


echo "build sub modules image ..."
docker-compose -f docker-compose.yml \
${MODULES_DOCKERFILES} \
build


echo "finish ."
