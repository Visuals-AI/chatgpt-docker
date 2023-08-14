# Powershell
#------------------------------------------------
# 停止 docker 服务
# bin/stop.ps1
#       [--keepdb]      # 可选参数: 保留 DB 服务不停止
#------------------------------------------------

param (
    [string]$keepdb
)

if ($keepdb -eq "--keepdb") {
    docker ps | Select-String "vul-" | Select-String -NotMatch -Pattern "redis|mysql" | ForEach-Object {
        docker stop $_.ToString().Split(" ")[-1]
    }
} else {
    $MODULES_DOCKERFILES = & ".\bin\_load_modules.ps1"
    docker-compose -f docker-compose.yml `
        $MODULES_DOCKERFILES `
        down

    Write-Host "Docker is stopped ."
}
