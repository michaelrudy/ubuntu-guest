# tinyOS

Custom Ubuntu 22.04 guest operating system configured with enterprise security hardening and smart card authentication.

## Features

- **XFCE4 Kiosk Mode**: Lightweight desktop with locked-down single-app interface
- **DISA STIG Compliance**: Hardened against Defense Information Systems Agency Security Technical Implementation Guide standards
- **Smart Card Authentication**: CAC/PIV card support enabled (pcscd, opensc, p11-kit)
- **Audio & Video Support**: PulseAudio with USB device support, webcam-ready
- **Modular Build System**: Easy-to-customize installation modules
- **Enterprise Ready**: Suitable for government and high-security environments

## Project Structure

```
tinyos/cubic/
├── config/
│   └── user-data                    # Cloud-init autoinstall configuration
│   └── meta-data                    
├── pre-install/
│   ├── install_deps.sh              # Main pre-install orchestrator
│   └── modules/                     # Pre-install modules (run in Cubic chroot)
│       ├── 00_base_system.sh        # Base system setup (apt, locale)
│       ├── 10_xfce_desktop.sh       # XFCE4 desktop + LightDM display manager
│       ├── 20_smart_card.sh         # Smart card stack (pcscd, opensc)
│       ├── 25_usbguard.sh           # USBGuard package installation
│       ├── 30_audio.sh              # PulseAudio and audio packages
│       ├── 35_firefox.sh            # Firefox ESR (non-snap) from Mozilla PPA
│       ├── 40_proprietary_debs.sh   # Custom .deb packages (rdcore, safenet)
│       ├── 50_ansible_stig.sh       # Ansible + UBUNTU22-STIG role
│       └── 99_cleanup.sh            # Remove unwanted apps, finalize
└── install-resources/
    ├── install_guest.sh             # Main guest installation orchestrator
    └── modules/                     # Guest install modules (run on first boot)
        ├── 00_system_prep.sh        # Locale generation
        ├── 10_cleanup_apps.sh       # Placeholder (cleanup done in pre-install)
        ├── 20_smart_card_config.sh  # Configure p11-kit SafeNet module
        ├── 25_usb_whitelist.sh      # Configure USBGuard device whitelist
        ├── 30_user_setup.sh         # Create users (lightdm, kiosk), configure autologin
        ├── 35_audio_config.sh       # Configure audio/video groups, PulseAudio
        ├── 40_xfce_config.sh        # XFCE4 panel, desktop, kiosk lockdown
        ├── 45_firefox_avd.sh        # Firefox AVD web client kiosk policies
        ├── 50_apply_stig.sh         # Run DISA STIG hardening playbook
        └── 99_finalize.sh           # Enable LightDM, final system checks
```

## Desktop Environment

The kiosk interface features:
- Full-width top panel with app launcher, window list, and audio control
- Disabled desktop right-click and icons
- Locked panel configuration
- No screensaver or screen locking
- Single-purpose application focus

## Modular Architecture

The build system uses a modular approach with numbered script modules:

- **Numbered prefixes** (00, 10, 20...): Define execution order and dependencies
- **Pre-install modules**: Run during ISO creation in Cubic chroot environment
- **Guest install modules**: Run during first boot via cloud-init autoinstall
- **Easy customization**: Comment out module calls in main scripts to disable features

### Adding/Removing Features

To disable a feature, comment out the corresponding module in the main orchestrator script:

```bash
# In install_deps.sh or install_guest.sh
# run_module "30_audio.sh"  # Disable audio support
```

To add a new module, create a numbered script (e.g., `25_new_feature.sh`) and add it to the orchestrator.

## Build Process

1. **Pre-Install** (`install_deps.sh`): Installs packages and configures the ISO in Cubic
2. **Autoinstall** (`user-data`): Automated Ubuntu installation with cloud-init
3. **Guest Install** (`install_guest.sh`): First-boot configuration and hardening

## Usage

Build the custom ISO using Cubic with the provided configuration in `tinyOS/cubic/`.

## Installation Log

After installation, review `/opt/install.log` on the installed system for detailed output.
