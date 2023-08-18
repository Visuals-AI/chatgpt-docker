#!/bin/bash
#------------------------------------------------
# 运行 docker 服务（由于需要实时解析局域网 IP，需要 sudo 权限执行）
# sudo bin/run.sh
#           [-t ${PROTOCOL}]            # 页面使用 http/https 协议（默认 http）
#           [-d ${DOMAIN}]              # 对公服务域名（浏览器访问地址）
#           [-i ${IP}]                  # 服务器 IP（默认通过网卡取内网 IP，如果需要公网访问，需设置为公网 IP）
#           [-u ${USERNAME}]            # ChatGPT Web 登录账户（BasicAuth）
#           [-p ${PASSWORD}]            # ChatGPT Web 登录密码（BasicAuth）
#           [-k ${OPENAI_API_KEY}]      # ChatGPT API key
#           [-m ${OPENAI_MODEL}]        # ChatGPT Model: gpt-4, gpt-4-0314, gpt-4-0613, gpt-4-32k, gpt-4-32k-0314, gpt-4-32k-0613, gpt-3.5-turbo-16k, gpt-3.5-turbo-16k-0613, gpt-3.5-turbo, gpt-3.5-turbo-0301, gpt-3.5-turbo-0613, text-davinci-003, text-davinci-002, code-davinci-002
#           [-s ${SOCKS_PROXY_HOST}]    # Socks5 代理服务，和 HTTP 二选一，格式形如 host.docker.internal
#           [-r ${SOCKS_PROXY_PORT}]    # Socks5 代理服务端口
#           [-h ${HTTPS_PROXY}]         # HTTP 代理服务，和 Socks5 二选一，格式形如 http://host.docker.internal:10088
#------------------------------------------------
# 注： host.docker.internal 是 docker 内访问宿主机上的服务的固定地址
#------------------------------------------------

PROTOCOL="http"
DOMAIN="local.chatgpt.com"
INTER_IP=""
USERNAME="chatgpt"
PASSWORD="TPGtahc#654321"
OPENAI_API_KEY=""
OPENAI_MODEL="gpt-3.5-turbo"
SOCKS_PROXY_HOST=""
SOCKS_PROXY_PORT=""
HTTPS_PROXY=""


set -- `getopt t:d:i:u:p:k:m:s:r:h: "$@"`
while [ -n "$1" ]
do
  case "$1" in
    -t) PROTOCOL="$2"
        shift ;;
    -d) DOMAIN="$2"
        shift ;;
    -i) INTER_IP="$2"
        shift ;;
    -u) USERNAME="$2"
        shift ;;
    -p) PASSWORD="$2"
        shift ;;
    -k) OPENAI_API_KEY="$2"
        shift ;;
    -m) OPENAI_MODEL="$2"
        shift ;;
    -s) SOCKS_PROXY_HOST="$2"
        shift ;;
    -r) SOCKS_PROXY_PORT="$2"
        shift ;;
    -h) HTTPS_PROXY="$2"
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
  echo "DOMAIN=${DOMAIN}" > ${ENV_FILE}
  echo "INTER_IP=${INTER_IP}" >> ${ENV_FILE}
  echo "PROTOCOL=${PROTOCOL}" >> ${ENV_FILE}
  echo "OPENAI_API_KEY=${OPENAI_API_KEY}" >> ${ENV_FILE}
  echo "OPENAI_MODEL=${OPENAI_MODEL}" >> ${ENV_FILE}
  echo "SOCKS_PROXY_HOST=${SOCKS_PROXY_HOST}" >> ${ENV_FILE}
  echo "SOCKS_PROXY_PORT=${SOCKS_PROXY_PORT}" >> ${ENV_FILE}
  echo "HTTPS_PROXY=${HTTPS_PROXY}" >> ${ENV_FILE}
}


python3 ./py/gen_basicauth.py -u "$USERNAME" -p "$PASSWORD"
set_dns $DOMAIN $INTER_IP
set_env



docker-compose up -d
docker ps
echo "Docker is running: ${PROTOCOL}://${DOMAIN}:7080"
