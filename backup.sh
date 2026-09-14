#!/usr/bin/env bash
# ==============================================================================
# Catppuccin GNOME Rice - Backup Script
# Creates a backup of your existing dconf settings and GTK configurations.
# ==============================================================================

set -e

BACKUP_DIR="$HOME/gnome-rice-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating GNOME rice backup in $BACKUP_DIR..."

# Backup dconf
if command -v dconf &>/dev/null; then
    dconf dump /org/gnome/ > "$BACKUP_DIR/gnome_dconf_backup.ini"
    echo "✔ Dconf settings backed up to $BACKUP_DIR/gnome_dconf_backup.ini"
fi

# Backup gtk configs
if [ -d "$HOME/.config/gtk-3.0" ]; then
    cp -r "$HOME/.config/gtk-3.0" "$BACKUP_DIR/gtk-3.0"
fi
if [ -d "$HOME/.config/gtk-4.0" ]; then
    cp -r "$HOME/.config/gtk-4.0" "$BACKUP_DIR/gtk-4.0"
fi

echo "✔ Backup completed successfully in $BACKUP_DIR"
