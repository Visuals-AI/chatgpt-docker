#!/bin/bash
# ----------------------------------------

# 复制挂载目录的配置文件到 nginx
MOUNT_DIR="/tmp/nginx/etc"
SITE_ETC_DIR="/etc/nginx/conf.d"
cp -r ${MOUNT_DIR}/* ${SITE_ETC_DIR}


# 以 HTTP/HTTPS 协议启动 nginx
HTTP_CONF="${SITE_ETC_DIR}/vulhub_http.conf"
HTTPS_CONF="${SITE_ETC_DIR}/vulhub_https.conf"
VULHUB_CONF="${SITE_ETC_DIR}/default.conf"
rm -f ${VULHUB_CONF}
if [[ ${PROTOCOL} = "https" ]]; then
    mv ${HTTPS_CONF} ${VULHUB_CONF}
    rm -f ${HTTP_CONF}
else
    mv ${HTTP_CONF} ${VULHUB_CONF}
    rm -f ${HTTPS_CONF}
fi
sed -i "s/YOUR_DOMAIN/${NGINX_DOMAIN}/g" ${VULHUB_CONF}
sed -i "s/VULHUB_VPC_IP/${VULHUB_VPC_IP}/g" ${VULHUB_CONF}
sed -i "s@TRUSTED_VPC_IP@${TRUSTED_VPC_IP}@g" ${VULHUB_CONF}


# 读取子模块清单，删除不在清单内的子模块接口，仅暴露注册的子模块接口
MODULES_FILE="/var/tmp/.modules.yml"
MODULES_DIR="${SITE_ETC_DIR}/shared"
MODULES=$(grep -v '^#' $MODULES_FILE)
for MODULE in ${MODULES}
do
    vulname=$(basename ${MODULE})
    cnfname="${vulname}.conf"
    cnfpath="${MODULES_DIR}/${cnfname}"

    if [ -e "${cnfpath}" ]; then
        echo "Keep vul [${vulname}] interface ."
    else
        echo "Remove vul [${vulname}] interface ."
        rm -f ${cnfpath}
    fi
done



# 启动系统日志
service rsyslog start

# 启动 nginx
nginx


