#!/usr/bin/env bash
set -e

echo "=== Enabling LightDM display manager ==="
systemctl set-default graphical.target
systemctl enable lightdm --no-start || true

echo "=== Re-enabling LightDM after STIG (in case STIG disabled it) ==="
# STIG hardening may disable certain services, ensure LightDM stays enabled
systemctl set-default graphical.target
systemctl enable lightdm --no-start || true

echo "=== Installation and hardening complete ==="
echo "The system will reboot after autoinstall finishes."
