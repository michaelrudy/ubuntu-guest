#!/usr/bin/env bash
# Modular installation script for Cubic chroot environment
# Needs to be run in an internet-connected environment
# Assumes rdcore.deb and safenet.deb are in /root/install-resources/pre-install/

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/modules"

# Function to run a module
run_module() {
    local module="$1"
    local module_path="${MODULES_DIR}/${module}"
    
    if [[ -f "${module_path}" ]]; then
        echo ""
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║  Running: ${module}"
        echo "╚════════════════════════════════════════════════════════════════╝"
        bash "${module_path}"
    else
        echo "⚠️  Module not found: ${module_path}"
        return 1
    fi
}

# Main execution
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Ubuntu 22.04 Hardened Guest - Pre-Install Setup"
echo "║  Running modular installation..."
echo "╚════════════════════════════════════════════════════════════════╝"

# Run modules in order
run_module "00_base_system.sh"
run_module "10_xfce_desktop.sh"
run_module "20_smart_card.sh"
run_module "25_usbguard.sh"
run_module "30_audio.sh"
run_module "40_proprietary_debs.sh"
run_module "50_ansible_stig.sh"
run_module "99_cleanup.sh"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✓ All modules completed successfully"
echo "╚════════════════════════════════════════════════════════════════╝"
