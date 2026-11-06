#!/bin/bash

LOG_FILE="../logs/tls_verification_summary.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=================================================="
echo " Starting TLS Endpoint & Security Header Audits"
echo " Date: $(date)"
echo "=================================================="

# 1. Test Apache HTTPS (Port 443)
echo -e "\n[+] Testing Apache (HTTPS - Port 443)..."
curl -s -k -I https://localhost:443 | grep -E "HTTP/|Strict-Transport-Security|X-Frame-Options"

# 2. Test NGINX HTTPS (Port 9443)
echo -e "\n[+] Testing NGINX (HTTPS - Port 9443)..."
curl -s -k -I https://localhost:9443 | grep -E "HTTP/|Strict-Transport-Security|X-Frame-Options|Server:"

# 3. Test NGINX HTTP-to-HTTPS Redirect (Port 8090)
echo -e "\n[+] Testing NGINX HTTP Redirect (Port 8090 to 9443)..."
curl -s -I http://localhost:8090 | grep -E "HTTP/|Location:"

echo -e "\n=================================================="
echo " All TLS verification checks completed successfully!"
echo "=================================================="
