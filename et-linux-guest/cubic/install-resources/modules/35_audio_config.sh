#!/usr/bin/env bash
set -e

echo "=== Configuring audio system ==="

# Ensure rtkit user exists (required for rtkit-daemon)
getent group rtkit >/dev/null || groupadd -r rtkit
getent passwd rtkit >/dev/null || useradd -r -g rtkit -d /proc -s /usr/sbin/nologin -c "RealtimeKit" rtkit

# Enable and start rtkit daemon
systemctl enable rtkit-daemon.service || true
systemctl start rtkit-daemon.service || true

# Enable and start PulseAudio socket for systemd user sessions
systemctl --global enable pulseaudio.socket || true
systemctl --global enable pulseaudio.service || true

# Add kiosk user to audio and video groups
usermod -aG audio,video kiosk || true

# Create PulseAudio configuration for kiosk user
mkdir -p /home/kiosk/.config/pulse
tee /home/kiosk/.config/pulse/client.conf > /dev/null << 'EOF'
# Automatically start PulseAudio if not running
autospawn = yes
daemon-binary = /usr/bin/pulseaudio
EOF

chown -R kiosk:kiosk /home/kiosk/.config

echo "=== Audio configuration complete ==="
