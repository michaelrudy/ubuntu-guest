#!/usr/bin/env bash
set -e

echo "=== Remove unwanted terminal apps ==="
apt purge -y \
  byobu \
  htop \
  info \
  texinfo \
  vim \
  yelp \
  git || true

echo "=== Enable GDM3 and set graphical target ==="
systemctl set-default graphical.target
systemctl enable gdm3 || true

echo "=== Cubic chroot setup complete ==="
