#!/bin/bash
#------------------------------------------------
# 运行 docker 服务（由于需要实时解析局域网 IP，需要 sudo 权限执行）
# sudo bin/run.sh
#           [-p ${PROTOCOL}]            # 页面使用 http/https 协议（默认 http）
#           [-d ${DOMAIN}]              # 服务域名
#           [-i ${IP}]                  # 服务器 IP（默认通过网卡取内网 IP，如果需要公网访问，需设置为公网 IP）
#           [-s db]                     # 只启动数据库服务
#------------------------------------------------

PROTOCOL="http"
DOMAIN="local.chatgpt.com"
DB_SVC=""
INTER_IP=""
TRUSTED_VPC_IP="172.168.200.200"


set -- `getopt p:d:i:s:t: "$@"`
while [ -n "$1" ]
do
  case "$1" in
    -u) PROTOCOL="$2"
        shift ;;
    -d) DOMAIN="$2"
        shift ;;
    -i) INTER_IP="$2"
        shift ;;
    -s) DB_SVC="$2"
        shift ;;
    -t) TRUSTED_VPC_IP="$2"
        shift ;;
  esac
  shift
done

if [[ -z "${INTER_IP}" ]]; then
  interface=("en0" "eth0")
  for int in "${interface[@]}"; do
    if INTER_IP=$(ifconfig "$int" 2>/dev/null | awk '/inet / {print $2}'); then
      break
    fi
  done

  if [[ -z "${INTER_IP}" ]]; then
    INTER_IP="127.0.0.1"
  fi
fi


# 修改本地 hosts 文件，在本地解析域名
function set_dns {
  DNS_FILE="/etc/hosts"
  domain=$1
  inter_ip=$2
  
  if [ `grep -c "${domain}" ${DNS_FILE}` -ne '0' ]; then
      FROM_REG="^[0-9.]* ${domain}$"
      TO_STR="${inter_ip} ${domain}"
      sed -i '' -E "s/${FROM_REG}/${TO_STR}/" ${DNS_FILE}
      if [ ! $? = 0 ]; then
        echo "In order to update the inter IP in local hosts, please use 'sudo' ..."
      fi
  else
      echo "${inter_ip} ${domain}" >> ${DNS_FILE}
  fi
}


# 写入 docker-compose 的 .env 文件
function set_env {
  ENV_FILE=".env"
  jar_pwd=$1
  jasypt_pwd=$2
  domain=$3
  inter_ip=$4
  protocol=$5
  trusted_ip=$6

  echo "CONFUSE_PWD=${jar_pwd}" > ${ENV_FILE}
  echo "JASYPT_PWD=${jasypt_pwd}" >> ${ENV_FILE}
  echo "DOMAIN=${domain}" >> ${ENV_FILE}
  echo "INTER_IP=${inter_ip}" >> ${ENV_FILE}
  echo "PROTOCOL=${protocol}" >> ${ENV_FILE}
  echo "TRUSTED_VPC_IP=${trusted_ip}" >> ${ENV_FILE}
  echo "${inter_ip} ${domain}"
}


set_dns $DOMAIN $INTER_IP
set_env $DECRYPT_PASSWORD $JASYPT_PWD $DOMAIN $INTER_IP $PROTOCOL $TRUSTED_VPC_IP


MODULES_DOCKERFILES=`./bin/_load_modules.sh`
if [ "x${DB_SVC}" = "xdb" ]; then
  MODULES_DOCKERFILES=""
fi

docker-compose -f docker-compose.yml ${MODULES_DOCKERFILES} up -d


docker ps
echo "Docker is running: ${PROTOCOL}://${DOMAIN}"
echo "(You can control the scene that needs to be started by modifying 'bin/_modules.yml')"
