# Powershell
#------------------------------------------------
# 运行 docker 服务（由于需要实时解析局域网 IP，需要管理员权限执行）
# sudo bin/run.ps1
#           [-p ${PROTOCOL}]            # 页面使用 http/https 协议（默认 http）
#           [-d ${DOMAIN}]              # 服务域名
#           [-i ${IP}]                  # 服务器 IP（默认通过网卡取内网 IP，如果需要公网访问，需设置为公网 IP）
#           [-s db]                     # 只启动数据库服务
#------------------------------------------------

param(
    [string]$Protocol = "http",
    [string]$Domain = "local.chatgpt.com",
    [string]$IP = "",
    [string]$DB_SVC = "", 
    [string]$TRUSTED_VPC_IP = "172.168.200.200"
)


if (-not $IP) {
  $interfaces = @("Wi-Fi", "Ethernet", "以太网")
  foreach ($int in $interfaces) {
    if ($output = (ipconfig $int 2>$null | Select-String -Pattern 'IPv4 Address')) {
      $IP = $output -replace '.*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*', '$1'
      break
    }
  }

  if (-not $IP) {
    $IP = "127.0.0.1"
  }
}

function Set-Dns {
  param(
    [string]$Domain,
    [string]$InterIP
  )

  $dns_file = "C:\Windows\System32\drivers\etc\hosts"
  if (Select-String -Path $dns_file -Pattern $Domain) {
    $from_reg = "^[0-9.]* ${Domain}$"
    $to_str = "${InterIP} ${Domain}"
    (Get-Content -Path $dns_file) -replace $from_reg, $to_str | Set-Content -Path $dns_file
    if (-not $?) {
      Write-Host "In order to update the inter IP in local hosts, please use 'Run as administrator' ..."
    }
  } else {
    Add-Content -Path $dns_file -Value "$InterIP $Domain"
  }
}

function Set-Env {
  param(
    [string]$jarPwd, 
    [string]$jasyptPwd, 
    [string]$Domain,
    [string]$InterIP,
    [string]$Protocol, 
    [string]$TrustedIP
  )

  $env_file = ".env"
  "CONFUSE_PWD=$JarPwd" | Out-File -Encoding utf8 -FilePath $env_file
  "JASYPT_PWD=${jasypt_pwd}" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "DOMAIN=$Domain" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "INTER_IP=$InterIP" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "PROTOCOL=$Protocol" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "TRUSTED_VPC_IP=${TrustedIP}" | Out-File -Encoding utf8 -Append -FilePath $env_file
  Write-Host "$InterIP $Domain"
}

Set-Dns -Domain $Domain -InterIP $IP
Set-Env -JarPwd $DECRYPT_PASSWORD -jasyptPwd $JASYPT_PWD -Domain $Domain -InterIP $IP -Protocol $Protocol -TrustedIP $TRUSTED_VPC_IP 


$MODULES_DOCKERFILES = & ".\bin\_load_modules.ps1"
if ($DB_SVC -eq "db") {
  $MODULES_DOCKERFILES = ""
}

docker-compose -f docker-compose.yml $MODULES_DOCKERFILES up -d

docker ps
Write-Host "Docker is running: ${Protocol}://${Domain}"
Write-Host "(You can control the scene that needs to be started by modifying 'bin/_modules.yml')"
