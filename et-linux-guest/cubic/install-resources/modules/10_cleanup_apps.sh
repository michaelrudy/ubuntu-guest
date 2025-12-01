#!/usr/bin/env bash
set -e

echo "=== Removing unwanted terminal apps from GUI ==="
# These may or may not be installed; purge is safe either way
apt purge -y \
  byobu \
  htop \
  info \
  texinfo \
  vim \
  yelp || true
