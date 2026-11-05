# Lab 15: Implementing Network Security with SELinux

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat%20Enterprise%20Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![SELinux](https://img.shields.io/badge/SELinux-Kernel%20MAC-blue?style=for-the-badge&logo=linux&logoColor=white)
![Apache HTTP Server](https://img.shields.io/badge/Apache%20HTTP%20Server-D22128?style=for-the-badge&logo=apache&logoColor=white)
![Bash Scripting](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![OpenSSH](https://img.shields.io/badge/OpenSSH-000000?style=for-the-badge&logo=openbsd&logoColor=white)

## 📌 Executive Summary

This lab demonstrates the configuration, enforcement, and troubleshooting of **Security-Enhanced Linux (SELinux)** for network-facing services on enterprise Red Hat Enterprise Linux systems. 

The lab guides through mandatory access control (MAC) enforcement, analyzing Access Vector Cache (AVC) denials using `ausearch` and `sealert`, fixing path label mismatches using `semanage fcontext` and `restorecon`, re-binding Apache HTTP Server to non-standard TCP ports (`8080`), and adjusting kernel-level booleans (`httpd_can_network_connect`) for secure network operations.

## 🛠️ Key Technologies & Tools

* **Mandatory Access Control (MAC):** SELinux (Targeted Policy)
* **Policy & Context Management:** `semanage`, `restorecon`, `chcon`, `setsebool`, `getsebool`
* **Audit & Diagnostics:** `ausearch`, `sealert` (`setroubleshoot-server`), `/var/log/audit/audit.log`
* **Web & Network Services:** Apache HTTP Server (`httpd`), OpenSSH Server (`sshd`)
* **Operating System:** CentOS Stream 9 / RHEL 9 (`x86_64`)

---

## 🚀 Implementation Workflow & Execution Steps

### Task 1: SELinux Enforcement & Service Baseline
1. Verified SELinux mode (`getenforce`, `sestatus`) and confirmed persistent enforcement inside `/etc/selinux/config`.
2. Provisioned Apache HTTP Server (`httpd`), enabled systemd startup, and inspected runtime security context (`ps -eZ | grep httpd`).
3. Deployed default index pages under `/var/www/html/` and verified standard `httpd_sys_content_t` context inheritance.

```bash
# Check enforcement status
sestatus

# Verify process context for Apache
ps -eZ | grep httpd
```

### Task 2: Custom Directory Deployment & AVC Denial Troubleshooting
1. Created a non-standard web root `/custom-web/test.html` and configured an Apache Directory Alias inside `/etc/httpd/conf/httpd.conf`.
2. Attempted HTTP access via `curl`, triggering intentional 403/404 errors due to SELinux `default_t` context isolation.
3. Queried audit logs with `ausearch -m avc -ts recent` and generated human-readable diagnostic analysis using `sealert -a /var/log/audit/audit.log`.

```bash
# Query recent AVC denials
sudo ausearch -m avc -ts recent

# Run detailed setroubleshoot report
sudo sealert -a /var/log/audit/audit.log
```

### Task 3: Permanent Policy Customization, Port Binding & Booleans
1. Added permanent file context rules for `/custom-web(/.*)?` using `semanage fcontext` and applied them recursively using `restorecon -R`.
2. Reconfigured Apache to listen on non-standard port `8080` and registered TCP port `8080` to `http_port_t` using `semanage port`.
3. Adjusted network connection booleans (`httpd_can_network_connect` and `httpd_can_network_connect_db`) persistently with `setsebool -P`.
4. Performed complete functional verification via `curl http://localhost:8080/custom/test.html`.

```bash
# Permanent file context mapping
sudo semanage fcontext -a -t httpd_sys_content_t "/custom-web(/.*)?"
sudo restorecon -R /custom-web/

# Register non-standard port in SELinux policy
sudo semanage port -a -t http_port_t -p tcp 8080

# Configure persistent booleans
sudo setsebool -P httpd_can_network_connect on
```

---

## 📸 Lab Execution Evidence

### 1. SELinux Status Verification & Process Context Audit
![SELinux Status Verification](screenshots/01-selinux-status-and-initial-check.png)
*Confirming system enforcement mode (`SELINUX=enforcing`), inspecting `httpd_t` process domain context, and checking `/var/www/html/` file context integrity.*

### 2. High-Level AVC Denial Analysis via `sealert`
![AVC Denial Overview](screenshots/02-sealert-avc-analysis-overview.png)
*Analyzing audit events with `sealert` to identify blocked `getattr` calls from `httpd_t` against `/custom-web/test.html`.*

### 3. Deep-Dive AVC Diagnostic & Remediation Guidance
![SEAlert Remediation Report](screenshots/03-sealert-remediation-details.png)
*Inspecting source context (`httpd_t`), target context (`default_t`), and recommended policy remediation commands.*

### 4. Enterprise Policy Mapping (`semanage`), Port Binding & Boolean Auditing
![Policy Modification & Port Binding](screenshots/04-semanage-fcontext-port-and-booleans.png)
*Applying permanent policy changes (`semanage fcontext`), relabeling path targets (`restorecon`), registering TCP port `8080` (`http_port_t`), and auditing HTTP booleans.*

### 5. Persistent Boolean Configuration & End-to-End Endpoint Verification
![Boolean Configuration and Functional Validation](screenshots/05-boolean-persistent-toggle-and-verification.png)
*Enabling `httpd_can_network_connect` persistently (`setsebool -P`), checking active systemd units, and validating clear HTTP response on port `8080`.*

---

## 🔒 Security Best Practices Implemented

1. **Mandatory Access Control Integrity:** Retained system-wide `Enforcing` mode throughout service deployment rather than degrading system protection to `Permissive` or `Disabled`.
2. **Persistent Context Mapping:** Used `semanage fcontext` alongside `restorecon` instead of temporary `chcon` modifications to guarantee policy persistence across file system relabeling operations (`fixfiles` / `touch /.autorelabel`).
3. **Explicit Port Authorization:** Registered non-standard service ports directly in the policy database using `semanage port`, preventing unauthorized process socket binding.
4. **Least-Privilege Boolean Tuning:** Toggled granular booleans (e.g., `httpd_can_network_connect`) with the `-P` flag to satisfy strict application network requirements without granting unnecessary administrative rights.

---

## 🎯 Conclusion

Lab 15 demonstrates the practical implementation of SELinux Mandatory Access Control for securing enterprise network services. By combining structured AVC log analysis, permanent file context mapping using `semanage`, non-standard port registration, and fine-grained boolean management, network services can be secured against unauthorized file system traversal and process compromise while maintaining high availability.