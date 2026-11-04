# Lab 8: Configuring Firewall with `firewalld`

![Red Hat Enterprise Linux](https://img.shields.io/badge/RHEL-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Firewalld](https://img.shields.io/badge/firewalld-Shield-blue?style=for-the-badge&logo=linux&logoColor=white)
![Linux Shell](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Network Testing](https://img.shields.io/badge/Nmap%20%2F%20Netcat-00599C?style=for-the-badge&logo=linux&logoColor=white)

---

## 📌 Executive Summary & Objectives

This lab focuses on configuring, managing, and validating host-based network security controls on Red Hat Enterprise Linux (RHEL 9) using `firewalld`. By utilizing a zone-based architecture, Network Address Translation (NAT) masquerading, port forwarding, and rich logging rules, the system was hardened against unauthorized traffic while allowing legitimate service communications.

### Core Technical Objectives
- **Zone Architecture & Management:** Explore default and custom firewall zones, interface bindings, and service rules.
- **NAT & Port Redirection:** Enable masquerading and configure port forwarding rules (e.g., port `8080` $\rightarrow$ `80`).
- **Rule Verification & Testing:** Validate active rules using diagnostic tools (`nmap`, `nc`, `curl`, `telnet`).
- **Security Auditing & Logging:** Implement rich rules with custom log prefixes (`SSH-ACCESS: `) for monitoring connection attempts via system logs.

---

## 🛠 Lab Tasks & Technical Implementation

### Task 1: Zone Setup & Custom Zone Configuration
1. Checked default active zones and identified system network interface bindings (`ens5`).
2. Created a custom permanent firewall zone named `lab-zone`:
   ```bash
   sudo firewall-cmd --permanent --new-zone=lab-zone
   sudo firewall-cmd --reload
   ```
3. Bound essential services (`http`, `ssh`) and custom TCP ports (`8080/tcp`) to `lab-zone`:
   ```bash
   sudo firewall-cmd --zone=lab-zone --add-service=ssh --permanent
   sudo firewall-cmd --zone=lab-zone --add-service=http --permanent
   sudo firewall-cmd --zone=lab-zone --add-port=8080/tcp --permanent
   sudo firewall-cmd --reload
   ```

---

### Task 2: Masquerading & Port Forwarding
1. Enabled Network Address Translation (NAT) masquerading on the `public` zone:
   ```bash
   sudo firewall-cmd --zone=public --add-masquerade --permanent
   ```
2. Configured local port redirection from port `8080` to port `80`:
   ```bash
   sudo firewall-cmd --zone=public --add-forward-port=port=8080:proto=tcp:toport=80 --permanent
   ```
3. Defined IPv4 source-restricted rich rules for granular network access and routing control:
   ```bash
   sudo firewall-cmd --zone=public --add-rich-rule='rule family=ipv4 source address=172.31.10.20/24 forward-port port=9090 protocol=tcp to-port=80' --permanent
   sudo firewall-cmd --zone=public --add-rich-rule='rule family=ipv4 source address=172.31.10.30/24 masquerade' --permanent
   ```

---

### Task 3: Testing, Verification & Logging
1. Deployed a lightweight HTTP test server using Python:
   ```bash
   sudo mkdir -p /var/www/html
   echo '<h1>Test Web Server</h1><p>Port forwarding test successful!</p>' | sudo tee /var/www/html/index.html
   sudo python3 -m http.server 80 --directory /var/www/html &
   ```
2. Tested active endpoints using `curl` and `nmap`:
   ```bash
   curl http://localhost:80
   nmap localhost
   ```
3. Applied rich rule logging to track incoming SSH access attempts:
   ```bash
   sudo firewall-cmd --zone=public --add-rich-rule='rule service name="ssh" log prefix="SSH-ACCESS: " level="info" accept' --permanent
   sudo firewall-cmd --reload
   ```

---

## 🖼 Verification & Visual Proof

### Suggested Image File Renaming Scheme
To maintain clean project organization, please rename your raw screenshots as follows before adding them to your repository:

| Original File Name | New Recommended File Name | Description |
| :--- | :--- | :--- |
| `Screenshot (787).png` | `01_firewalld_zones_and_nmap_verification.png` | Zone configuration inspection (`lab-zone`, `public`), web server verification, and Nmap scan output. |
| `Screenshot (788).png` | `02_ssh_rich_rule_logging_setup.png` | Setting up and reloading `SSH-ACCESS` rich logging rule in `firewalld`. |

---

### 1. Firewall Zone Inspection & Network Service Scanning
Below is the verification of default and active zones, configuration parameters for `lab-zone` and `public` zones, local HTTP web server verification via `curl`, and port scanning using `nmap`.

![Firewalld Zones and Nmap Verification](./01_firewalld_zones_and_nmap_verification.png)

---

### 2. Rich Rule Creation & Logging Configuration
Below is the implementation and reloading of the custom SSH rich rule configured to prepend connection logs with the prefix `SSH-ACCESS: `.

![SSH Rich Rule Logging Setup](./02_ssh_rich_rule_logging_setup.png)

---

## 💡 Troubleshooting & Key Takeaways

1. **Loopback vs. Network Interface NAT Routing:**
   - Packet forwarding rules defined on `firewalld` process traffic traversing the `PREROUTING` chain on external network interfaces (`ens5`). Traffic originating and terminating strictly on loopback (`127.0.0.1` / `localhost`) bypasses interface NAT hooks, resulting in a *Connection refused* response unless tested across the actual interface IP (`172.31.10.20`) or configured via kernel flags (`net.ipv4.conf.all.route_localnet=1`).

2. **Bash History Expansion with Exclamation Marks:**
   - Attempting to pass string variables containing `!` using double quotes triggers Bash history expansion errors (`-bash: !: event not found`). Wrapping content in single quotes (`'...'`) avoids syntax errors.

3. **Service Listener Requirement:**
   - Opening firewall ports (`--add-port`) allows traffic past the packet filtering wall, but attempts to communicate return `Connection refused` unless a backend service process (such as Python's HTTP server or `sshd`) is actively bound and listening on that port.

---

## 🏁 Conclusion

Through Lab 8, hands-on experience was gained in designing and deploying host-based firewall policies using `firewalld` on Enterprise Linux. The tasks demonstrated how zone separation, masquerading, port forwarding, and rich rule logging protect system resources while providing precise traffic management across enterprise environments.