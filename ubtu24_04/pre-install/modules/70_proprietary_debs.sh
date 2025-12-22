#!/usr/bin/env bash
set -e

echo "=== Install safenet.deb (with deps) ==="
# Assumes safenet.deb are in /root/install-resources/pre-install/
dpkg -i ./safenet.deb || apt install -f -y
# Optional: rerun dpkg to be 100% sure they're fully configured
dpkg -i ./safenet.deb || true
