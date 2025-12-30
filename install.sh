#!/usr/bin/env bash
set -e

# ----------- style -----------
BLUE="\e[34m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1m"

info()   { echo -e "${BLUE}::${RESET} $1"; }
ok()     { echo -e "${GREEN}✔${RESET} $1"; }
warn()   { echo -e "${YELLOW}⚠${RESET} $1"; }
error()  { echo -e "${RED}✖${RESET} $1"; }
askmsg() { echo -e "${CYAN}?${RESET} $1"; }

# ----------- header -----------
cat <<'EOF'
                                                                                 /$$        /$$$$$$    /$$                                                                                      
                                                                                | $$       /$$__  $$ /$$$$                                                                                      
                               /$$   /$$  /$$$$$$$  /$$$$$$   /$$$$$$   /$$$$$$ | $$   /$$|__/  \ $$|_  $$                                                                                      
 /$$$$$$ /$$$$$$ /$$$$$$      |  $$ /$$/ /$$_____/ /$$__  $$ |____  $$ /$$__  $$| $$  /$$/  /$$$$$$/  | $$         /$$$$$$ /$$$$$$ /$$$$$$                                                      
|______/|______/|______/       \  $$$$/ |  $$$$$$ | $$  \ $$  /$$$$$$$| $$  \__/| $$$$$$/  /$$____/   | $$        |______/|______/|______/                                                      
                                >$$  $$  \____  $$| $$  | $$ /$$__  $$| $$      | $$_  $$ | $$        | $$                                                                                      
                               /$$/\  $$ /$$$$$$$/| $$$$$$$/|  $$$$$$$| $$      | $$ \  $$| $$$$$$$$ /$$$$$$                                                                                    
                              |__/  \__/|_______/ | $$____/  \_______/|__/      |__/  \__/|________/|______/                                                                                    
                                                  | $$                                                                                                                                          
                                                  | $$                                                                                                                                          
                                                  |__/                                                                                                                                          
 /$$       /$$ /$$         /$$     /$$       /$$                 /$$                   /$$     /$$                       /$$                       /$$               /$$ /$$                    
| $$      |__/| $$        | $$    | $$      |__/                |__/                  | $$    | $$                      |__/                      | $$              | $$| $$                    
| $$$$$$$  /$$| $$       /$$$$$$  | $$$$$$$  /$$  /$$$$$$$       /$$  /$$$$$$$       /$$$$$$  | $$$$$$$   /$$$$$$        /$$ /$$$$$$$   /$$$$$$$ /$$$$$$    /$$$$$$ | $$| $$  /$$$$$$   /$$$$$$ 
| $$__  $$| $$| $$      |_  $$_/  | $$__  $$| $$ /$$_____/      | $$ /$$_____/      |_  $$_/  | $$__  $$ /$$__  $$      | $$| $$__  $$ /$$_____/|_  $$_/   |____  $$| $$| $$ /$$__  $$ /$$__  $$
| $$  \ $$| $$|__/        | $$    | $$  \ $$| $$|  $$$$$$       | $$|  $$$$$$         | $$    | $$  \ $$| $$$$$$$$      | $$| $$  \ $$|  $$$$$$   | $$      /$$$$$$$| $$| $$| $$$$$$$$| $$  \__/
| $$  | $$| $$            | $$ /$$| $$  | $$| $$ \____  $$      | $$ \____  $$        | $$ /$$| $$  | $$| $$_____/      | $$| $$  | $$ \____  $$  | $$ /$$ /$$__  $$| $$| $$| $$_____/| $$      
| $$  | $$| $$ /$$        |  $$$$/| $$  | $$| $$ /$$$$$$$/      | $$ /$$$$$$$/        |  $$$$/| $$  | $$|  $$$$$$$      | $$| $$  | $$ /$$$$$$$/  |  $$$$/|  $$$$$$$| $$| $$|  $$$$$$$| $$      
|__/  |__/|__/|__/         \___/  |__/  |__/|__/|_______/       |__/|_______/          \___/  |__/  |__/ \_______/      |__/|__/  |__/|_______/    \___/   \_______/|__/|__/ \_______/|__/      
                                                                                                                                                                                                
                                                                                                                                                                                                
                                                                                                                                                                                                
