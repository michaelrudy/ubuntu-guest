#!/usr/bin/env bash
set -e

echo "=== Install XFCE4 + LightDM ==="
apt install -y \
  xfce4 \
  xfce4-power-manager-plugins \
  lightdm \
  lightdm-gtk-greeter \
  dbus-user-session \
  libubsan1 \
  network-manager # remember to comment out this line

: '
Include these in the list above if we are installing the reference client - NOTE will only work on Ubuntu 22.04 due to
dpkg python3 post-installation failures in 24.04.
libsoup-3.0-0 \  
libwebkit2gtk-4.1-dev \
'


 # libsoup-3.0-0 \  # we do not need these if we are ommitting the reference client
# libwebkit2gtk-4.1-dev \

apt remove -y light-locker-settings || true
apt remove -y light-locker || true

# unsure if I need these commands
echo "=== Configure LightDM as default display manager ==="
# Set LightDM as the system's display manager
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
# Reconfigure to ensure it's properly set
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure lightdm || true
