#!/usr/bin/env bash
set -e

echo "=== Enabling GDM3 display manager ==="
systemctl set-default graphical.target
systemctl enable gdm3 || true

echo "=== Re-enabling GDM after STIG (in case STIG disabled it) ==="
# STIG hardening may disable certain services, ensure GDM stays enabled
systemctl set-default graphical.target
systemctl enable gdm3 || true

echo "=== Installation and hardening complete ==="
echo "The system will reboot after autoinstall finishes."
