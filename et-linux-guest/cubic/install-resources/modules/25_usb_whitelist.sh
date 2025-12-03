#!/usr/bin/env bash
set -e

echo "=== Configuring USBGuard device whitelist ==="

# Create USBGuard policy directory
mkdir -p /etc/usbguard

# Configure USBGuard daemon settings
tee /etc/usbguard/usbguard-daemon.conf > /dev/null << 'EOF'
# USBGuard Daemon Configuration
RuleFile=/etc/usbguard/rules.conf
ImplicitPolicyTarget=block
PresentDevicePolicy=apply-policy
PresentControllerPolicy=allow
InsertedDevicePolicy=apply-policy
RestoreControllerDeviceState=false
DeviceManagerBackend=uevent
IPCAllowedUsers=root
IPCAllowedGroups=root
IPCAccessControlFiles=/etc/usbguard/IPCAccessControl.d/
DeviceRulesWithPort=false
AuditBackend=FileAudit
AuditFilePath=/var/log/usbguard/usbguard-audit.log
EOF

# Create audit log directory
mkdir -p /var/log/usbguard
chown root:root /var/log/usbguard
chmod 750 /var/log/usbguard

# Create USBGuard whitelist policy
# Hardware IDs are persistent across reboots and VM instances

# review line 58 because I might not need the additional interfaces for webcam
tee /etc/usbguard/rules.conf > /dev/null << 'EOF'
# USBGuard Policy - Whitelist approved devices only
# Default action for unlisted devices: block

# ===== VIRTUALIZATION INFRASTRUCTURE =====
# QEMU USB Tablet (0627:0001) - Required for mouse in VM
allow id 0627:0001

# QEMU USB Keyboard (0627:0001) - Some VMs use same ID
allow with-interface 03:01:01

# USB Root Hubs (1d6b:0002 and 1d6b:0003) - Required for USB to work
allow id 1d6b:0002
allow id 1d6b:0003
allow id 1d6b:*

# ===== APPROVED PERIPHERAL DEVICES =====
# OmniKey Smart Card Reader (076b:3031)
allow id 076b:3031

# Logitech HD Pro Webcam C920 (046d:082d)
# Needs video, audio, and control interfaces
allow id 046d:082d
allow id 046d:082d with-interface 0e:01:00
allow id 046d:082d with-interface 0e:02:00
allow id 046d:082d with-interface 01:01:00
allow id 046d:082d with-interface 01:02:00

# DASAN ELECTRON DSU-08M Headset (2ea1:0110)
allow id 2ea1:0110

# ===== DEFAULT DENY =====
# All other devices are implicitly blocked by ImplicitPolicyTarget=block
EOF

# Set proper permissions
chmod 600 /etc/usbguard/rules.conf
chmod 600 /etc/usbguard/usbguard-daemon.conf

# Verify USBGuard runs as root (default) - no special user needed
# Create IPC access control directory
mkdir -p /etc/usbguard/IPCAccessControl.d/

# Enable USBGuard service (don't start yet - will start on reboot)
systemctl enable usbguard.service

echo "=== USBGuard whitelist configuration complete ==="
echo "Approved devices:"
echo "  - OmniKey Smart Card Reader (076b:3031)"
echo "  - Logitech C920 Webcam (046d:082d)"
echo "  - DASAN DSU-08M Headset (2ea1:0110)"
echo "  - QEMU USB Tablet (0627:0001)"
echo "  - USB Root Hubs (1d6b:*)"
echo ""
echo "USBGuard will start on next boot"
