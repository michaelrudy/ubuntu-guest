#!/usr/bin/env bash
set -e

echo "=== Install audio packages ==="
apt install -y \
  pulseaudio \
  pulseaudio-module-bluetooth \
  pavucontrol \
  alsa-utils \
  rtkit
