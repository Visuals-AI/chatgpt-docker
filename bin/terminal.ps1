# Powershell
#------------------------------------------------
# ���������Ľ����ն�
# bin\terminal.ps1
#------------------------------------------------

# ��ȡ�����б�

$CONTAINER_LIST = docker ps --format "{{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"


# ��ӡ�����б������������ϱ��

Write-Host "Select a container to enter:"
$CONTAINER_LIST | ForEach-Object { $_ -replace "`t", " " } | ForEach-Object { $i=0 } { ++$i; "$i. $_" }


# ��ȡ�û�ѡ����������

$NUMBER = Read-Host "Enter a number (0 for exit):"


# �����û�ѡ���������Ż�ȡ����ID

$CONTAINER_ID = ($CONTAINER_LIST | Select-Object -Skip 1)[$NUMBER-1].Substring(0, 12)


# ���������ն�

if ($CONTAINER_ID) {
    docker exec -it $CONTAINER_ID /bin/bash
} else {
    Write-Host "Invalid container number."
}
