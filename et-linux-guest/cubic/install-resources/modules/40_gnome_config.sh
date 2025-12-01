#!/usr/bin/env bash
set -e

echo "=== Setting GNOME dock favorites via dconf ==="
mkdir -p /etc/dconf/db/local.d
tee /etc/dconf/db/local.d/01-kiosk-settings > /dev/null << 'EOF'
[org/gnome/shell]
favorite-apps=['msrdc.desktop']

[org/gnome/desktop/screensaver]
lock-enabled=false
ubuntu-lock-on-suspend=false

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/desktop/lockdown]
disable-lock-screen=true
EOF

# Create dconf profile
mkdir -p /etc/dconf/profile
tee /etc/dconf/profile/user > /dev/null << 'EOF'
user-db:user
system-db:local
EOF

# Update dconf database
dconf update || true
