# Powershell
#------------------------
# 构建子模块镜像
# bin/build.ps1 --recompile
#------------------------
# 由于子模块均依赖基础镜像，需要在 base_deploy.ps1 之后执行
#------------------------

$BASE_DIR = Get-Location
$VULHUB_DIR = "vulhub"
$VULBASE_DIR = "${VULHUB_DIR}/vul-base"
$TARGET_DIR = Join-Path -Path $VULBASE_DIR -ChildPath "target"

# jar 包的加密密码，需要和 bin/run.ps1 保持一致，请勿泄露给渗透测试人员或随意变更，否则无法解密
$ENCRYPT_PASSWORD = "6nMtd2sWQ6p3RMmTqyHh"


$REBUILD = $args[0]
if (-not (Test-Path $TARGET_DIR)) {
    $REBUILD = "--recompile"
}


# 预编译靶场后端代码
if ($REBUILD -eq "--recompile") {

    # 打包依赖工程(父工程)
    Write-Host "precompiled ${VULHUB_DIR} pom ..."
    Set-Location -Path ${VULHUB_DIR}
    mvn "-Dmaven.test.skip=true" clean install -N
    Set-Location -Path ${BASE_DIR}


    # 打包基础后端代码
    Write-Host "precompiled ${VULBASE_DIR} code ..."
    Set-Location -Path ${VULBASE_DIR}
    mvn "-Dmaven.test.skip=true" clean install -P toLibJar
    mvn "-Dmaven.test.skip=true" clean install -P toResWar
    mvn "-Dmaven.test.skip=true" "-Dencrypt.password=${ENCRYPT_PASSWORD}" clean package -P toFatJar
    Set-Location -Path ${BASE_DIR}


    # 打包各个子模块
    & ".\bin\_build_modules.ps1"
}


Write-Host "load sub modules info ..."
$MODULES_DOCKERFILES = & ".\bin\_load_modules.ps1"


Write-Host "build sub modules image ..."
docker-compose -f docker-compose.yml `
$MODULES_DOCKERFILES `
build

Write-Host "finish."
