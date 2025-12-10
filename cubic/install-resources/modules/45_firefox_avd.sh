#!/usr/bin/env bash
set -e

echo "=== Configure Firefox for AVD Web Client Kiosk Mode ==="

# Create Firefox policies directory
mkdir -p /etc/firefox/policies

# Create managed policy to lock down Firefox to only AVD web client
tee /etc/firefox/policies/policies.json > /dev/null << 'EOF'
{
  "policies": {
    "WebsiteFilter": {
      "Block": ["<all_urls>"],
      "Exceptions": [
        "https://client.wvd.microsoft.com/*",
        "https://*.wvd.microsoft.com/*",
        "https://login.microsoftonline.com/*",
        "https://*.login.microsoftonline.com/*",
        "https://*.login.live.com/*",
        "https://*.windows.net/*",
        "https://*.microsoft.com/*"
      ]
    },
    "Homepage": {
      "URL": "https://client.wvd.microsoft.com/arm/webclient/index.html",
      "Locked": true,
      "StartPage": "homepage"
    },
    "NoDefaultBookmarks": true,
    "DontCheckDefaultBrowser": true,
    "DisableDeveloperTools": true,
    "DisablePrivateBrowsing": true,
    "DisableProfileImport": true,
    "DisableSystemAddonUpdate": true,
    "DisableTelemetry": true,
    "PasswordManagerEnabled": true,
    "Preferences": {
      "browser.toolbars.bookmarks.visibility": "never",
      "browser.tabs.warnOnClose": false
    }
  }
}
EOF

# Create AVD Web Client desktop launcher
mkdir -p /usr/share/applications
tee /usr/share/applications/avd-webclient.desktop > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=AVD Web Client
Comment=Azure Virtual Desktop Web Client
Exec=firefox-esr https://client.wvd.microsoft.com/arm/webclient/index.html
Icon=firefox-esr
Terminal=false
Categories=Network;RemoteAccess;
StartupNotify=true
EOF

chmod 644 /usr/share/applications/avd-webclient.desktop

# Configure Firefox to load SafeNet smart card module
echo "=== Configuring Firefox security modules ==="

# Initialize Firefox profile by running it briefly
sudo -u kiosk timeout 5 firefox-esr --headless 2>/dev/null || true

# Wait for profile creation
sleep 2

# Find the actual profile directory (Firefox ESR may create different profile names)
FIREFOX_PROFILE_DIR=$(find /home/kiosk/.mozilla/firefox* -maxdepth 2 -name "*.default*" -type d 2>/dev/null | head -1)

if [ -z "$FIREFOX_PROFILE_DIR" ]; then
    # Fallback: create profile manually
    mkdir -p /home/kiosk/.mozilla/firefox
    FIREFOX_PROFILE_DIR="/home/kiosk/.mozilla/firefox/kiosk.default"
    mkdir -p "$FIREFOX_PROFILE_DIR"
    
    tee /home/kiosk/.mozilla/firefox/profiles.ini > /dev/null << 'EOF'
[General]
StartWithLastProfile=1

[Profile0]
Name=default
IsRelative=1
Path=kiosk.default
Default=1
EOF
fi

# Load the SafeNet PKCS#11 module
echo "Loading SafeNet module into Firefox profile: $FIREFOX_PROFILE_DIR"
modutil -dbdir sql:"$FIREFOX_PROFILE_DIR" -add "SafeNet Authentication Client" -libfile /usr/lib/libeToken.so -force 2>&1 || true

# Set ownership
chown -R kiosk:kiosk /home/kiosk/.mozilla

echo "✓ Firefox smart card module configured (libeToken.so)"

# Set proper permissions
chmod 644 /etc/firefox/policies/policies.json

echo "✓ Firefox configured for AVD Web Client kiosk mode"
echo "✓ URL restrictions applied - only Microsoft AVD domains allowed"
echo "✓ Desktop launcher created: avd-webclient.desktop"
