#!/usr/bin/env bash
# ==============================================================================
# Canon PIXMA G3010 Series Automated Linux Setup & Maintenance Suite Installer
# Author: 9M2PJU
# Repository: https://github.com/9M2PJU/9M2PJU-Canon-PIXMA-G3010-Linux-Tool
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}   Canon PIXMA G3010 Linux Tool & Driver Setup by 9M2PJU          ${NC}"
echo -e "${BLUE}==================================================================${NC}"

# Check root / sudo
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# 1. Package Installation
echo -e "\n${GREEN}[1/5] Checking and installing dependencies...${NC}"
if [ -f /etc/arch-release ] || [ -f /etc/cachyos-release ]; then
    echo "    Detected Arch / CachyOS Linux."
    $SUDO pacman -S --noconfirm --needed cups cups-filters gutenprint foomatic-db-gutenprint-ppds avahi nss-mdns python python-gobject gtk3 || true
    
    if ! pacman -Qi cnijfilter2-g3010 >/dev/null 2>&1; then
        echo "    Installing official cnijfilter2-g3010 driver via AUR..."
        if command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm cnijfilter2-g3010
        elif command -v paru >/dev/null 2>&1; then
            paru -S --noconfirm cnijfilter2-g3010
        else
            echo -e "${YELLOW}    Note: AUR helper (yay/paru) not found. Proceeding with Gutenprint/IPP drivers.${NC}"
        fi
    fi
elif [ -f /etc/debian_version ]; then
    echo "    Detected Debian / Ubuntu Linux."
    $SUDO apt-get update
    $SUDO apt-get install -y cups cups-filters printer-driver-gutenprint avahi-daemon python3 python3-gi gir1.2-gtk-3.0
fi

# 2. Compatibility Library Fix
echo -e "\n${GREEN}[2/5] Setting up compatibility libraries...${NC}"
if [ -f /usr/lib/libxml2.so.16 ] && [ ! -f /usr/lib/libxml2.so.2 ]; then
    echo "    Creating libxml2.so.2 -> libxml2.so.16 compatibility symlink..."
    $SUDO ln -sf /usr/lib/libxml2.so.16 /usr/lib/libxml2.so.2
fi

# 3. Install Maintenance Suite & Command Files
echo -e "\n${GREEN}[3/5] Installing maintenance suite and desktop integration...${NC}"
$SUDO mkdir -p /usr/share/cmdtocanonij2 /usr/local/bin /usr/local/share/applications
$SUDO cp -r "$SCRIPT_DIR/data/cmdtocanonij2/"*.utl /usr/share/cmdtocanonij2/
$SUDO cp "$SCRIPT_DIR/bin/canon-g3010-maintenance" /usr/local/bin/canon-g3010-maintenance
$SUDO chmod +x /usr/local/bin/canon-g3010-maintenance
$SUDO cp "$SCRIPT_DIR/desktop/canon-g3010-maintenance.desktop" /usr/local/share/applications/
$SUDO chmod 644 /usr/local/share/applications/canon-g3010-maintenance.desktop

# Also link into user ~/.local/bin if available
if [ -d "$HOME/.local/bin" ]; then
    ln -sf /usr/local/bin/canon-g3010-maintenance "$HOME/.local/bin/canon-g3010-maintenance"
fi
if [ -d "$HOME/.local/share/applications" ]; then
    cp "$SCRIPT_DIR/desktop/canon-g3010-maintenance.desktop" "$HOME/.local/share/applications/" || true
fi

# 4. Enable Services
echo -e "\n${GREEN}[4/5] Enabling CUPS and Avahi services...${NC}"
$SUDO systemctl enable --now cups.service avahi-daemon.service || true

# 5. Network Printer Discovery & Queue Setup
echo -e "\n${GREEN}[5/5] Configuring CUPS Printer Queue...${NC}"
PRINTER_NAME="Canon_G3010"
PRINTER_IP="169.254.108.236"

# Check active Wi-Fi profile in NetworkManager to ensure link-local route
if command -v nmcli >/dev/null 2>&1; then
    ACTIVE_CON=$(nmcli -t -f NAME,TYPE con show --active | grep -E "wireless|802-11-wireless" | cut -d: -f1 | head -n 1 || true)
    if [ -n "$ACTIVE_CON" ]; then
        echo "    Ensuring link-local IPv4 route on connection '$ACTIVE_CON'..."
        $SUDO nmcli con modify "$ACTIVE_CON" ipv4.link-local 1 +ipv4.routes "169.254.0.0/16" 2>/dev/null || true
        $SUDO nmcli con up "$ACTIVE_CON" 2>/dev/null || true
    fi
fi

# Pick PPD
PPD_FILE=""
if [ -f /usr/share/ppd/canong3010.ppd ]; then
    PPD_FILE="lsb/usr/canong3010.ppd"
elif [ -f /usr/share/cups/model/canong3010.ppd ]; then
    PPD_FILE="canong3010.ppd"
else
    PPD_FILE="gutenprint.5.3://bjc-PIXMA-G3010/expert"
fi

echo "    Adding printer '$PRINTER_NAME' (socket://$PRINTER_IP:9100) with PPD '$PPD_FILE'..."
$SUDO lpadmin -p "$PRINTER_NAME" -E -v "socket://$PRINTER_IP:9100" -m "$PPD_FILE" || \
$SUDO lpadmin -p "$PRINTER_NAME" -E -v "socket://$PRINTER_IP:9100" -m "everywhere"
$SUDO lpadmin -d "$PRINTER_NAME"

echo -e "\n${BLUE}==================================================================${NC}"
echo -e "${GREEN} ✅ Installation Complete!${NC}"
echo -e " • Printer default set to: ${YELLOW}$PRINTER_NAME${NC}"
echo -e " • Launch maintenance tool anytime by typing: ${YELLOW}canon-g3010-maintenance${NC}"
echo -e " • Or search for ${YELLOW}'Canon PIXMA G3010 Maintenance'${NC} in your app launcher."
echo -e "${BLUE}==================================================================${NC}"
