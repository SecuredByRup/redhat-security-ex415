# Advanced SELinux Troubleshooting & Custom Apache Configuration Lab

<p align="left">
  <img src="https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat" />
  <img src="https://img.shields.io/badge/Apache%20HTTP%20Server-D22128?style=for-the-badge&logo=apache&logoColor=white" alt="Apache" />
  <img src="https://img.shields.io/badge/SELinux-Security-blue?style=for-the-badge&logo=linux&logoColor=white" alt="SELinux" />
  <img src="https://img.shields.io/badge/RHEL%209-Enterprise-success?style=for-the-badge&logo=redhat&logoColor=white" alt="RHEL 9" />
</p>

## Overview

This repository documents **Lab 5: Advanced SELinux Troubleshooting and Custom Apache Configuration**, executed on a **Red Hat Enterprise Linux (RHEL 9)** environment (`httpd-2.4.62-17.el9.x86_64`). The lab focuses on enterprise-grade Linux security enforcement, resolving Access Vector Cache (AVC) denials, compiling custom SELinux security modules, managing file contexts for non-standard web directories, and real-time monitoring.

---

## Lab Objectives & Key Tasks

1. **Custom Port Binding & SELinux Enforcement:** Configured Apache HTTP Server to bind to a non-standard port (`12345`) and captured the resulting SELinux AVC denial.
2. **Policy Generation (`audit2allow`):** Analyzed audit logs using `ausearch` and `sealert`, then generated, compiled, and installed a custom SELinux policy module (`myhttpd.pp`) to permit the port binding.
3. **Advanced Troubleshooting (`DocumentRoot` & File Contexts):** Deployed a custom web directory (`/custom-web`), diagnosed subsequent SELinux file-context blocks, and applied appropriate labeling (`httpd_sys_content_t`) using `semanage fcontext` and `restorecon`.
4. **Real-Time Monitoring & Validation:** Monitored audit logs live (`tail -f` and `journalctl`) and verified successful HTTP access (`HTTP 200`) using `curl`.

---

## Implementation & Execution Workflow

### 1. Diagnosing & Fixing Port Binding Denials
When Apache attempts to bind to unreserved ports (e.g., port `12345`), SELinux Enforcing mode blocks the action by default:
```bash
systemctl restart httpd
grep "AVC" /var/log/audit/audit.log | tail -5
```

### 2. Generating & Installing Custom Policy Modules
Using audit tools to translate denials into allow rules and compiling them into a policy package:
```bash
grep httpd /var/log/audit/audit.log | audit2allow -M myhttpd
semodule -i myhttpd.pp
semodule -l | grep myhttpd
```

### 3. Configuring Custom `DocumentRoot` & File Contexts
Moving web content outside default directories (`/var/www/html`) requires explicit context labeling:
```bash
mkdir /custom-web
echo "<h1>Custom Web Content</h1>" > /custom-web/index.html
semanage fcontext -a -t httpd_sys_content_t "/custom-web(/.*)?"
restorecon -R /custom-web/
```

---

## Verification & Final Evidence

The screenshot below validates the complete deployment, confirming active policy modules, correct file security contexts, enforcing status, active Apache service threads, and successful HTTP validation:

![SELinux & Apache Verification](selinux-apache-custom-port-context-verification.png)

> **Note on Screenshot Renaming:** The original attached image (`Screenshot (779).png`) has been professionally renamed to **`selinux-apache-custom-port-context-verification.png`** to clearly describe its contents for portfolio presentation. It captures module verification (`semodule -l`), file context inspection (`ls -Zd`), SELinux enforcing status (`getenforce`), active service status (`systemctl status httpd`), and curl/access log verification showing successful `HTTP 200` responses.

---

## Conclusion

This lab successfully demonstrates mastery over Linux Security-Enhanced Linux (SELinux) mechanisms in enterprise environments. By moving beyond disabling security controls and instead mastering policy generation (`audit2allow`) and context management (`semanage`, `restorecon`), services like Apache can be securely deployed on custom ports and directories while maintaining strict compliance with mandatory access control (MAC) policies.