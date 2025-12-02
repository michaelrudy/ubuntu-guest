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

echo "=== Cubic chroot setup complete ==="
