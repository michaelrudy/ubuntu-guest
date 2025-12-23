#!/usr/bin/env bash
set -e

echo "=== Ensure add-apt-repository exists ==="
apt install -y software-properties-common

echo "=== Install Ansible from official PPA ==="
apt remove -y ansible ansible-core || true
add-apt-repository --yes ppa:ansible/ansible
apt update -y
apt install -y ansible

# Check OS version to determine which STIG role to install
OS_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')
mkdir -p /etc/ansible/roles

if [ "$OS_VERSION" = "22.04" ]; then
    echo "=== Ubuntu 22.04 detected - Installing UBUNTU22-STIG role ==="
    ansible-galaxy install -p /etc/ansible/roles \
      git+https://github.com/ansible-lockdown/UBUNTU22-STIG.git
elif [ "$OS_VERSION" = "24.04" ]; then
    echo "=== Ubuntu 24.04 detected - Installing UBUNTU24-STIG role ==="
    ansible-galaxy install -p /etc/ansible/roles \
      git+https://github.com/ansible-lockdown/UBUNTU24-STIG.git
else
    echo "WARNING: Unknown Ubuntu version $OS_VERSION - installing UBUNTU24-STIG as default"
    ansible-galaxy install -p /etc/ansible/roles \
      git+https://github.com/ansible-lockdown/UBUNTU24-STIG.git
fi
