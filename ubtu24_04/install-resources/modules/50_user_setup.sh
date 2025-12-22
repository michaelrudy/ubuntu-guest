#!/usr/bin/env bash
set -e

echo "=== Ensuring lightdm user exists ==="
# LightDM requires this user to run the greeter
getent group lightdm >/dev/null || groupadd -r lightdm
getent passwd lightdm >/dev/null || useradd -r -g lightdm -d /var/lib/lightdm -s /usr/sbin/nologin -c "Light Display Manager" lightdm
mkdir -p /var/lib/lightdm
mkdir -p /var/lib/lightdm-data
chown -R lightdm:lightdm /var/lib/lightdm
chown -R lightdm:lightdm /var/lib/lightdm-data
chmod 750 /var/lib/lightdm

echo "=== Ensuring kiosk user exists ==="
if ! id -u kiosk >/dev/null 2>&1; then
  useradd -m -s /bin/bash kiosk
  echo "kiosk:kiosk" | chpasswd
fi

echo "=== Configuring LightDM autologin for kiosk ==="
# Create LightDM configuration directory
mkdir -p /etc/lightdm/lightdm.conf.d

# Configure autologin for kiosk user
tee /etc/lightdm/lightdm.conf.d/50-kiosk-autologin.conf > /dev/null << 'EOF'
[Seat:*]
autologin-user=kiosk
autologin-user-timeout=0
user-session=xfce
EOF
