#!/usr/bin/env bash
set -e

echo "=== Setting locale for Ansible ==="
# Generate and set locale for Ansible (required for STIG playbook)
locale-gen en_US.UTF-8 || true
update-locale LANG=en_US.UTF-8 || true
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Check OS version to determine which STIG variables and role to use
OS_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')

echo "=== Creating DISA STIG playbook ==="

if [ "$OS_VERSION" = "22.04" ]; then
    echo "=== Ubuntu 22.04 detected - Using UBUNTU22-STIG role ==="
    tee /tmp/apply-stig.yml > /dev/null << 'EOF'
---
- name: Apply DISA STIG
  hosts: localhost
  connection: local
  become: true
  ignore_errors: true

  vars:
    ubtu22stig_cat1: true
    ubtu22stig_cat2: true
    ubtu22stig_cat3: true
    ubtu22stig_run_audit: true

  roles:
    - UBUNTU22-STIG
EOF

elif [ "$OS_VERSION" = "24.04" ]; then
    echo "=== Ubuntu 24.04 detected - Using UBUNTU24-STIG role ==="
    tee /tmp/apply-stig.yml > /dev/null << 'EOF'
---
- name: Apply DISA STIG
  hosts: localhost
  connection: local
  become: true
  ignore_errors: true

  vars:
    ubtu24stig_cat1: true
    ubtu24stig_cat2: true
    ubtu24stig_cat3: true
    ubtu24stig_run_audit: true

  roles:
    - UBUNTU24-STIG
EOF

else
    echo "WARNING: Unknown Ubuntu version $OS_VERSION - Using UBUNTU24-STIG as default"
    tee /tmp/apply-stig.yml > /dev/null << 'EOF'
---
- name: Apply DISA STIG
  hosts: localhost
  connection: local
  become: true
  ignore_errors: true

  vars:
    ubtu24stig_cat1: true
    ubtu24stig_cat2: true
    ubtu24stig_cat3: true
    ubtu24stig_run_audit: true

  roles:
    - UBUNTU24-STIG
EOF
fi

echo "=== Running DISA STIG playbook on localhost ==="
ansible-playbook -i localhost, /tmp/apply-stig.yml
