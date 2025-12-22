#!/usr/bin/env bash
set -e

echo "=== Enabling pcscd service ==="
systemctl enable pcscd || true

echo "=== Adding Broadcom 58200 (0x5865) to libccid ==="
PLIST="/usr/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Info.plist"

if [ -f "$PLIST" ]; then
    # Backup the original file
    cp "$PLIST" "${PLIST}.bak"
    
    # Add Broadcom 58200 vendor ID (0x0A5C) to ifdVendorID array
    # Insert after the opening <array> tag in ifdVendorID section
    sed -i '/<key>ifdVendorID<\/key>/{n;s/<array>/<array>\n\t\t<string>0x0A5C<\/string>/}' "$PLIST"
    
    # Add Broadcom 58200 product ID (0x5865) to ifdProductID array
    sed -i '/<key>ifdProductID<\/key>/{n;s/<array>/<array>\n\t\t<string>0x5865<\/string>/}' "$PLIST"
    
    # Add friendly name to ifdFriendlyName array
    sed -i '/<key>ifdFriendlyName<\/key>/{n;s/<array>/<array>\n\t\t<string>Broadcom 58200 (0x5865)<\/string>/}' "$PLIST"
    
    echo "Broadcom 58200 added to libccid configuration"
else
    echo "WARNING: libccid Info.plist not found at $PLIST"
fi

echo "=== Configuring p11-kit SafeNet module ==="
mkdir -p /usr/share/p11-kit/modules

tee /usr/share/p11-kit/modules/safenet.module > /dev/null << 'EOF'
module: /usr/lib/libeToken.so
trust-policy: yes
EOF

chown root:root /usr/share/p11-kit/modules/safenet.module
chmod 644 /usr/share/p11-kit/modules/safenet.module
