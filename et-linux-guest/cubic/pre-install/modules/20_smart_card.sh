#!/usr/bin/env bash
set -e

echo "=== Install smart card stack ==="
apt install -y \
  pcscd \
  pcsc-tools \
  p11-kit \
  p11-kit-modules \
  opensc
