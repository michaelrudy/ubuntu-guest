#!/usr/bin/env bash
set -e

echo "=== Removing unwanted packages ==="

# Clean package caches
apt-get autoclean
apt-get clean

echo "=== Cleanup complete ==="
