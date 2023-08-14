# Powershell
#------------------------------------------------
# 初始化数据库
# bin/init_db.ps1
#------------------------------------------------

$DEFAULT_DB_NAME = "vulhub"
$DB_USER = "root"
$DB_PASS = "N8vV9modVBznVFXq"
$DB_CHARSET = "utf8mb4"
$DOCKER_NAME = "vul-mysql"
$DOCKER_ID = (docker ps -aq --filter name=${DOCKER_NAME})

$DB_SQL_DIR = "./sql/dbs"
$TABLE_SQL_DIR = "./sql/tables"
$DATA_SQL_DIR = "./sql/datas"
$DOCKER_SQL_DIR = "/tmp"


# 导入指定目录下的全部 sql 脚本
# ----------------------
function exec_sqls([string]$script_dir, [bool]$create_db=$False) {
  $files = Get-ChildItem ${script_dir} -recurse "*.sql"
  Foreach($file in ${files}) {
    exec_sql "${script_dir}/${file}" "${DOCKER_SQL_DIR}/${file}" $create_db
  }
}


# 把某个 sql 脚本拷贝到 docker 中导入
# ----------------------
function exec_sql([string]$srcpath, [string]$snkpath, [bool]$create_db) {
  if(![String]::IsNullOrEmpty(${srcpath})) {
    Write-Host "Exec [${srcpath}] ..."
    docker cp ${srcpath} ${DOCKER_ID}:${snkpath}

    if($create_db -eq $True) {
      docker exec -u root ${DOCKER_ID} /bin/bash -c "mysql --default-character-set=${DB_CHARSET} -u ${DB_USER} -p${DB_PASS} < ${snkpath}"
    } else {
      docker exec -u root ${DOCKER_ID} /bin/bash -c "mysql --default-character-set=${DB_CHARSET} -u ${DB_USER} -p${DB_PASS} ${DEFAULT_DB_NAME} < ${snkpath}"
    }
  }
}


Write-Host "Init the Database ..."
if(![String]::IsNullOrEmpty($DOCKER_ID)) {

  # 构建数据库
  # ---------------
  exec_sqls ${DB_SQL_DIR} $True

  # 构建表
  # ---------------
  exec_sqls ${TABLE_SQL_DIR} $False

  # 导入数据
  # ---------------
  exec_sqls ${DATA_SQL_DIR} $False

} else {
  Write-Host "Database has not running ..."
}
Write-Host "Finish."
exit 0