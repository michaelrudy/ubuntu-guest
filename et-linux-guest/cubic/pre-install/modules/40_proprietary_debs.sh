#!/usr/bin/env bash
set -e

echo "=== Install rdcore.deb and safenet.deb (with deps) ==="
# Assumes rdcore.deb and safenet.deb are in /root/install-resources/pre-install/
dpkg -i ./rdcore.deb ./safenet.deb || apt install -f -y
# Optional: rerun dpkg to be 100% sure they're fully configured
dpkg -i ./rdcore.deb ./safenet.deb || true
