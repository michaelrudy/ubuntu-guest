#!/usr/bin/env bash
set -e

echo "=== Removing unwanted packages ==="

# Remove unnecessary terminal apps
apt-get purge -y \
  byobu \
  htop \
  info \
  texinfo \
  vim \
  yelp \
  git || true

# Remove GNOME packages (not needed with XFCE4)
apt-get purge -y gnome-* ubuntu-desktop || true

echo "=== Removing documentation and man pages ==="

# Remove documentation to save space
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*
rm -rf /usr/share/lintian/*
rm -rf /usr/share/help/*

echo "=== Cleaning up unused packages ==="

# Remove unused dependencies
apt-get autoremove -y --purge

# Clean package caches
apt-get autoclean
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/archives/*.deb

echo "=== Cleanup complete ==="
