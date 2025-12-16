#!/usr/bin/env bash
set -e

echo "=== Configure Microsoft Edge for AVD Web Client Kiosk Mode ==="

# Create Edge policies directories (try both locations)
mkdir -p /etc/opt/edge/policies/managed
mkdir -p /etc/microsoft-edge/policies/managed

# Create managed policy to lock down Edge to only AVD web client
tee /etc/opt/edge/policies/managed/managed.json > /dev/null << 'EOF'
{
  "URLBlocklist": [
    "*"
  ],
  "URLAllowlist": [
    "client.wvd.microsoft.com",
    "*.wvd.microsoft.com",
    "https://client.wvd.microsoft.com/*",
    "https://*.wvd.microsoft.com/*",
    "login.microsoft.com",
    "login.microsoftonline.com",
    "https://login.microsoftonline.com/*",
    "*.login.microsoft.com",
    "https://login.microsoft.com/*",
    "https://*.login.microsoft.com/*",
    "*.login.live.com",
    "https://*.login.live.com/*",
    "*.windows.net",
    "https://*.windows.net/*",
    "*.microsoft.com",
    "https://*.microsoft.com/*",
    "*.msftauth.net",
    "https://*.msftauth.net/*",
    "*.msauth.net",
    "https://*.msauth.net/*",
    "*.msidentity.com",
    "https://*.msidentity.com/*",
    "*.office.com",
    "https://*.office.com/*"
  ],
  "RestoreOnStartup": 4,
  "RestoreOnStartupURLs": [
    "https://client.wvd.microsoft.com/arm/webclient/index.html"
  ],
  "HomepageLocation": "https://client.wvd.microsoft.com/arm/webclient/index.html",
  "HomepageIsNewTabPage": false,
  "ShowHomeButton": true,
  "DefaultBrowserSettingEnabled": false,
  "DeveloperToolsAvailability": 2,
  "PasswordManagerEnabled": true,
  "BookmarkBarEnabled": false,
  "InPrivateModeAvailability": 1,
  "BrowserSignin": 0,
  "SyncDisabled": true,
  "MetricsReportingEnabled": false,
  "SpellcheckEnabled": true,
  "AudioCaptureAllowed": true,
  "AudioCaptureAllowedUrls": [
    "https://client.wvd.microsoft.com",
    "https://*.wvd.microsoft.com"
  ],
  "VideoCaptureAllowed": true,
  "VideoCaptureAllowedUrls": [
    "https://client.wvd.microsoft.com",
    "https://*.wvd.microsoft.com"
  ],
  "DefaultPopupsSetting": 2,
  "PopupsAllowedForUrls": [
    "https://client.wvd.microsoft.com",
    "https://*.wvd.microsoft.com",
    "https://login.microsoftonline.com",
    "https://*.login.microsoftonline.com",
    "https://login.microsoft.com",
    "https://*.microsoft.com"
  ],
  "DefaultNotificationsSetting": 2,
  "NotificationsAllowedForUrls": [
    "https://client.wvd.microsoft.com",
    "https://*.wvd.microsoft.com"
  ],
  "DefaultMediaStreamSetting": 1
}
EOF

# Create AVD Web Client desktop launcher for Edge
mkdir -p /usr/share/applications

tee /usr/share/applications/avd-webclient-edge.desktop > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=AVD Web Client (Edge)
Comment=Azure Virtual Desktop Web Client via Microsoft Edge
Exec=/usr/bin/microsoft-edge-stable --no-first-run https://client.wvd.microsoft.com/arm/webclient/index.html
Icon=microsoft-edge
Terminal=false
Categories=Network;RemoteAccess;
StartupNotify=true
StartupWMClass=Microsoft-edge
EOF

chmod 644 /usr/share/applications/avd-webclient-edge.desktop

# Update desktop database to make the launcher immediately available
update-desktop-database /usr/share/applications 2>/dev/null || true

# Configure Edge to load SafeNet smart card module
echo "=== Configuring Edge security modules ==="

# Edge uses the system-wide NSS database, not a browser-specific profile
# Create NSS database directory for kiosk user
mkdir -p /home/kiosk/.pki/nssdb

# Initialize the NSS database if it doesn't exist
if [ ! -f /home/kiosk/.pki/nssdb/cert9.db ]; then
    certutil -N -d sql:/home/kiosk/.pki/nssdb --empty-password
fi

# Load the SafeNet PKCS#11 module into the system NSS database
echo "Loading SafeNet module into system NSS database: /home/kiosk/.pki/nssdb"
modutil -dbdir sql:/home/kiosk/.pki/nssdb -add "SafeNet Authentication Client" -libfile /usr/lib/libeToken.so -force 2>&1 || true

# Set ownership
chown -R kiosk:kiosk /home/kiosk/.pki

echo "Edge smart card module configured (libeToken.so)"

# Set proper permissions
chmod 644 /etc/opt/edge/policies/managed/managed.json

# Also create a copy in the alternative location if it exists
if [ -d /etc/microsoft-edge/policies/managed ]; then
    cp /etc/opt/edge/policies/managed/managed.json /etc/microsoft-edge/policies/managed/managed.json
    chmod 644 /etc/microsoft-edge/policies/managed/managed.json
fi

echo "Microsoft Edge configured for AVD Web Client kiosk mode"
echo "URL restrictions applied - only Microsoft AVD domains allowed"
echo "Desktop launcher created: avd-webclient-edge.desktop"
