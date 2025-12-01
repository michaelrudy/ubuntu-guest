#!/usr/bin/env bash
set -e

echo "=== Install GNOME + base deps ==="
apt install -y \
  gnome-session \
  gnome-shell \
  gdm3 \
  gnome-settings-daemon \
  dbus-user-session \
  adwaita-icon-theme-full \
  libsoup-3.0-0 \
  libwebkit2gtk-4.1-dev \
  libubsan1
