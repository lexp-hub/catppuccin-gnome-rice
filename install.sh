#!/usr/bin/env bash
# ==============================================================================
# Catppuccin GNOME Rice Installer
# Automated installer for Catppuccin GNOME desktop setup, themes, extensions,
# icons, fonts, wallpapers, and OpenBar theme.
# ==============================================================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CURRENT_USER="$(whoami)"
USER_HOME="$HOME"

COLOR_RESET="\033[0m"
COLOR_CYAN="\033[1;36m"
COLOR_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_BLUE="\033[1;34m"
COLOR_RED="\033[1;31m"

print_header() {
    echo -e "\n${COLOR_CYAN}======================================================${COLOR_RESET}"
    echo -e "${COLOR_CYAN}  🎨  Catppuccin GNOME Rice Installer  🎨${COLOR_RESET}"
    echo -e "${COLOR_CYAN}======================================================${COLOR_RESET}\n"
}

log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $1"
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $1"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1"
}

print_header

# ------------------------------------------------------------------------------
# 1. Package Manager & Dependencies
# ------------------------------------------------------------------------------
log_info "Controllo delle dipendenze di sistema..."

install_pkg() {
    if command -v dnf &>/dev/null; then
        sudo dnf install -y "$@" || true
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm --needed "$@" || true
    elif command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y "$@" || true
    fi
}

# Check if dconf, gnome-shell, fontconfig are available
MISSING_PKGS=()
for cmd in dconf gsettings fc-cache; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING_PKGS+=("$cmd")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    log_warning "Mancano i seguenti comandi: ${MISSING_PKGS[*]}"
    log_info "Tentativo di installazione dei pacchetti richiesti..."
    if command -v dnf &>/dev/null; then
        install_pkg dconf fontconfig gnome-tweaks unzip
    elif command -v pacman &>/dev/null; then
        install_pkg dconf fontconfig gnome-tweaks unzip
    elif command -v apt &>/dev/null; then
        install_pkg dconf-cli fontconfig gnome-tweaks unzip
    fi
fi

# ------------------------------------------------------------------------------
# 2. Directory Creation
# ------------------------------------------------------------------------------
log_info "Creazione delle cartelle di configurazione..."
mkdir -p "$USER_HOME/.themes"
mkdir -p "$USER_HOME/.local/share/themes"
mkdir -p "$USER_HOME/.icons"
mkdir -p "$USER_HOME/.local/share/icons"
mkdir -p "$USER_HOME/.local/share/fonts"
mkdir -p "$USER_HOME/.local/share/gnome-shell/extensions"
mkdir -p "$USER_HOME/.config"
mkdir -p "$USER_HOME/Documents"

# ------------------------------------------------------------------------------
# 3. Wallpaper & Assets Setup
# ------------------------------------------------------------------------------
log_info "Copia dello sfondo del desktop..."
if [ -f "$REPO_DIR/wallpapers/catppuccin-wallpaper.jpg" ]; then
    cp "$REPO_DIR/wallpapers/catppuccin-wallpaper.jpg" "$USER_HOME/.config/background"
    log_success "Sfondo copiato in ~/.config/background"
fi

if [ -f "$REPO_DIR/assets/mouse.png" ]; then
    cp "$REPO_DIR/assets/mouse.png" "$USER_HOME/Documents/mouse.png"
    log_success "Asset cursore Wiggly copiato in ~/Documents/mouse.png"
fi

