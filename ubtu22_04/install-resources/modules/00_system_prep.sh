#!/usr/bin/env bash
set -e

echo "=== Generate and set locale ==="
locale-gen en_US.UTF-8 || true
update-locale LANG=en_US.UTF-8 || true
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
