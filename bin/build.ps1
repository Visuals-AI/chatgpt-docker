# Powershell
# ------------------------
# ¹¹½¨¾µÏñ
# bin/base_build.ps1
# ------------------------


Write-Host "build image ..."
docker-compose build

docker image ls | Select-String "${IMAGE_NAME}"
Write-Host "finish ."