# ------------------------------------------------------------------------------
# 4. Themes Installation (GTK / Shell)
# ------------------------------------------------------------------------------
log_info "Installazione dei temi GTK e GNOME Shell..."
if [ -d "$REPO_DIR/themes" ]; then
    cp -r "$REPO_DIR"/themes/* "$USER_HOME/.themes/" 2>/dev/null || true
    cp -r "$REPO_DIR"/themes/* "$USER_HOME/.local/share/themes/" 2>/dev/null || true
    log_success "Temi Catppuccin installati con successo."
fi

# ------------------------------------------------------------------------------
# 5. Icons and Cursors Installation
# ------------------------------------------------------------------------------
log_info "Installazione delle icone e dei cursori (Kora & Bibata)..."
if [ -d "$REPO_DIR/icons" ]; then
    cp -r "$REPO_DIR"/icons/* "$USER_HOME/.local/share/icons/" 2>/dev/null || true
    cp -r "$REPO_DIR"/icons/* "$USER_HOME/.icons/" 2>/dev/null || true
    log_success "Icone e cursori installati."
fi

# ------------------------------------------------------------------------------
# 6. Fonts Installation
# ------------------------------------------------------------------------------
log_info "Installazione dei font..."
if [ -d "$REPO_DIR/fonts" ]; then
    cp -r "$REPO_DIR"/fonts/* "$USER_HOME/.local/share/fonts/" 2>/dev/null || true
    if command -v fc-cache &>/dev/null; then
        fc-cache -f "$USER_HOME/.local/share/fonts" &>/dev/null || true
    fi
    log_success "Font installati e cache aggiornata."
fi

# ------------------------------------------------------------------------------
# 7. GNOME Shell Extensions Installation
# ------------------------------------------------------------------------------
log_info "Installazione delle estensioni GNOME Shell..."
if [ -d "$REPO_DIR/extensions" ]; then
    cp -r "$REPO_DIR"/extensions/* "$USER_HOME/.local/share/gnome-shell/extensions/" 2>/dev/null || true
    log_success "Estensioni copiate in ~/.local/share/gnome-shell/extensions/"
fi

# Disable extension version validation to guarantee compatibility
log_info "Disabilitazione del controllo di compatibilità delle estensioni..."
gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || true

# ------------------------------------------------------------------------------
# 8. GTK & App Configurations (GTK 3/4, Ghostty, Fastfetch, Starship)
# ------------------------------------------------------------------------------
log_info "Copia delle configurazioni GTK, Fastfetch, Ghostty..."
if [ -d "$REPO_DIR/config" ]; then
    cp -r "$REPO_DIR"/config/* "$USER_HOME/.config/" 2>/dev/null || true
    log_success "Configurazioni copiate in ~/.config/"
fi

# ------------------------------------------------------------------------------
# 9. OpenBar Theme file
# ------------------------------------------------------------------------------
log_info "Preparazione del file tema OpenBar (catppuccin.theme)..."
if [ -f "$REPO_DIR/openbar-catppuccin.theme" ]; then
    sed "s|/home/lex|$USER_HOME|g" "$REPO_DIR/openbar-catppuccin.theme" > "$USER_HOME/catppuccin.theme"
    log_success "File tema OpenBar copiato in ~/catppuccin.theme"
fi

# ------------------------------------------------------------------------------
# 10. Dconf Settings Restoration
# ------------------------------------------------------------------------------
log_info "Applicazione delle impostazioni dconf di GNOME..."
DCONF_FILE="$REPO_DIR/dconf/dconf-clean.ini"
if [ ! -f "$DCONF_FILE" ]; then
    DCONF_FILE="$REPO_DIR/dconf/dconf-settings.ini"
fi

if [ -f "$DCONF_FILE" ]; then
    # Dynamically substitute /home/lex with actual $USER_HOME
    TMP_DCONF="$(mktemp)"
    sed "s|/home/lex|$USER_HOME|g" "$DCONF_FILE" > "$TMP_DCONF"
    dconf load /org/gnome/ < "$TMP_DCONF" 2>/dev/null || dconf load / < "$TMP_DCONF" 2>/dev/null || true
    rm -f "$TMP_DCONF"
    log_success "Impostazioni dconf caricate con successo."
fi

# Explicit interface settings for reliability
log_info "Applicazione esplicita dei parametri d'interfaccia..."
gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-B-MB-Dark-Macchiato' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'kora' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface accent-color 'yellow' 2>/dev/null || true
gsettings set org.gnome.desktop.background picture-uri "file://$USER_HOME/.config/background" 2>/dev/null || true
gsettings set org.gnome.desktop.background picture-uri-dark "file://$USER_HOME/.config/background" 2>/dev/null || true
dconf write /org/gnome/shell/extensions/user-theme/name "'Catppuccin-B-MB-Dark-Macchiato'" 2>/dev/null || true

# ------------------------------------------------------------------------------
# 11. Enable Extensions
# ------------------------------------------------------------------------------
log_info "Abilitazione delle estensioni GNOME..."
EXTENSIONS=(
    "user-theme@gnome-shell-extensions.gcampax.github.com"
    "openbar@neuromorph"
    "arcmenu@arcmenu.com"
    "dash-to-dock@micxgx.gmail.com"
    "blur-my-shell@aunetx"
    "rounded-window-corners@fxgn"
    "just-perfection-desktop@just-perfection"
    "color-picker@tuberry"
    "clipboard-history@alexsaveau.dev"
    "caffeine@patapon.info"
    "gtk4-ding@smedius.gitlab.com"
    "Vitals@CoreCoding.com"
    "wiggly@mojarch"
)

for ext in "${EXTENSIONS[@]}"; do
    if command -v gnome-extensions &>/dev/null; then
        gnome-extensions enable "$ext" 2>/dev/null || true
    fi
done

echo -e "\n${COLOR_GREEN}======================================================${COLOR_RESET}"
echo -e "${COLOR_GREEN}  ✨  Installazione completata con successo!  ✨${COLOR_RESET}"
echo -e "${COLOR_GREEN}======================================================${COLOR_RESET}\n"
echo -e "${COLOR_CYAN}Per rendere attive tutte le modifiche:${COLOR_RESET}"
echo -e "  1. Effettua il ${COLOR_YELLOW}Logout${COLOR_RESET} e rientra nella sessione GNOME (oppure riavvia il sistema)."
echo -e "  2. Su X11 puoi premere ${COLOR_YELLOW}Alt + F2${COLOR_RESET}, digitare ${COLOR_YELLOW}r${COLOR_RESET} e premere ${COLOR_YELLOW}Invio${COLOR_RESET}."
echo -e "  3. Il file di import per OpenBar si trova in ${COLOR_YELLOW}~/catppuccin.theme${COLOR_RESET}.\n"
