#!/usr/bin/env bash
# ==============================================================================
# Canon PIXMA G3010 Series Linux Tool Uninstaller
# Author: 9M2PJU
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

echo "Removing Canon PIXMA G3010 Linux Tool..."

$SUDO rm -f /usr/local/bin/canon-maintenance /usr/local/bin/canon-g3010-maintenance
$SUDO rm -f /usr/local/share/applications/canon-maintenance.desktop
$SUDO rm -rf /usr/share/cmdtocanonij2

rm -f "$HOME/.local/bin/canon-maintenance" "$HOME/.local/bin/canon-g3010-maintenance"
rm -f "$HOME/.local/share/applications/canon-maintenance.desktop"

read -rp "Do you also want to remove the CUPS printer queue 'Canon_G3010'? [y/N]: " del_queue
if [[ "$del_queue" =~ ^[yY] ]]; then
    $SUDO lpadmin -x Canon_G3010 2>/dev/null || true
    echo "Removed Canon_G3010 queue from CUPS."
fi

echo "Uninstallation complete."