EOF

# ----------- helpers -----------
ask() {
  askmsg "$1 [y/N]"
  read -r ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

require_arch() {
  if [[ ! -f /etc/arch-release ]]; then
    error "Esto es solo para Arch Linux."
    exit 1
  fi
}

# ----------- checks -----------
require_arch

DOTDIR="$(pwd)"
CONFIG_SRC="$DOTDIR/config"
CONFIG_DST="$HOME/.config"
ASSETS_SRC="$DOTDIR/assets"
WALLPAPER_DST="$HOME/images/wallpapers"
THEMES_DST="$HOME/.themes"

# ----------- packages ----------
if ask "¿Instalar paquetes necesarios?"; then
  info "Actualizando sistema e instalando paquetes..."

  if ! sudo pacman -Syu --needed --noconfirm $(< packages.txt); then
    warn "pacman terminó con advertencias, continuando instalación..."
  else
    ok "Paquetes instalados"
  fi
fi

# ----------- AUR ----------
if command -v yay &>/dev/null; then
  if [[ -f aur-packages.txt ]]; then
    info "Instalando paquetes AUR..."
    yay -S --needed --noconfirm $(< aur-packages.txt)
    ok "Paquetes AUR instalados"
  fi
else
  warn "yay no está instalado, saltando AUR"
fi

# ----------- configs ----------
info "Copiando configuraciones a ~/.config"
mkdir -p "$CONFIG_DST"

for dir in "$CONFIG_SRC"/*; do
  name="$(basename "$dir")"
  echo -e "  ${GREEN}→${RESET} $name"
  
  mkdir -p "$CONFIG_DST/$name"
  rsync -a "$dir/" "$CONFIG_DST/$name/"

done
ok "Configuraciones copiadas"

# ----------- Wallpapers ----------
if ask "¿Instalar wallpapers?"; then
  info "Instalando wallpapers..."
  mkdir -p "$WALLPAPER_DST"
  cp -r "$ASSETS_SRC/wallpapers/"* "$WALLPAPER_DST/"
  ok "Wallpapers instalados"
fi

# ----------- GTK Themes ----------
if ask "¿Instalar temas GTK?"; then
  info "Instalando temas GTK..."
  mkdir -p "$THEMES_DST"
  cp -r "$ASSETS_SRC/gtk/"* "$THEMES_DST/"
  ok "Temas GTK instalados"
fi

# ----------- ZSH / OH-MY-ZSH ----------
if ask "¿Instalar y configurar Zsh + Oh My Zsh?"; then
  info "Configurando Zsh + Oh My Zsh"

  if ! command -v zsh &>/dev/null; then
    sudo pacman -S --needed --noconfirm zsh
  fi

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  PLUGINS_FILE="$DOTDIR/zsh/plugins.txt"

  if [[ -f "$PLUGINS_FILE" ]]; then
    info "Instalando plugins de Zsh..."
    while read -r plugin; do
      [[ -z "$plugin" ]] && continue

      case "$plugin" in
        git|z|colored-man-pages)
          echo -e "  ${GREEN}→${RESET} $plugin (builtin)"
          ;;
        *)
          if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
            echo -e "  ${GREEN}→${RESET} $plugin"
            git clone --depth=1 \
              "https://github.com/zsh-users/$plugin" \
              "$ZSH_CUSTOM/plugins/$plugin"
          fi
          ;;
      esac
    done < "$PLUGINS_FILE"
  fi

  cp "$DOTDIR/zsh/.zshrc" "$HOME/.zshrc"

  if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s "$(which zsh)"
  fi

  ok "Zsh configurado"
fi

# ----------- MPD ----------
if ask "¿Configurar MPD como servicio de usuario?"; then
  info "Configurando MPD"
  mkdir -p "$HOME/.config/mpd"
  mkdir -p "$HOME/.local/share/mpd"
  mkdir -p "$HOME/.cache/mpd"
  systemctl --user enable mpd.service
  systemctl --user restart mpd.service
  ok "MPD habilitado y reiniciado"
fi

# ----------- Neovim ----------
if ask "¿Configurar Neovim (Lazy.nvim)?"; then
  info "Configurando Neovim"

  mkdir -p "$HOME/.config/nvim"
  cp -r "$CONFIG_SRC/nvim/"* "$HOME/.config/nvim/"

  info "Inicializando plugins (Lazy.nvim)..."
  nvim --headless "+Lazy! sync" +qa || \
    warn "Lazy falló, se instalará al abrir nvim"

  ok "Neovim configurado"
fi

# ----------- cleanup ----------
if ask "¿Eliminar el repositorio luego de instalar?"; then
  warn "Eliminando repositorio local"
  cd ..
  rm -rf "$DOTDIR"
fi

cat <<'EOF'
   /$$     /$$                        /$$$$$$                                                              /$$   /$$                                            
  | $$    | $$                       /$$__  $$                                                            |__/  | $$                                            
 /$$$$$$  | $$$$$$$  /$$   /$$      | $$  \__//$$$$$$   /$$$$$$        /$$   /$$  /$$$$$$$  /$$$$$$        /$$ /$$$$$$                                          
|_  $$_/  | $$__  $$|  $$ /$$/      | $$$$   /$$__  $$ /$$__  $$      | $$  | $$ /$$_____/ /$$__  $$      | $$|_  $$_/                                          
  | $$    | $$  \ $$ \  $$$$/       | $$_/  | $$  \ $$| $$  \__/      | $$  | $$|  $$$$$$ | $$$$$$$$      | $$  | $$                                            
  | $$ /$$| $$  | $$  >$$  $$       | $$    | $$  | $$| $$            | $$  | $$ \____  $$| $$_____/      | $$  | $$ /$$                                        
  |  $$$$/| $$  | $$ /$$/\  $$      | $$    |  $$$$$$/| $$            |  $$$$$$/ /$$$$$$$/|  $$$$$$$      | $$  |  $$$$//$$                                     
   \___/  |__/  |__/|__/  \__/      |__/     \______/ |__/             \______/ |_______/  \_______/      |__/   \___/ | $/                                     
                                                                                                                       |_/                                      
                                                                                                                                                                
                                                                                                                                                                
 /$$$$$$       /$$                                                                                                                                 /$$   /$$    
|_  $$_/      | $$                                                                                                                                |__/  | $$    
  | $$        | $$$$$$$   /$$$$$$   /$$$$$$   /$$$$$$        /$$   /$$  /$$$$$$  /$$   /$$        /$$$$$$  /$$$$$$$  /$$  /$$$$$$  /$$   /$$       /$$ /$$$$$$  
  | $$        | $$__  $$ /$$__  $$ /$$__  $$ /$$__  $$      | $$  | $$ /$$__  $$| $$  | $$       /$$__  $$| $$__  $$|__/ /$$__  $$| $$  | $$      | $$|_  $$_/  
  | $$        | $$  \ $$| $$  \ $$| $$  \ $$| $$$$$$$$      | $$  | $$| $$  \ $$| $$  | $$      | $$$$$$$$| $$  \ $$ /$$| $$  \ $$| $$  | $$      | $$  | $$    
  | $$        | $$  | $$| $$  | $$| $$  | $$| $$_____/      | $$  | $$| $$  | $$| $$  | $$      | $$_____/| $$  | $$| $$| $$  | $$| $$  | $$      | $$  | $$ /$$
 /$$$$$$      | $$  | $$|  $$$$$$/| $$$$$$$/|  $$$$$$$      |  $$$$$$$|  $$$$$$/|  $$$$$$/      |  $$$$$$$| $$  | $$| $$|  $$$$$$/|  $$$$$$$      | $$  |  $$$$/
|______/      |__/  |__/ \______/ | $$____/  \_______/       \____  $$ \______/  \______/        \_______/|__/  |__/| $$ \______/  \____  $$      |__/   \___/  
                                  | $$                       /$$  | $$                                         /$$  | $$           /$$  | $$                    
                                  | $$                      |  $$$$$$/                                        |  $$$$$$/          |  $$$$$$/                    
                                  |__/                       \______/                                          \______/            \______/
EOF

echo
ok "Instalación terminada"
warn "Reinicia sesión o el sistema para aplicar todo"

