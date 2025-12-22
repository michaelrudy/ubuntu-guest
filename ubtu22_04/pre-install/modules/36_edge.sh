#!/usr/bin/env bash
set -e

echo "=== Install Microsoft Edge ==="
# Assumes microsoft-edge-stable_*.deb is in /root/install-resources/pre-install/
dpkg -i ./microsoft-edge-stable_*.deb || true
# Fix any dependency issues
apt install -f -y
# Install libnss3-tools for smart card support
apt install -y libnss3-tools

echo "Microsoft Edge installed"
