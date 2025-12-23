#!/usr/bin/env bash
set -e

echo "=== Update apt metadata ==="
apt update -y && apt upgrade -y
apt install git -y # needed for ansible stig

echo "=== Ensure locale is generated ==="
apt install -y locales
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
