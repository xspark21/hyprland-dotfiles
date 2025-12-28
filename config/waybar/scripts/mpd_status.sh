#!/bin/bash

SOCKET="/home/minovki/.config/mpd/socket"

# Verificar si el socket existe
if [[ ! -S "$SOCKET" ]]; then
    echo '{"text": "♪ MPD Offline", "class": "offline"}'
    exit 0
fi

# Estado de MPD desde socket
status=$(mpc --host "$SOCKET" status 2>&1)

# Manejar errores
if [[ "$status" == *"Connection refused"* ]] || [[ "$status" == *"Connection closed"* ]]; then
    echo '{"text": "♪ MPD Error", "class": "error"}'
    exit 0
fi

# Canción actual
current_song=$(mpc --host "$SOCKET" current | tr -d '"' | cut -c-40)
[[ -z "$current_song" ]] && current_song="No track"

# EXTRAER EL ESTADO DE REPRODUCCIÓN — ESTA ES LA PARTE ARREGLADA
player_status=$(echo "$status" | grep -o '\[.*\]' | tr -d '[]')

# Determinar clase e icono
case $player_status in
    playing)
        class="playing"
        icon=""
        ;;
    paused)
        class="paused"
        icon=""
        ;;
    *)
        class="stopped"
        icon=""
        ;;
esac

echo "{\"text\": \"$icon $current_song\", \"class\": \"$class\"}"

