#!/usr/bin/env bash
set -e

echo "=== Install XFCE4 + LightDM ==="
apt install -y \
  xfce4 \
  lightdm \
  lightdm-gtk-greeter \
  dbus-user-session \
  libsoup-3.0-0 \
  libwebkit2gtk-4.1-dev \
  libubsan1

# TO-DO: some of the packages above are not exclusively used for XFCE; might move them to a common module

# unsure if I need these commands
echo "=== Configure LightDM as default display manager ==="
# Set LightDM as the system's display manager
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
# Reconfigure to ensure it's properly set
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure lightdm || true
