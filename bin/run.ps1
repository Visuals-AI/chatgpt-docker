# Powershell
#------------------------------------------------
# ���� docker ����������Ҫʵʱ���������� IP����Ҫ����ԱȨ��ִ�У�
# bin/run.ps1
#           [-p ${PROTOCOL}]            # ҳ��ʹ�� http/https Э�飨Ĭ�� http��
#           [-d ${DOMAIN}]              # �Թ�������������������ʵ�ַ��
#           [-i ${IP}]                  # ������ IP��Ĭ��ͨ������ȡ���� IP�������Ҫ�������ʣ�������Ϊ���� IP��
#           [-k ${OPENAI_API_KEY}]      # ChatGPT API key
#           [-m ${OPENAI_MODEL}]        # ChatGPT Model: gpt-4, gpt-4-0314, gpt-4-0613, gpt-4-32k, gpt-4-32k-0314, gpt-4-32k-0613, gpt-3.5-turbo-16k, gpt-3.5-turbo-16k-0613, gpt-3.5-turbo, gpt-3.5-turbo-0301, gpt-3.5-turbo-0613, text-davinci-003, text-davinci-002, code-davinci-002
#           [-s ${SOCKS_PROXY_HOST}]    # Socks5 ������񣬺� HTTP ��ѡһ����ʽ���� host.docker.internal
#           [-r ${SOCKS_PROXY_PORT}]    # Socks5 �������˿�
#           [-h ${HTTPS_PROXY}]         # HTTP ������񣬺� Socks5 ��ѡһ����ʽ���� http://host.docker.internal:10088
#------------------------------------------------
# ע�� host.docker.internal �� docker �ڷ����������ϵķ���Ĺ̶���ַ
#------------------------------------------------

param(
    [string]$t = "http",
    [string]$d = "local.chatgpt.com",
    [string]$i = "", 
    [string]$u = "chatgpt", 
    [string]$p = "TPGtahc#654321", 
    [string]$k = "", 
    [string]$m = "gpt-3.5-turbo", 
    [string]$s = "", 
    [string]$r = "", 
    [string]$h = ""
)

$PROTOCOL = $t
$DOMAIN = $d
$INTER_IP = $i
$USERNAME = $u
$PASSWORD = $p
$OPENAI_API_KEY = $k
$OPENAI_MODEL = $m
$SOCKS_PROXY_HOST = $s
$SOCKS_PROXY_PORT = $r
$HTTPS_PROXY = $h


if (-not $INTER_IP) {
  $interfaces = @("Wi-Fi", "Ethernet", "��̫��")
  foreach ($int in $interfaces) {
    if ($output = (ipconfig $int 2>$null | Select-String -Pattern 'IPv4 Address')) {
      $INTER_IP = $output -replace '.*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*', '$1'
      break
    }
  }

  if (-not $INTER_IP) {
    $INTER_IP = "127.0.0.1"
  }
}

function Set-Dns {
  param(
    [string]$DOMAIN,
    [string]$INTER_IP
  )

  $dns_file = "C:\Windows\System32\drivers\etc\hosts"
  if (Select-String -Path $dns_file -Pattern $DOMAIN) {
    $from_reg = "^[0-9.]* ${DOMAIN}$"
    $to_str = "${INTER_IP} ${DOMAIN}"
    (Get-Content -Path $dns_file) -replace $from_reg, $to_str | Set-Content -Path $dns_file
    if (-not $?) {
      Write-Host "In order to update the inter IP in local hosts, please use 'Run as administrator' ..."
    }
  } else {
    Add-Content -Path $dns_file -Value "$INTER_IP $DOMAIN"
  }
}

function Set-Env {
  $env_file = ".env"
  "DOMAIN=$DOMAIN" | Out-File -Encoding utf8 -FilePath $env_file
  "INTER_IP=$INTER_IP" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "PROTOCOL=$PROTOCOL" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "OPENAI_API_KEY=$OPENAI_API_KEY" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "OPENAI_MODEL=$OPENAI_MODEL" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "SOCKS_PROXY_HOST=$SOCKS_PROXY_HOST" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "SOCKS_PROXY_PORT=$SOCKS_PROXY_PORT" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "HTTPS_PROXY=$HTTPS_PROXY" | Out-File -Encoding utf8 -Append -FilePath $env_file
  Write-Host "$INTER_IP $DOMAIN"
}

# �޷����ݶ��û����������������������
# python3 ./py/gen_basicauth.py -u "$USERNAME" -p "$PASSWORD"

Set-Dns -DOMAIN $DOMAIN -INTER_IP $INTER_IP
Set-Env


docker-compose up -d
docker ps
Write-Host "Docker is running: ${PROTOCOL}://${DOMAIN}:7080"
