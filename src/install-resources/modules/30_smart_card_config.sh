#!/usr/bin/env bash
set -e

echo "=== Enabling pcscd service ==="
systemctl enable pcscd || true

# Check OS version to determine if Broadcom support is needed
OS_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')

if [ "$OS_VERSION" = "22.04" ]; then
    echo "=== Ubuntu 22.04 detected - Adding Broadcom 58200 smart card reader support ==="
    
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
        
        echo "✓ Broadcom 58200 added to libccid configuration"
    else
        echo "WARNING: libccid Info.plist not found at $PLIST"
    fi
else
    echo "=== Ubuntu $OS_VERSION detected - Broadcom 58200 support is built-in, skipping manual configuration ==="
fi

echo "=== Configuring p11-kit SafeNet module ==="
mkdir -p /usr/share/p11-kit/modules

tee /usr/share/p11-kit/modules/safenet.module > /dev/null << 'EOF'
module: /usr/lib/libeToken.so
trust-policy: yes
EOF

chown root:root /usr/share/p11-kit/modules/safenet.module
chmod 644 /usr/share/p11-kit/modules/safenet.module
