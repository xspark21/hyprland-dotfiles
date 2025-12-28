# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim
export VISUAL=nvim

ENABLE_CORRECTION="true"

plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-history-substring-search
    z
    colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# Pronmpt configuration

function parse_git_branch {
	local branch
	branch=$(git symbolic-ref --short HEAD 2> /dev/null)
	if [ -n "$branch" ]; then
		echo " [$branch]"
	fi
}

PROMPT='%F{#6570A0}%n%f%F{#5E72CA}@%m%f %F{white}%~%f%${vcs_info_msg_0_} %F{white}$(parse_git_branch)%f %(?.%B%F{#7A7AF}$.%F{#5E6A75}$)%f%b '



# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim
export VISUAL=nvim


ENABLE_CORRECTION = true

plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh


function parse_git_branch {
	local branch
	branch=$(git symbolic-ref --short HEAD 2> /dev/null)
	if [ -n "$branch" ]; then
		echo " [$branch]"
	fi
}

PROMPT='%F{#6570A0}%n%f%F{#5E72CA}@%m%f %F{white}%~%f%1 %F{white}$(parse_git_branch)%f %(?.%B%F{#7A7AF}$.%F{#5E6A75}$)%f%b '

##########################################################
# script para poder conectarme a wifi mas facilmente ToT #
##########################################################

wifi_connect() {
    echo "=================================="
    echo "      WiFi Connector (iwctl)"
    echo "=================================="

    local iface
    iface=$(iwctl device list | awk 'NR==2 {print $1}')

    if [[ -z "$iface" ]]; then
        echo "[!] Interfaz wifi no detectada"
        return 1
    fi

    echo "[*] Escaneando redes..."
    iwctl station "$iface" scan >/dev/null
    sleep 1

    local networks
    networks=$(iwctl station "$iface" get-networks \
        | sed '1,4d' \
        | sed '/^$/d')

    if [[ -z "$networks" ]]; then
        echo "[!] Ninguna red encontrada"
        return 1
    fi

    echo
    echo "Redes disponibles:"
    echo "-------------------"
    echo "$networks" | nl -w2 -s'. '

    echo
    read -p "Elegir red [numero]: " selection

    local line
    line=$(echo "$networks" | sed -n "${selection}p")

    if [[ -z "$line" ]]; then
        echo "[!] Seleccion invalida!"
        return 1
    fi

    local ssid
    ssid=$(echo "$line" | sed 's/  .*//')

    echo
    echo "[+] Conectando a \"$ssid\"..."
    iwctl station "$iface" connect "$ssid"
}

#############
# soy flojo #
#############

alias py='python'

######################################################################
# script sencillo para compilar y correr archivos rs sin dependencias, 
# remplaza el uso de rustc archivo.rs && ./archivo
######################################################################

rust-run() {
    [[ -z "$1" ]] && {
        echo "Uso: rs <file.rs>"
        return 1
    }

    [[ "$1" == "--help" || "$1" == "-h" ]] && {
        rustc --help
        return 0
    }

    local bin
    bin=$(mktemp /tmp/rust.XXXXXX) || return 1

    rustc "$1" -o "$bin" || { rm -f "$bin"; return 1; }
    "$bin"
    local code=$?
    rm -f "$bin"
    return $code
}

alias rs='rust-run'

###########################
# crea plantilla para rsc #
###########################

rs-new() {
    local file="${1:-script.rs}"

    cat > "$file" << 'EOF'
// cargo-deps: 

fn main() {

}
EOF

    echo "Creado $file"
}

##########################################################################################
# corre archivos rs sin necesidad de tocar cargo.toml, para crate/dependencias sencillas #
##########################################################################################

rsc() {
    if [[ -z "$1" ]]; then
        echo "Uso: rsc <archivo.rs>"
        return 1
    fi

    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Error: archivo no encontrado"
        return 1
    fi

    # Directorio temporal
    local dir
    dir=$(mktemp -d)

    mkdir -p "$dir/src"

    # Crear Cargo.toml base
    cat > "$dir/Cargo.toml" << EOF
[package]
name = "temp_rust"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF

    # Extraer dependencias desde comentario cargo-deps
    local deps
    deps=$(grep -E '^//\s*cargo-deps:' "$file" \
        | sed 's|//\s*cargo-deps:\s*||')

    if [[ -n "$deps" ]]; then
        echo "$deps" | tr ',' '\n' >> "$dir/Cargo.toml"
    fi

    # Copiar archivo como main.rs
    cp "$file" "$dir/src/main.rs"

    # Compilar y ejecutar
    (
        cd "$dir" || exit 1
        cargo run --quiet
    )

    local status=$?
    rm -rf "$dir"
    return $status
}

#####################################
# automatizacion para uso de yt-dlp #
#####################################

# main
_ytdlp() {
    local output_dir="$1"
    shift

    mkdir -p "$output_dir"
    yt-dlp "$@" -o "$output_dir/%(title)s.%(ext)s"
}

# para albumes/playlist 
yt-album() {
    _ytdlp "$HOME/music/albums" \
        -x --audio-format opus \
        --embed-metadata --embed-thumbnail \
        --yes-playlist "$1"
}

# solo una cancion 
yt-song() {
    _ytdlp "$HOME/music" \
        -x --audio-format opus \
        --embed-metadata --embed-thumbnail "$1"
}

# audio en general (para edicion por ejemplo)
yt-audio() {
    _ytdlp "$HOME/sounds" -x --audio-format best "$1"
}

# descargar videos mejor calidad
mvk() {
    _ytdlp "$HOME/videos" \
        -f "bestvideo+bestaudio" \
        --merge-output-format mkv "$1"
}

# para no cometer el error de descargar un video 4k de 3 horas... (de nuevo)
mvk1080() {
    if [[ -z "$1" ]]; then
        echo "Uso: mvk1080 <URL>"
        return 1
    fi

    _ytdlp "$HOME/videos" \
        -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
        --merge-output-format mkv \
        "$1"
}

