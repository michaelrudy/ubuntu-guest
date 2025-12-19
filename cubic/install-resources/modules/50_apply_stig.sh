#!/usr/bin/env bash
set -e

echo "=== Setting locale for Ansible ==="
# Generate and set locale for Ansible (required for STIG playbook)
locale-gen en_US.UTF-8 || true
update-locale LANG=en_US.UTF-8 || true
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "=== Creating DISA STIG playbook ==="
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

echo "=== Running DISA STIG playbook on localhost ==="
ansible-playbook -i localhost, /tmp/apply-stig.yml
