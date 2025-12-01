#!/usr/bin/env bash
set -e

echo "=== Ensuring gdm user exists ==="
# GDM requires this user - it may not exist after autoinstall
getent group gdm >/dev/null || groupadd -r gdm
getent passwd gdm >/dev/null || useradd -r -g gdm -d /var/lib/gdm3 -s /usr/sbin/nologin gdm
mkdir -p /var/lib/gdm3
chown -R gdm:gdm /var/lib/gdm3
chmod 750 /var/lib/gdm3

echo "=== Ensuring kiosk user exists ==="
if ! id -u kiosk >/dev/null 2>&1; then
  useradd -m -s /bin/bash kiosk
  echo "kiosk:kiosk" | chpasswd
fi

echo "=== Configuring GDM autologin for kiosk ==="
tee /etc/gdm3/custom.conf > /dev/null << 'EOF'
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=kiosk

[security]

[xdmcp]

[chooser]

[debug]
#Enable=true
EOF
