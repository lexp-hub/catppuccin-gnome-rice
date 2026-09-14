# 🌸 GNOME Catppuccin Macchiato Rice & Dotfiles

Configurazione completa ed elegante per GNOME Shell basata sulla palette **Catppuccin Macchiato**, completa di temi GTK 3/4, estensioni GNOME, icone Kora, cursori Bibata, font Nerd, configurazione OpenBar e asset personalizzati.

---

## 📸 Componenti del Rice

| Componente | Nome / Dettagli |
| :--- | :--- |
| **GTK Theme** | `Catppuccin-B-MB-Dark-Macchiato` (GTK 3 & GTK 4 / Libadwaita) |
| **GNOME Shell Theme** | `Catppuccin-B-MB-Dark-Macchiato` (via User Theme) |
| **Icon Theme** | `kora` |
| **Cursor Theme** | `Bibata-Modern-Classic` |
| **Pannello Superiore** | `OpenBar` (preset custom `catppuccin.theme` con floating bar e gradienti) |
| **Dock** | `Dash to Dock` (curva e trasparenza ottimizzata) |
| **Menu Applicazioni** | `ArcMenu` (con icona Fedora personalizzata) |
| **Angoli Finestre** | `Rounded Window Corners Reborn` (raggio e bordi blu/viola Catppuccin) |
| **Effetti Sfocatura** | `Blur my Shell` |
| **Cursore Dinamico** | `Wiggly` (con sprite personalizzato `mouse.png`) |
| **Monitor Sistema** | `Vitals` |
| **Terminal & Prompt** | `Ghostty`, `Fastfetch`, `Starship` |
| **Font** | `Adwaita Mono`, `JetBrainsMono Nerd Font`, `CascadiaCode` |

---

## 🧩 Estensioni GNOME Shell Incluse

Tutte le estensioni necessarie sono incluse nella cartella `extensions/` e vengono attivate automaticamente dall'installer:

1. **User Theme** (`user-theme@gnome-shell-extensions.gcampax.github.com`)
2. **OpenBar** (`openbar@neuromorph`)
3. **ArcMenu** (`arcmenu@arcmenu.com`)
4. **Dash to Dock** (`dash-to-dock@micxgx.gmail.com`)
5. **Blur my Shell** (`blur-my-shell@aunetx`)
6. **Rounded Window Corners** (`rounded-window-corners@fxgn`)
7. **Just Perfection** (`just-perfection-desktop@just-perfection`)
8. **Color Picker** (`color-picker@tuberry`)
9. **Clipboard History** (`clipboard-history@alexsaveau.dev`)
10. **Caffeine** (`caffeine@patapon.info`)
11. **Desktop Icons NG (DING)** (`gtk4-ding@smedius.gitlab.com`)
12. **Vitals** (`Vitals@CoreCoding.com`)
13. **Wiggly** (`wiggly@mojarch`)

---

## 🚀 Installazione Rapida

### 1. Clona la repository
```bash
git clone https://github.com/lexp-hub/catppuccin-gnome-rice.git
cd catppuccin-gnome-rice
```

### 2. (Opzionale) Esegui un backup della configurazione attuale
```bash
./backup.sh
```

### 3. Esegui lo script di installazione
```bash
chmod +x install.sh
./install.sh
```

### 4. Riavvia la sessione
- Effettua il **Logout** e rientra nella sessione GNOME (oppure riavvia il computer).
- Su sessioni X11 puoi premere `Alt + F2`, digitare `r` e premere `Invio`.

---

## ⚙️ Importazione Tema OpenBar

Lo script copia automaticamente il file `catppuccin.theme` nella tua cartella `$HOME` e applica la configurazione dconf.

Se desideri re-importare o modificare il tema manualmente:
1. Apri le impostazioni di **OpenBar** (da *Estensioni* o *Extension Manager*).
2. Vai alla scheda **Import / Export**.
3. Clicca su **Import** e seleziona il file `~/catppuccin.theme` (o `openbar-catppuccin.theme` presente nella repo).
4. Clicca su **Reload Style** per confermare.

---

## 📁 Struttura della Repository

```text
├── assets/
│   └── mouse.png                     # Asset sprite per l'estensione Wiggly
├── config/
│   ├── fastfetch/                    # Configurazione Fastfetch e loghi
│   ├── ghostty/                      # Configurazione Ghostty terminal
│   ├── gtk-3.0/                      # Catppuccin GTK 3 theme CSS
│   ├── gtk-4.0/                      # Catppuccin GTK 4 / Libadwaita theme CSS
│   └── starship.toml                 # Prompt Starship personalizzato
├── dconf/
│   ├── catppuccin.theme              # File tema OpenBar
│   ├── dconf-clean.ini               # Dump dconf ottimizzato per GNOME
│   └── dconf-settings.ini            # Dump dconf completo
├── extensions/                       # Cartelle delle estensioni GNOME Shell
├── fonts/                            # Font TTF/OTF (Adwaita, Cascadia, JetBrains, ecc.)
├── icons/
│   ├── Bibata-Modern-Classic/        # Tema cursore Bibata
│   └── kora/                         # Tema icone Kora
├── themes/
│   └── Catppuccin-B-MB-Dark-Macchiato/ # Tema GTK e GNOME Shell
├── wallpapers/
│   └── catppuccin-wallpaper.jpg      # Sfondo desktop Catppuccin
├── install.sh                        # Script automatico di installazione
├── backup.sh                         # Script di backup dconf
└── openbar-catppuccin.theme          # File import OpenBar standalone
```

---

## 🛠️ Requisiti

- **OS**: Fedora / Arch Linux / Ubuntu / Debian o qualsiasi distribuzione con GNOME Desktop.
- **GNOME Shell**: 45, 46, 47, 48, 49, 50+.
- **Pacchetti consigliati**: `dconf`, `gnome-tweaks`, `unzip`, `fontconfig`.
