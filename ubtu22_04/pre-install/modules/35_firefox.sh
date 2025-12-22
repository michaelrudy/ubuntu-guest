#!/usr/bin/env bash
set -e

echo "=== Install Firefox ESR ==="
# Install software-properties-common for add-apt-repository command
apt install -y software-properties-common

# Add Mozilla Team PPA for Firefox ESR (non-snap version)
# https://askubuntu.com/questions/1409351/ubuntu-22-04-firefox-unable-to-load-module
add-apt-repository ppa:mozillateam/ppa -y
apt update
apt install -y firefox-esr libnss3-tools

echo "Firefox ESR installed"
