#!/usr/bin/env bash
set -e

echo "=== Creating DISA STIG playbook ==="
tee /tmp/apply-stig.yml > /dev/null << 'EOF'
---
- name: Apply DISA STIG
  hosts: localhost
  connection: local
  become: true

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
