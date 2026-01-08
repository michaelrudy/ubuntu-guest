# Root CA
mkdir -p /tmp/test_certs/{Trusted\ Root\ Certification\ Authorities,Intermediate\ Certification\ Authorities,Personal,Trusted\ Publishers,Untrusted\ Certificates}

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/test_certs/Trusted\ Root\ Certification\ Authorities/test-root.key \
  -out /tmp/test_certs/Trusted\ Root\ Certification\ Authorities/test-root.crt \
  -subj "/CN=Test Root CA"


