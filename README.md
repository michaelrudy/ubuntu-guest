# Ubuntu 22.04 Hardened Guest OS

Custom Ubuntu 22.04 guest operating system configured with enterprise security hardening and smart card authentication.

## Features

- **DISA STIG Compliance**: Hardened against Defense Information Systems Agency Security Technical Implementation Guide standards
- **Smart Card Authentication**: CAC/PIV card support enabled
- **Enterprise Ready**: Suitable for government and high-security environments

## Contents

- `et-linux-guest/cubic/`: Build configuration and installation scripts
- `install_guest.sh`: Main guest OS installation and hardening script
- `install_deps.sh`: Dependency installation

## Usage

Build the custom ISO using the provided scripts in the `et-linux-guest/cubic/` directory.

