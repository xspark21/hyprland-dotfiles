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
  echo "Wallpapers copiados a $WALLPAPER_DST"
fi

# ----------- GTK Themes ----------
if ask "¿Instalar temas GTK?"; then
  echo "Instalando temas GTK..."
  mkdir -p "$THEMES_DST"
  cp -r "$ASSETS_SRC/gtk/"* "$THEMES_DST/"
  echo "Temas instalados en ~/.themes"
fi
# ----------- ZSH / OH-MY-ZSH ----------
if ask "¿Instalar y configurar Zsh + Oh My Zsh?"; then

  # instalar zsh si no existe
  if ! command -v zsh &>/dev/null; then
    echo "Instalando zsh..."
    sudo pacman -S --needed --noconfirm zsh
  fi

  # instalar oh-my-zsh
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Instalando Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  PLUGINS_FILE="$DOTDIR/zsh/plugins.txt"

  # instalar plugins desde plugins.txt
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
            echo " - Instalando $plugin"
            git clone --depth=1 \
              "https://github.com/zsh-users/$plugin" \
              "$ZSH_CUSTOM/plugins/$plugin"
          else
            echo " - $plugin ya instalado"
          fi
          ;;
      esac
    done < "$PLUGINS_FILE"
  fi

  echo "Copiando .zshrc"
  cp "$DOTDIR/zsh/.zshrc" "$HOME/.zshrc"

  # cambiar shell por defecto
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Cambiando shell por defecto a zsh"
    chsh -s "$(which zsh)"
  fi
fi


# ----------- MPD (USER) ----------
if ask "¿Configurar MPD como servicio de usuario?"; then
  systemctl --user enable mpd.service
  systemctl --user restart mpd.service
  echo "MPD ahora corre SOLO para el usuario"
fi

# ----------- Neovim -------------
if ask "¿Configurar Neovim (vim-plug + plugins)?"; then
  echo "Configurando Neovim..."

  # deps mínimas para coc.nvim
  if ! command -v node &>/dev/null; then
    echo "Instalando nodejs y npm (requerido por coc.nvim)"
    sudo pacman -S --needed --noconfirm nodejs npm
  fi

  mkdir -p "$HOME/.config/nvim"
  cp -r "$CONFIG_SRC/nvim/"* "$HOME/.config/nvim/"

  # instalar vim-plug si no existe
  if [[ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]]; then
    echo "Instalando vim-plug..."
    curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  echo "Instalando plugins de Neovim..."
  nvim --headless +'PlugInstall --sync' +qa

  echo "Inicializando Neovim (primer arranque)..."
  nvim --headless +qa

  echo "Instalando plugins de Neovim (headless)..."

  echo "Neovim listo."
fi

# ----------- cleanup ------------
if ask "¿Eliminar el repositorio luego de instalar?"; then
  cd ..
  rm -rf "$DOTDIR"
  echo "Repo eliminado"
fi

echo
echo "✔ Instalación terminada"
echo "⚠ Reinicia sesión o el sistema para aplicar todo"

