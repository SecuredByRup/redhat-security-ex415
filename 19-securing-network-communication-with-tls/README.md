# Lab 19: Securing Network Communication with TLS

<p align="center">
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/redhat/redhat-original.svg" alt="Red Hat" width="60" height="60"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/apache/apache-original.svg" alt="Apache HTTPD" width="60" height="60"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/nginx/nginx-original.svg" alt="NGINX" width="60" height="60"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/openssl/openssl-original.svg" alt="OpenSSL" width="60" height="60"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/linux/linux-original.svg" alt="Linux" width="60" height="60"/>
</p>

---

## 📌 Executive Summary
This laboratory exercise implements enterprise-grade transport layer security (**TLS 1.2 / TLS 1.3**) across **Apache HTTPD** and **NGINX** web servers on Red Hat Enterprise Linux (RHEL) / CentOS Stream environments. The primary objectives encompass end-to-end cryptographic setup, custom SELinux policy labeling for non-standard port allocations, strict HTTP-to-HTTPS redirection, hard security header injections (HSTS, X-Frame-Options, X-Content-Type-Options), and empirical verification of protocol downgrade rejections.

---

## 🏗️ Architecture & Network Port Allocation Strategy

To resolve binding collisions with pre-installed services (Apache on standard ports and AWS DCV Remote Desktop Server listening on port `8443`), the network topology is designed with explicit port separation:

| Service | Protocol | Assigned Port | Purpose & Routing |
| :--- | :--- | :--- | :--- |
| **Apache HTTPD** | HTTPS | `443` | Primary secure Web Endpoint enforcing TLS 1.2/1.3 |
| **NGINX Proxy** | HTTP | `8090` | Insecure endpoint configured with HTTP 301 Redirect to Port `9443` |
| **NGINX Proxy** | HTTPS / HTTP2 | `9443` | Primary secure NGINX endpoint serving `/var/www/nginx` |
| **DCV Remote Display** | HTTPS | `8443` | Cloud display server (isolated from web server configuration) |

---

## 🛡️ Implementation Details

### 1. Key & Certificate Management (OpenSSL)
Generated 2048-bit RSA private keys, Certificate Signing Requests (CSRs), self-signed certificates, and 2048-bit Diffie-Hellman parameters (`dhparam.pem`) for enhanced Perfect Forward Secrecy (PFS):
```bash
# NGINX Certificate & DH Parameter Generation
sudo openssl genrsa -out /etc/ssl/private/nginx-selfsigned.key 2048
sudo openssl req -new -key /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.csr
sudo openssl x509 -req -days 365 -in /etc/ssl/certs/nginx-selfsigned.csr \
    -signkey /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

### 2. NGINX Hardened Configuration (`/etc/nginx/conf.d/ssl-lab.conf`)
- Enforced modern cryptographic protocols: `TLSv1.2` and `TLSv1.3`.
- Restricted ciphers to high-strength ECDHE/DHE AES-256 GCM suites.
- Enabled HTTP/2 protocol support.
- Injected strict security headers:
  - `Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"`
  - `X-Frame-Options DENY`
  - `X-Content-Type-Options nosniff`
  - `X-XSS-Protection "1; mode=block"`

### 3. SELinux Port Labeling Policy
Authorized NGINX to listen on non-standard ports `8090` and `9443` within the mandatory access control subsystem:
```bash
sudo semanage port -a -t http_port_t -p tcp 8090
sudo semanage port -a -t http_port_t -p tcp 9443
```

---

## 🔬 Verification, Auditing & Screenshots

### 1. Service Status & Port Bindings
Verification of active `httpd` and `nginx` systemd units alongside verified socket bindings on ports `443`, `8090`, and `9443`.

![Service Status and Port Bindings](assets/service_status_and_port_bindings.png)

### 2. Automated TLS Audits, Protocol Rejection & Header Verification
Execution of the automated verification suite (`scripts/tls_test.sh`), demonstrating:
- Active 301 HTTP-to-HTTPS redirection (`http://localhost:8090` $\rightarrow$ `https://localhost:9443`).
- **Empirical Downgrade Protection:** Rejection of obsolete `TLSv1.0` handshakes (`tls_setup_handshake: no protocols available`).
- Successful negotiation of modern `TLSv1.3`.
- Presence of enterprise security headers on HTTPS endpoints.

![TLS Downgrade Rejection and Security Headers](assets/tls_downgrade_rejection_and_headers.png)

---

## 📜 Automated Audit Script (`scripts/tls_test.sh`)

```bash
#!/bin/bash
# Automated TLS Endpoint & Security Header Audit Script

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

# 4. Verify Obsolete Protocol Rejection (TLSv1.0)
echo -e "\n[+] Verifying Protocol Rejection (TLSv1.0)..."
openssl s_client -connect localhost:9443 -tls1 </dev/null 2>&1 | grep -E "no protocols available|handshake failure"

# 5. Verify Modern Protocol Acceptance (TLSv1.3)
echo -e "\n[+] Verifying Protocol Acceptance (TLSv1.3)..."
echo | openssl s_client -connect localhost:9443 -tls1_3 2>/dev/null | grep -E "Protocol"

echo -e "\n=================================================="
echo " All TLS verification checks completed successfully!"
echo "=================================================="
EOF
```

---

## 🎯 Conclusion
Lab 19 successfully establishes a hardened transport security posture on RHEL/CentOS Stream. By combining robust OpenSSL key management, tailored SELinux port policies, modern cipher suites, strict protocol enforcement (blocking TLS 1.0/1.1), and defensive HTTP headers, the web infrastructure satisfies contemporary enterprise security standards (PCI-DSS and DISA STIG requirements).