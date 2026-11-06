# Lab 14: Intrusion Detection with AIDE

![Red Hat Enterprise Linux](https://img.shields.io/badge/RHEL-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS](https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash Shell](https://img.shields.io/badge/Bash_Shell-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Systemd](https://img.shields.io/badge/Systemd-000000?style=for-the-badge&logo=systemd&logoColor=white)
![JSON](https://img.shields.io/badge/SIEM_JSON-000000?style=for-the-badge&logo=json&logoColor=white)

---

## 📌 Executive Summary

This lab demonstrates the implementation of **File Integrity Monitoring (FIM)** and **Host-Based Intrusion Detection (HIDS)** using **AIDE (Advanced Intrusion Detection Environment)** on Red Hat Enterprise Linux / CentOS environments. 

The lab covers custom baseline configuration, resolution of legacy syntax warnings, simulation of multi-vector security incidents (content tampering, permission escalation, file deletions, unauthorized additions, and binary trojanization), build-out of automated monitoring scripts, SIEM JSON log exporters, and automated scheduling via `systemd` timers.

---

## 🛠️ Key Technologies & Tools

* **Intrusion Detection System:** AIDE 0.19.2 (Advanced Intrusion Detection Environment)
* **Operating System:** Red Hat Enterprise Linux / CentOS 9 (`x86_64`)
* **Cryptographic Hashing:** SHA-256, SHA-512, MD5, Argon2id
* **Automation & Orchestration:** Bash Shell Scripting, Cron, Systemd (`.service` & `.timer`)
* **Data Interchange & SIEM Integration:** JSON Output Generation, Web Dashboard (HTML5/JS)

---

## 🚀 Implementation Workflow & Execution Steps

### Task 1: Package Installation & Custom Configuration Tuning
1. Installed the `aide` package via `dnf` and verified version binary specs.
2. Formatted `/etc/aide.conf` using modern URI schemes (`database_in=file:///...`, `database_out=file:///...`) and updated deprecated growth attributes from `S` to `growing+s`.
3. Created secure database and log directories (`/var/lib/aide`, `/var/log/aide`) with restrictive `0700` and `0755` permissions.

```bash
sudo dnf install aide -y
sudo aide --config-check
```

### Task 2: Baseline Initialization & Incident Simulation
1. Generated the cryptographic baseline database (`aide --init`) and deployed it to the active path (`aide.db.gz`).
2. Configured custom surveillance rules for `/opt/test-aide/` and re-initialized the baseline.
3. Executed security incident simulations:
   * **Content Modification:** Altered content in `testfile1.txt`.
   * **Permission Escalation:** Changed `testfile2.txt` to `777`.
   * **File Deletion:** Removed `testfile3.txt`.
   * **Unauthorized File Addition:** Created `suspicious-file.txt`.
   * **Binary Replacement:** Replaced `/opt/test-aide/test-binary` with `/bin/cat`.

### Task 3: Automation Pipeline, SIEM Export & Dashboard
1. Developed `/usr/local/bin/aide-report-parser.sh` to extract modified, added, and removed entries.
2. Built `/usr/local/bin/aide-monitor.sh` with automated log rotation, threshold alerting, and database maintenance capabilities.
3. Implemented `/usr/local/bin/aide-siem-export.sh` to format detection reports into structured JSON for SIEM ingestion.
4. Created a `systemd` timer (`aide-monitor.timer`) and service (`aide-monitor.service`) to enforce daily persistent checks.

---

## 📸 Lab Execution Evidence

### 1. AIDE Configuration & Rule Definition
*Custom rule aliases (`Binlib`, `ConfFiles`, `Logs`) and surveillance targets configured in `/etc/aide.conf`.*
![AIDE Configuration](screenshots/01-aide-configuration.png)

### 2. Syntax Validation & URI Schema Fix
*Resolving URI format requirements (`file:///`) and permissions setup for AIDE directories.*
![Config Validation](screenshots/02-config-validation-fix.png)

### 3. Baseline Database Initialization & Clean Scan
*Running `aide --init`, inspecting generated SHA-256/SHA-512 database hashes, and verifying initial baseline cleanliness.*
![Database Initialization](screenshots/03-database-initialization.png)

### 4. Test Environment Provisioning
*Creating `/opt/test-aide/` artifacts using `echo | sudo tee` and registering the path in `/etc/aide.conf`.*
![Test Environment Setup](screenshots/04-test-environment-setup.png)

### 5. Detection: File Content Modification
*AIDE identifying unauthorized text alterations in `testfile1.txt` through MD5 and SHA-256 hash mismatches.*
![Content Modification Detection](screenshots/05-content-modification-detection.png)

### 6. Detection: Permission Escalation
*Detecting privilege shifts (`-rwxrwxrwx`) on `testfile2.txt`.*
![Permission Escalation Detection](screenshots/06-permission-change-detection.png)

### 7. Detection: File Deletion
*Identifying missing objects (`testfile3.txt`) and directory metadata updates.*
![File Deletion Detection](screenshots/07-file-deletion-detection.png)

### 8. Detection: Unauthorized File Creation
*Identifying untracked files (`suspicious-file.txt`) added to protected directories.*
![Unauthorized File Addition](screenshots/08-unauthorized-file-addition.png)

### 9. Detection: Binary Replacement & Trojanization
*Detecting binary replacement where `/bin/ls` was replaced with `/bin/cat`, flagging size and hash shifts.*
![Binary Replacement Detection](screenshots/09-binary-replacement-detection.png)

### 10. Audit Logging & Report Redirection
*Capturing check output into `/tmp/aide-report.txt` for automated parsing and security reporting.*
![Report Redirection Analysis](screenshots/10-report-redirection-analysis.png)

---

## 🔒 Security Best Practices Implemented

1. **Non-Interactive Root File Writing:** Executed `echo "..." | sudo tee` redirection to avoid permissions issues while operating in root-protected directories.
2. **Least Privilege Data Protection:** Restricted access to `/var/lib/aide` (`0700`) to prevent unauthorized database tampering.
3. **Automated SIEM Standardization:** Exported security events to JSON for correlation with central SIEM solutions (Splunk, Elastic / ELK).
4. **Persistent Task Scheduling:** Deployed `systemd` timers with randomized delay offsets (`RandomizedDelaySec=1800`) to prevent resource contention during integrity scans.

---

## 🎯 Conclusion

Lab 14 demonstrates the end-to-end implementation of Host-Based Intrusion Detection and File Integrity Monitoring using AIDE on Enterprise Linux. By combining tuned cryptographic inspection, rule aliases, automated shell parsing, SIEM JSON data generation, and scheduled `systemd` timers, this architecture provides continuous monitoring for critical system binaries and configuration paths, meeting compliance standards such as PCI-DSS, NIST SP 800-53, and ISO 27001.