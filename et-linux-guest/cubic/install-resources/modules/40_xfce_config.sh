#!/usr/bin/env bash
set -e

# TO-DO: need to move out the xml stuff into a separate config folder for easier maintenance

echo "=== Configuring XFCE4 kiosk mode ==="

# Copy wallpaper to system backgrounds directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_RESOURCES_DIR="$(dirname "$SCRIPT_DIR")"
mkdir -p /usr/share/backgrounds
cp "${INSTALL_RESOURCES_DIR}/assets/wallpaper.png" /usr/share/backgrounds/wallpaper.png
chmod 644 /usr/share/backgrounds/wallpaper.png

# Create XFCE4 configuration directory for kiosk user
mkdir -p /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml
mkdir -p /home/kiosk/.config/xfce4/panel

# Configure XFCE4 Panel - dual panel setup (top bar + bottom taskbar)
tee /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <value type="int" value="2"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
      <property name="icon-size" type="uint" value="32"/>
      <property name="autohide-behavior" type="uint" value="0"/>
      <property name="disable-struts" type="bool" value="false"/>
      <property name="mode" type="uint" value="0"/>
      <property name="nrows" type="uint" value="1"/>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-rgba" type="array">
        <value type="double" value="0.117647"/>
        <value type="double" value="0.117647"/>
        <value type="double" value="0.117647"/>
        <value type="double" value="0.95"/>
      </property>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
      </property>
    </property>
    <property name="panel-2" type="empty">
      <property name="position" type="string" value="p=10;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
      <property name="autohide-behavior" type="uint" value="0"/>
      <property name="disable-struts" type="bool" value="false"/>
      <property name="mode" type="uint" value="0"/>
      <property name="nrows" type="uint" value="1"/>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-rgba" type="array">
        <value type="double" value="0.117647"/>
        <value type="double" value="0.117647"/>
        <value type="double" value="0.117647"/>
        <value type="double" value="0.95"/>
      </property>
      <property name="plugin-ids" type="array">
        <value type="int" value="3"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="msrdc.desktop"/>
      </property>
    </property>
    <property name="plugin-2" type="string" value="pulseaudio">
      <property name="enable-keyboard-shortcuts" type="bool" value="true"/>
      <property name="show-notifications" type="bool" value="true"/>
    </property>
    <property name="plugin-3" type="string" value="tasklist">
      <property name="flat-buttons" type="bool" value="true"/>
      <property name="include-all-workspaces" type="bool" value="true"/>
      <property name="show-labels" type="bool" value="true"/>
      <property name="show-handle" type="bool" value="false"/>
    </property>
  </property>
</channel>
EOF

# Configure XFCE4 Desktop - disable right-click, hide icons, set wallpaper
tee /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorVirtual-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/wallpaper.png"/>
          <property name="image-path" type="string" value="/usr/share/backgrounds/wallpaper.png"/>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="style" type="int" value="0"/>
    <property name="file-icons" type="empty">
      <property name="show-home" type="bool" value="false"/>
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-removable" type="bool" value="false"/>
      <property name="show-trash" type="bool" value="false"/>
    </property>
  </property>
  <property name="desktop-menu" type="empty">
    <property name="show" type="bool" value="false"/>
  </property>
</channel>
EOF

# Configure XFCE4 Session - disable screensaver, logout, and session saving
tee /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="SaveOnExit" type="bool" value="false"/>
    <property name="LockCommand" type="string" value=""/>
  </property>
  <property name="shutdown" type="empty">
    <property name="ShowHibernate" type="bool" value="false"/>
    <property name="ShowSuspend" type="bool" value="false"/>
  </property>
</channel>
EOF

# Configure XFCE4 Power Manager - disable screen blanking and lock
tee /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-power-manager" version="1.0">
  <property name="xfce4-power-manager" type="empty">
    <property name="blank-on-ac" type="int" value="0"/>
    <property name="blank-on-battery" type="int" value="0"/>
    <property name="dpms-on-ac-sleep" type="uint" value="0"/>
    <property name="dpms-on-ac-off" type="uint" value="0"/>
    <property name="dpms-on-battery-sleep" type="uint" value="0"/>
    <property name="dpms-on-battery-off" type="uint" value="0"/>
    <property name="lock-screen-suspend-hibernate" type="bool" value="false"/>
    <property name="logind-handle-lid-switch" type="bool" value="false"/>
    <property name="presentation-mode" type="bool" value="true"/>
  </property>
</channel>
EOF

# Configure screensaver settings - disable entirely
tee /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-screensaver" version="1.0">
  <property name="saver" type="empty">
    <property name="enabled" type="bool" value="false"/>
    <property name="mode" type="int" value="0"/>
  </property>
  <property name="lock" type="empty">
    <property name="enabled" type="bool" value="false"/>
  </property>
</channel>
EOF

# Configure XFCE4 Keyboard shortcuts - disable most shortcuts for kiosk mode
tee /home/kiosk/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="custom" type="empty">
      <property name="override" type="bool" value="true"/>
    </property>
  </property>
</channel>
EOF

# Set ownership of all XFCE4 configs to kiosk user
chown -R kiosk:kiosk /home/kiosk/.config

# Create kiosk lockdown profile to prevent settings changes
mkdir -p /etc/xdg/xfce4/kiosk
tee /etc/xdg/xfce4/kiosk/kioskrc > /dev/null << 'EOF'
[xfce4-panel]
CustomizePanel=NONE

[xfce4-session]
Logout=NONE
SaveSession=NONE

[xfdesktop]
CustomizeDesktop=NONE

[xfce4-power-manager]
CustomizePowerManager=NONE

[xfce4-screensaver]
CustomizeScreensaver=NONE
EOF

# Disable xfce4-screensaver service for kiosk user
mkdir -p /home/kiosk/.config/autostart
tee /home/kiosk/.config/autostart/xfce4-screensaver.desktop > /dev/null << 'EOF'
[Desktop Entry]
Hidden=true
EOF

echo "=== XFCE4 kiosk configuration complete ==="
