#!/usr/bin/env bash
set -e

echo "== Hyprland Dotfiles Installer =="

# ----------- helpers -----------
ask() {
  read -rp "$1 [y/N]: " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

require_arch() {
  if [[ ! -f /etc/arch-release ]]; then
    echo "Esto es solo para Arch Linux."
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
  echo "Actualizando sistema e instalando paquetes..."

  if ! sudo pacman -Syu --needed --noconfirm $(< packages.txt); then
    echo "⚠ pacman terminó con advertencias, continuando instalación..."
  fi
fi

# ----------- AUR ----------
if command -v yay &>/dev/null; then
  if [[ -f aur-packages.txt ]]; then
    echo "Instalando paquetes AUR..."
    yay -S --needed --noconfirm $(< aur-packages.txt)
  fi
else
  echo "⚠ yay no está instalado, saltando AUR"
fi

# ----------- configs ----------
echo "Copiando configuraciones a ~/.config"
mkdir -p "$CONFIG_DST"

for dir in "$CONFIG_SRC"/*; do
  name="$(basename "$dir")"
  echo " - $name"
  rm -rf "$CONFIG_DST/$name"
  cp -r "$dir" "$CONFIG_DST/"
done

# ----------- Wallpapers ----------
if ask "¿Instalar wallpapers?"; then
  echo "Instalando wallpapers..."
  mkdir -p "$WALLPAPER_DST"
  cp -r "$ASSETS_SRC/wallpapers/"* "$WALLPAPER_DST/"
fi

# ----------- GTK Themes ----------
if ask "¿Instalar temas GTK?"; then
  echo "Instalando temas GTK..."
  mkdir -p "$THEMES_DST"
  cp -r "$ASSETS_SRC/gtk/"* "$THEMES_DST/"
fi

# ----------- ZSH / OH-MY-ZSH ----------
if ask "¿Instalar y configurar Zsh + Oh My Zsh?"; then

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
    echo "Instalando plugins de Zsh..."
    while read -r plugin; do
      [[ -z "$plugin" ]] && continue

      case "$plugin" in
        git|z|colored-man-pages)
          echo " - $plugin (builtin)"
          ;;
        *)
          if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
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
fi

# ----------- MPD ----------
if ask "¿Configurar MPD como servicio de usuario?"; then
  systemctl --user enable mpd.service
  systemctl --user restart mpd.service
fi

# ----------- Neovim ----------
if ask "¿Configurar Neovim (Lazy.nvim)?"; then
  echo "Configurando Neovim..."

  mkdir -p "$HOME/.config/nvim"
  cp -r "$CONFIG_SRC/nvim/"* "$HOME/.config/nvim/"

  echo "Inicializando Neovim (Lazy)..."
  nvim --headless "+Lazy! sync" +qa || \
    echo "⚠ Lazy falló, se instalará al abrir nvim"
fi

# ----------- cleanup ----------
if ask "¿Eliminar el repositorio luego de instalar?"; then
  cd ..
  rm -rf "$DOTDIR"
fi

echo
echo "✔ Instalación terminada"
echo "⚠ Reinicia sesión o el sistema para aplicar todo"

