#!/usr/bin/env bash
set -e  # Exit on errors

# Generate and set locale for Ansible (curtin environment doesn't have locale set)
locale-gen en_US.UTF-8 || true
update-locale LANG=en_US.UTF-8 || true
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "==============================="
echo " Updating package lists..."
echo "==============================="
# sudo apt update -y
# sudo apt install git -y

echo "==============================="
echo " Installing GNOME (minimal) and base deps..."
echo "==============================="
# sudo apt install -y \
#   gnome-session \
#   gnome-shell \
#   gdm3 \
#   gnome-settings-daemon \
#   dbus-user-session \
#   adwaita-icon-theme-full \
#   libsoup-3.0-0 \
#   libwebkit2gtk-4.1-dev \
#   libubsan1

echo "==============================="
echo " Removing unwanted terminal apps from GUI..."
echo "==============================="
# These may or may not be installed; purge is safe either way.
sudo apt purge -y \
  byobu \
  htop \
  info \
  texinfo \
  vim \
  yelp || true

echo "==============================="
echo " Installing smart card stack..."
echo "==============================="
# apt install -y \
#   pcscd \
#   pcsc-tools \
#   p11-kit \
#   p11-kit-modules \
#   opensc

systemctl enable pcscd || true

echo "==============================="
echo " Ensuring gdm user exists..."
echo "==============================="
# GDM requires this user - it may not exist after autoinstall
getent group gdm >/dev/null || groupadd -r gdm
getent passwd gdm >/dev/null || useradd -r -g gdm -d /var/lib/gdm3 -s /usr/sbin/nologin gdm
mkdir -p /var/lib/gdm3
chown -R gdm:gdm /var/lib/gdm3
chmod 750 /var/lib/gdm3

echo "==============================="
echo " Enabling GDM3 display manager..."
echo "==============================="
systemctl set-default graphical.target
systemctl enable gdm3 || true

echo "==============================="
echo " Installing rdcore.deb..."
echo "==============================="
# sudo dpkg -i ./rdcore.deb || {
#   echo "dpkg reported missing dependencies for rdcore — attempting to fix..."
#   sudo apt install -f -y
# }

echo "==============================="
echo " Installing safenet.deb..."
echo "==============================="
# sudo dpkg -i ./safenet.deb || {
#   echo "dpkg reported missing dependencies for safenet — attempting to fix..."
#   sudo apt install -f -y
# }

echo "==============================="
echo " Configuring p11-kit SafeNet module..."
echo "==============================="
mkdir -p /usr/share/p11-kit/modules

tee /usr/share/p11-kit/modules/safenet.module > /dev/null << 'EOF'
module: /usr/lib/libeToken.so
trust-policy: yes
EOF

chown root:root /usr/share/p11-kit/modules/safenet.module
chmod 644 /usr/share/p11-kit/modules/safenet.module

echo "==============================="
echo " Ensuring kiosk user exists..."
echo "==============================="
if ! id -u kiosk >/dev/null 2>&1; then
  useradd -m -s /bin/bash kiosk
  echo "kiosk:kiosk" | chpasswd
fi

echo "==============================="
echo " Configuring GDM autologin for kiosk..."
echo "==============================="
tee /etc/gdm3/custom.conf > /dev/null << 'EOF'
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=kiosk

[security]

[xdmcp]

[chooser]

[debug]
#Enable=true
EOF

echo "==============================="
echo " Setting GNOME dock favorites via dconf (chroot-safe)..."
echo "==============================="
mkdir -p /etc/dconf/db/local.d
tee /etc/dconf/db/local.d/01-kiosk-settings > /dev/null << 'EOF'
[org/gnome/shell]
favorite-apps=['msrdc.desktop']

[org/gnome/desktop/screensaver]
lock-enabled=false
ubuntu-lock-on-suspend=false

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/desktop/lockdown]
disable-lock-screen=true
EOF

# Create dconf profile
mkdir -p /etc/dconf/profile
tee /etc/dconf/profile/user > /dev/null << 'EOF'
user-db:user
system-db:local
EOF

# Update dconf database
dconf update || true

echo "==============================="
echo " Installing Ansible from official PPA..."
echo "==============================="
# Ensure add-apt-repository exists (only if needed)
# if ! command -v add-apt-repository >/dev/null 2>&1; then
#   sudo apt install -y software-properties-common
# fi

# Remove any existing Ansible bits (ignore errors)
# sudo apt remove -y ansible ansible-core || true

# sudo add-apt-repository --yes ppa:ansible/ansible
# sudo apt update -y
# sudo apt install -y ansible

echo "==============================="
echo " Installing UBUNTU22-STIG role..."
echo "==============================="
# sudo mkdir -p /etc/ansible/roles
# sudo ansible-galaxy install -p /etc/ansible/roles \
#   git+https://github.com/ansible-lockdown/UBUNTU22-STIG.git

echo "==============================="
echo " Creating DISA STIG playbook..."
echo "==============================="
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

echo "==============================="
echo " Running DISA STIG playbook on localhost..."
echo "==============================="
ansible-playbook -i localhost, /tmp/apply-stig.yml

echo "==============================="
echo " Re-enabling GDM after STIG (in case STIG disabled it)..."
echo "==============================="
systemctl set-default graphical.target
systemctl enable gdm3 || true

echo "==============================="
echo " Installation and hardening complete!"
echo " The system will reboot after autoinstall finishes."
echo "==============================="
