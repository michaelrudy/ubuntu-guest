#!/usr/bin/env bash
set -e

echo "=== Ensure add-apt-repository exists ==="
apt install -y software-properties-common

echo "=== Install Ansible from official PPA ==="
apt remove -y ansible ansible-core || true
add-apt-repository --yes ppa:ansible/ansible
apt update -y
apt install -y ansible

echo "=== Install UBUNTU22-STIG role ==="
mkdir -p /etc/ansible/roles
ansible-galaxy install -p /etc/ansible/roles \
  git+https://github.com/ansible-lockdown/UBUNTU22-STIG.git
