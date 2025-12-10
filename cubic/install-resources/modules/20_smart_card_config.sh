#!/usr/bin/env bash
set -e

echo "=== Enabling pcscd service ==="
systemctl enable pcscd || true

echo "=== Configuring p11-kit SafeNet module ==="
mkdir -p /usr/share/p11-kit/modules

tee /usr/share/p11-kit/modules/safenet.module > /dev/null << 'EOF'
module: /usr/lib/libeToken.so
trust-policy: yes
EOF

chown root:root /usr/share/p11-kit/modules/safenet.module
chmod 644 /usr/share/p11-kit/modules/safenet.module
