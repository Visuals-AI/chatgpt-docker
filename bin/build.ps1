# Powershell
# ------------------------
# ��������
# bin/base_build.ps1 [-c OFF]
#   -c �Ƿ����û��湹��: OFF/ON(Ĭ��)
# ------------------------


param([string]$c="ON")
$CACHE = $c

function del_image([string]$image_name) {
    $image_id = (docker images -q --filter reference=${image_name})
    if(![String]::IsNullOrEmpty(${image_id})) {
        Write-Host "delete [${image_name}] ..."
        docker image rm -f ${image_id}
        Write-Host "done ."
    }
}

function build_image([string]$image_name, [string]$dockerfile) {
    del_image -image_name ${image_name}
    if ("x${CACHE}" -eq "xOFF") {
        docker build --no-cache -t ${image_name} -f ${dockerfile} .
    } else {
        docker build -t ${image_name} -f ${dockerfile} .
    }
}


Write-Host "build image ..."
$IMAGE_NAME = (Split-Path $pwd -leaf)
build_image -image_name ${IMAGE_NAME} -dockerfile "Dockerfile"
docker-compose build

docker image ls | Select-String "${IMAGE_NAME}"
Write-Host "finish ."