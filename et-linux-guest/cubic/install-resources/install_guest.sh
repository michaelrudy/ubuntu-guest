#!/usr/bin/env bash
# Modular guest OS installation and hardening script
# Runs during first boot / autoinstall process

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
echo "║  Ubuntu 22.04 Hardened Guest - Installation & Configuration"
echo "║  Running modular setup..."
echo "╚════════════════════════════════════════════════════════════════╝"

# Run modules in order
run_module "00_system_prep.sh"
run_module "10_cleanup_apps.sh"
run_module "20_smart_card_config.sh"
run_module "30_user_setup.sh"
run_module "35_audio_config.sh"
run_module "40_gnome_config.sh"
run_module "50_apply_stig.sh"
run_module "99_finalize.sh"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✓ All modules completed successfully"
echo "║  System ready for reboot"
echo "╚════════════════════════════════════════════════════════════════╝"
