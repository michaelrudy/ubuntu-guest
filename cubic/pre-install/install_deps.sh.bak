# Needs to be run in a internet-connected environment
# Assumes rdcore.deb and safenet.deb are in /root/install-resources/pre-install/

echo "=== Update apt metadata ==="
apt update -y
apt install git -y # needed for ansible sti

echo "=== Ensure locale is generated ==="
apt install -y locales
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

echo "=== Install GNOME + base deps ==="
apt install -y \
  gnome-session \
  gnome-shell \
  gdm3 \
  gnome-settings-daemon \
  dbus-user-session \
  adwaita-icon-theme-full \
  libsoup-3.0-0 \
  libwebkit2gtk-4.1-dev \
  libubsan1

echo "=== Install smart card stack ==="
apt install -y \
  pcscd \
  pcsc-tools \
  p11-kit \
  p11-kit-modules \
  opensc

echo "=== Install audio packages ==="
apt install -y \
  pulseaudio \
  pulseaudio-module-bluetooth \
  pavucontrol \
  alsa-utils \
  rtkit

echo "=== Remove unwanted terminal apps ==="
apt purge -y \
  byobu \
  htop \
  info \
  texinfo \
  vim \
  yelp || true

echo "=== Install rdcore.deb and safenet.deb (with deps) ==="
dpkg -i ./rdcore.deb ./safenet.deb || apt install -f -y
# optional: rerun dpkg to be 100% sure they’re fully configured
dpkg -i ./rdcore.deb ./safenet.deb || true

echo "=== Ensure adapt-repository exists ==="
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

apt purge git -y || true 

echo "=== Enable GDM3 and set graphical target ==="
systemctl set-default graphical.target
systemctl enable gdm3 || true

echo "=== Cubic chroot setup complete ==="