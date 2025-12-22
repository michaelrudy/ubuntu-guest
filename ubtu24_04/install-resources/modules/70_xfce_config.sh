#!/usr/bin/env bash
set -e

echo "=== Configuring XFCE4 kiosk mode ==="

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_RESOURCES_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="${INSTALL_RESOURCES_DIR}/config/xfce4"

# Create XFCE4 configuration directories for kiosk user
mkdir -p /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml
mkdir -p /home/kiosk/.config/xfce4/panel

# Copy XFCE4 XML configuration files
echo "Copying XFCE4 configuration files..."
cp "${CONFIG_DIR}/xfce4-panel.xml" /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/
cp "${CONFIG_DIR}/xfce4-desktop.xml" /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/
cp "${CONFIG_DIR}/xfce4-session.xml" /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/
cp "${CONFIG_DIR}/xfce4-power-manager.xml" /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/
cp "${CONFIG_DIR}/xfce4-screensaver.xml" /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/
cp "${CONFIG_DIR}/xfce4-keyboard-shortcuts.xml" /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/

# Set ownership of all XFCE4 configs to kiosk user
chown -R kiosk:kiosk /home/kiosk/.config

# Create kiosk lockdown profile to prevent settings changes
mkdir -p /etc/xdg/xfce4/kiosk
cp "${CONFIG_DIR}/kioskrc" /etc/xdg/xfce4/kiosk/kioskrc

# Disable xfce4-screensaver service for kiosk user
mkdir -p /home/kiosk/.config/autostart
cp "${CONFIG_DIR}/xfce4-screensaver.desktop" /home/kiosk/.config/autostart/

# Ensure proper ownership
chown -R kiosk:kiosk /home/kiosk/.config

echo "=== XFCE4 kiosk configuration complete ==="
