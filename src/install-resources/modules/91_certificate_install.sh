#!/usr/bin/env bash
set -e

echo "=== Installing System Certificates from Mounted Location ==="

CERTS_PATH="${1:-/mnt/certs}"

# Check if the certificates path exists
if [ ! -d "$CERTS_PATH" ]; then
    echo "Warning: Certificate path does not exist: $CERTS_PATH"
    echo "Skipping certificate installation"
    exit 0
fi

# Function to convert certificate to PEM format if needed
convert_to_pem() {
    local cert_file="$1"
    local temp_pem="/tmp/$(basename "$cert_file" | sed 's/\.[^.]*$//')_converted.pem"
    
    if [[ "$cert_file" == *.der || "$cert_file" == *.cer ]]; then
        # Convert DER to PEM
        openssl x509 -inform DER -in "$cert_file" -out "$temp_pem" 2>/dev/null || return 1
    elif [[ "$cert_file" == *.pfx || "$cert_file" == *.p12 ]]; then
        # Extract certificate from PKCS#12 (requires password, skip if fails)
        openssl pkcs12 -in "$cert_file" -nokeys -out "$temp_pem" -passin pass: 2>/dev/null || return 1
    else
        # Assume it's already PEM or CRT
        cp "$cert_file" "$temp_pem"
    fi
    
    echo "$temp_pem"
}

# Function to install certificate to system CA store
install_system_ca() {
    local cert_file="$1"
    local cert_name=$(basename "$cert_file" | sed 's/\.[^.]*$//')
    
    echo "Installing system CA: $cert_file"
    
    # Copy to system CA directory
    cp "$cert_file" "/usr/local/share/ca-certificates/${cert_name}.crt"
    chmod 644 "/usr/local/share/ca-certificates/${cert_name}.crt"
}

# Function to install certificate to NSS database (for browsers)
install_nss_cert() {
    local cert_file="$1"
    local cert_name=$(basename "$cert_file" | sed 's/\.[^.]*$//')
    local nss_db="sql:/root/.pki/nssdb"
    
    echo "Installing certificate to NSS database: $cert_file"
    
    # Create NSS database directory if it doesn't exist
    mkdir -p /root/.pki/nssdb
    
    # Initialize the NSS database if it doesn't exist
    if [ ! -f /root/.pki/nssdb/cert9.db ]; then
        certutil -N -d "$nss_db" --empty-password 2>/dev/null || true
    fi
    
    # Import certificate to NSS database
    certutil -d "$nss_db" -A -t "C,," -n "$cert_name" -i "$cert_file" 2>/dev/null || true
}

# Process certificates from each category
echo "Scanning certificate directories in $CERTS_PATH"

# Iterate through certificate store directories
for store_dir in "$CERTS_PATH"/*; do
    if [ ! -d "$store_dir" ]; then
        continue
    fi
    
    store_name=$(basename "$store_dir")
    echo ""
    echo "Processing store: $store_name"
    
    # Map store names to installation targets
    case "$store_name" in
        "Trusted Root Certification Authorities")
            echo "Installing as system root CAs"
            find "$store_dir" -type f \( -name "*.cer" -o -name "*.crt" -o -name "*.pem" -o -name "*.der" \) | while read -r cert_file; do
                pem_file=$(convert_to_pem "$cert_file")
                if [ -f "$pem_file" ]; then
                    install_system_ca "$pem_file"
                    rm -f "$pem_file"
                fi
            done
            ;;
        
        "Intermediate Certification Authorities")
            echo "Installing as system intermediate CAs"
            find "$store_dir" -type f \( -name "*.cer" -o -name "*.crt" -o -name "*.pem" -o -name "*.der" \) | while read -r cert_file; do
                pem_file=$(convert_to_pem "$cert_file")
                if [ -f "$pem_file" ]; then
                    install_system_ca "$pem_file"
                    rm -f "$pem_file"
                fi
            done
            ;;
        
        "Personal")
            echo "Installing personal/device certificates to system and NSS"
            find "$store_dir" -type f \( -name "*.cer" -o -name "*.crt" -o -name "*.pem" -o -name "*.der" \) | while read -r cert_file; do
                pem_file=$(convert_to_pem "$cert_file")
                if [ -f "$pem_file" ]; then
                    install_system_ca "$pem_file"
                    install_nss_cert "$pem_file"
                    rm -f "$pem_file"
                fi
            done
            ;;
        
        "Trusted Publishers")
            echo "Installing as trusted publisher certificates"
            find "$store_dir" -type f \( -name "*.cer" -o -name "*.crt" -o -name "*.pem" -o -name "*.der" \) | while read -r cert_file; do
                pem_file=$(convert_to_pem "$cert_file")
                if [ -f "$pem_file" ]; then
                    install_system_ca "$pem_file"
                    rm -f "$pem_file"
                fi
            done
            ;;
        
        "Untrusted Certificates")
            echo "Skipping untrusted certificates (manual review recommended)"
            ;;
        
        *)
            echo "Unknown certificate store: $store_name (skipping)"
            ;;
    esac
done

# Update the system certificate database
echo ""
echo "Updating system certificate database..."
update-ca-certificates --fresh 2>/dev/null || true

# Verify installation
cert_count=$(find /usr/local/share/ca-certificates -name "*.crt" 2>/dev/null | wc -l)
echo ""
echo "Certificate installation complete"
echo "Total certificates installed to system store: $cert_count"

# Optional: Update NSS database for all users if kiosk user exists
if id "kiosk" &>/dev/null; then
    echo ""
    echo "Installing certificates for kiosk user NSS database..."
    
    kiosk_nss_db="sql:/home/kiosk/.pki/nssdb"
    mkdir -p /home/kiosk/.pki/nssdb
    
    if [ ! -f /home/kiosk/.pki/nssdb/cert9.db ]; then
        certutil -N -d "$kiosk_nss_db" --empty-password 2>/dev/null || true
    fi
    
    # Install all root and intermediate CAs to kiosk NSS database
    for cert_file in /usr/local/share/ca-certificates/*.crt; do
        if [ -f "$cert_file" ]; then
            cert_name=$(basename "$cert_file" | sed 's/\.[^.]*$//')
            certutil -d "$kiosk_nss_db" -A -t "C,," -n "$cert_name" -i "$cert_file" 2>/dev/null || true
        fi
    done
    
    chown -R kiosk:kiosk /home/kiosk/.pki
    echo "Kiosk user NSS database updated"
fi

echo "=== System Certificate Installation Complete ==="
