# Powershell
#------------------------------------------------
# ���� docker ����������Ҫʵʱ���������� IP����Ҫ����ԱȨ��ִ�У�
# sudo bin/run.ps1
#           [-p ${PROTOCOL}]            # ҳ��ʹ�� http/https Э�飨Ĭ�� http��
#           [-d ${DOMAIN}]              # ��������
#           [-i ${IP}]                  # ������ IP��Ĭ��ͨ������ȡ���� IP�������Ҫ�������ʣ�������Ϊ���� IP��
#------------------------------------------------

param(
    [string]$Protocol = "http",
    [string]$Domain = "web.music.com",
    [string]$IP = ""
)


if (-not $IP) {
  $interfaces = @("Wi-Fi", "Ethernet", "��̫��")
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
    [string]$Domain,
    [string]$InterIP,
    [string]$Protocol
  )

  $env_file = ".env"
  "DOMAIN=$Domain" | Out-File -Encoding utf8 -FilePath $env_file
  "INTER_IP=$InterIP" | Out-File -Encoding utf8 -Append -FilePath $env_file
  "PROTOCOL=$Protocol" | Out-File -Encoding utf8 -Append -FilePath $env_file
  Write-Host "$InterIP $Domain"
}

Set-Dns -Domain $Domain -InterIP $IP
Set-Env -Domain $Domain -InterIP $IP -Protocol $Protocol



docker-compose up -d

docker ps
Write-Host "Docker is running: ${Protocol}://${Domain}"
