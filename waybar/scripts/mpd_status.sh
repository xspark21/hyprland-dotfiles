#!/bin/bash

# Verificar si MPD está activo
if ! pgrep mpd >/dev/null; then
    echo '{"text": "♪ MPD Offline", "class": "offline"}'
    exit 0
fi

# Obtener estado de MPD
status=$(mpc status 2>&1)

# Manejar errores de conexión
if [[ "$status" == *"Connection refused"* ]]; then
    echo '{"text": "♪ MPD Error", "class": "error"}'
    exit 0
fi

# Extraer información
current_song=$(mpc current | tr -d '"' | cut -c-40)
player_status=$(mpc status | awk 'NR==2 {print $1}' | tr -d '[]')

# Determinar clase e icono
case $player_status in
    "playing") 
        class="playing"
        icon="" ;;
    "paused") 
        class="paused"
        icon="" ;;
    *) 
        class="stopped"
        icon="" ;;
esac

# Generar JSON válido
echo "{\"text\": \"$icon $current_song\", \"class\": \"$class\"}"