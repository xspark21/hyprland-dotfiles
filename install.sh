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
echo
echo -e "${BOLD}${CYAN}hyprland-dotfiles${RESET}  ·  instalador"
echo -e "${BLUE}────────────────────────────${RESET}"
echo

# ----------- helpers -----------
ask() {
  askmsg "$1 [y/N]"
  read -r ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

pkglist() { grep -vE '^[[:space:]]*(#|$)' "$1"; }

require_arch() {
  if [[ ! -f /etc/arch-release ]]; then
    error "Esto es solo para Arch Linux."
    exit 1
  fi
}

# ----------- checks -----------
require_arch

DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTDIR/config"
CONFIG_DST="$HOME/.config"
ASSETS_SRC="$DOTDIR/assets"
WALLPAPER_DST="$HOME/images/wallpapers"
THEMES_DST="$HOME/.themes"

# ----------- packages ----------
if ask "¿Instalar paquetes necesarios?"; then
  info "Actualizando sistema e instalando paquetes..."

  if ! sudo pacman -Syu --needed --noconfirm $(pkglist "$DOTDIR/packages.txt"); then
    warn "pacman terminó con advertencias, continuando instalación..."
  else
    ok "Paquetes instalados"
  fi
fi

# ----------- AUR ----------
if ask "¿Instalar paquetes AUR?"; then
  if command -v yay &>/dev/null; then
    if [[ -f "$DOTDIR/aur-packages.txt" ]]; then
      info "Instalando paquetes AUR..."
      yay -S --needed --noconfirm $(pkglist "$DOTDIR/aur-packages.txt") \
        || warn "yay terminó con errores, continuando..."
      ok "Paquetes AUR instalados"
    fi
  else
    warn "yay no está instalado, saltando AUR"
  fi
fi

# ----------- configs ----------
if ask "¿Copiar las configuraciones a ~/.config?"; then
  info "Copiando configuraciones a ~/.config"
  mkdir -p "$CONFIG_DST"

  for dir in "$CONFIG_SRC"/*; do
    name="$(basename "$dir")"
    echo -e "  ${GREEN}→${RESET} $name"

    mkdir -p "$CONFIG_DST/$name"
    if command -v rsync &>/dev/null; then
      rsync -a "$dir/" "$CONFIG_DST/$name/"
    else
      cp -a "$dir/." "$CONFIG_DST/$name/"
    fi
  done
  ok "Configuraciones copiadas"
fi

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
  ok "Temas GTK instalados (se aplican vía GTK_THEME en hyprland.lua)"
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
              "$ZSH_CUSTOM/plugins/$plugin" \
              || warn "no se pudo clonar $plugin"
          fi
          ;;
      esac
    done < "$PLUGINS_FILE"
  fi

  cp "$DOTDIR/zsh/.zshrc" "$HOME/.zshrc"

  if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s "$(which zsh)" || warn "no se pudo cambiar el shell por defecto"
  fi

  ok "Zsh configurado"
fi

# ----------- MPD ----------
if ask "¿Configurar MPD como servicio de usuario?"; then
  if ! command -v mpd &>/dev/null; then
    warn "mpd no está instalado, saltando"
  else
    info "Configurando MPD"
    mkdir -p "$HOME/.config/mpd"
    mkdir -p "$HOME/.local/share/mpd"
    mkdir -p "$HOME/.cache/mpd"
    systemctl --user enable mpd.service  || warn "no se pudo habilitar mpd"
    systemctl --user restart mpd.service || warn "no se pudo reiniciar mpd"
    ok "MPD habilitado y reiniciado"
  fi
fi

# ----------- Neovim ----------
if ask "¿Configurar Neovim (Lazy.nvim)?"; then
  info "Configurando Neovim"

  mkdir -p "$HOME/.config/nvim"
  cp -r "$CONFIG_SRC/nvim/"* "$HOME/.config/nvim/"

  info "Inicializando plugins (Lazy.nvim)..."
  nvim --headless "+Lazy! sync" +qa \
    || warn "Lazy falló, se instalará al abrir nvim"

  ok "Neovim configurado"
fi

# ----------- cleanup ----------
if ask "¿Eliminar el repositorio luego de instalar?"; then
  warn "Eliminando repositorio local"
  cd ..
  rm -rf "$DOTDIR"
fi

echo
ok "Instalación terminada"
warn "Reinicia sesión o el sistema para aplicar todo"
