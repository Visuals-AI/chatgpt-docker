#!/bin/bash
#------------------------------------------------
# 初始化数据库
# bin/init_db.sh
#------------------------------------------------

DEFAULT_DB_NAME="vulhub"
DB_USER="root"
DB_PASS="N8vV9modVBznVFXq"
DB_CHARSET="utf8mb4"
DOCKER_NAME="vul-mysql"
DOCKER_ID=`docker ps -aq --filter name=${DOCKER_NAME}`

DB_SQL_DIR="./sql/dbs"
TABLE_SQL_DIR="./sql/tables"
DATA_SQL_DIR="./sql/datas"
DOCKER_SQL_DIR="/tmp"


# 导入指定目录下的全部 sql 脚本
function exec_sqls {
  script_dir=$1
  create_db=$2
  for file in `ls ${script_dir}`
  do
    if [ "x${file##*.}" = "xsql" ] ; then
      exec_sql "${script_dir}/${file}" "${DOCKER_SQL_DIR}/${file}" $create_db
    fi
  done
}

# 把某个 sql 脚本拷贝到 docker 中导入
function exec_sql {
  srcpath=$1
  snkpath=$2
  create_db=$3
  if [ -s ${srcpath} ]; then
    echo "Exec [${srcpath}] ..."
    docker cp ${srcpath} ${DOCKER_ID}:${snkpath}

    if [ "$create_db" = "True" ]; then
      docker exec -u root ${DOCKER_ID} /bin/bash -c "mysql --default-character-set=${DB_CHARSET} -u ${DB_USER} -p${DB_PASS} < ${snkpath}"
    else
      docker exec -u root ${DOCKER_ID} /bin/bash -c "mysql --default-character-set=${DB_CHARSET} -u ${DB_USER} -p${DB_PASS} ${DEFAULT_DB_NAME} < ${snkpath}"
    fi
  fi
}


echo "Init the Database ..."
if [ ! -z "${DOCKER_ID}" ]; then
  # 构建数据库
  exec_sqls ${DB_SQL_DIR} "True"

  # 构建表
  exec_sqls ${TABLE_SQL_DIR} "False"

  # 导入数据
  exec_sqls ${DATA_SQL_DIR} "False"
else
  echo "Database has not running ..."
fi
echo "Finish."
exit 0