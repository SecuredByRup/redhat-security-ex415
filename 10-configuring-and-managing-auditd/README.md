# Lab 10: Configuring and Managing Auditd

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Red Hat](https://img.shields.io/badge/Red_Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

## Executive Summary

This lab focuses on installing, configuring, and managing the Linux Audit Subsystem (`auditd`) on an Enterprise Linux system. The primary goal is to establish comprehensive security monitoring, track system call events, enforce file access accountability, and automate forensic report generation in alignment with security compliance standards (e.g., PCI-DSS, HIPAA, SOX).

## Lab Objectives & Key Technical Implementations

1. **Audit Daemon Installation & System Tuning (`/etc/audit/auditd.conf`)**
   * Installed and verified the core `audit` and `audit-libs` packages.
   * Configured storage, rotation, and disk actions in `auditd.conf`:
     * `max_log_file = 50` (MB limit per log file)
     * `num_logs = 10` (Log rotation history retention)
     * `space_left_action = email` & `disk_full_action = suspend`
     * `log_format = RAW` & `flush = incremental_async`
   * Enabled and verified the `auditd` service using `systemctl enable --now auditd`.

2. **Custom Rule Creation & Immutability (`/etc/audit/rules.d/custom.rules`)**
   * **File Monitoring Watches (`-w`):** Tracked modifications (`wa`) on critical files (`/etc/passwd`, `/etc/shadow`, `/etc/group`, `/etc/sudoers`, `/etc/ssh/sshd_config`, `/var/log`).
   * **System Call Rules (`-a`):** Tracked file deletion (`unlink`, `rename`), permission changes (`chmod`), ownership changes (`chown`), and process execution (`execve`).
   * **Persistence & Security Hardening:** Implemented custom rules under `/etc/audit/rules.d/custom.rules` and enforced configuration immutability using `-e 2` (preventing runtime rule alterations without a reboot).

3. **Log Analysis & Automated Security Reporting (`ausearch`, `aureport`)**
   * Executed queries using `ausearch` to filter events by key name (`-k`), user ID (`-ua`), and failed logins (`-m USER_LOGIN --success no`).
   * Generated structured summary reports using `aureport` for authentication (`-au`), file accesses (`-f`), and failed logins (`-l --failed`).
   * Engineered an automated daily analysis script (`audit_analysis.sh`) to aggregate critical system events into timestamped reports stored under `~/audit_reports/`.

---

## Technical Verification & Screenshot Evidence

### 1. Kernel Rule Configuration & Immutability Enforcement
Resolved active rule conflicts using `auditctl -D` and loaded the persistent rule set from `/etc/audit/rules.d/custom.rules`. Verified active watches, system call triggers, and kernel immutability (`enabled 2`).

![Auditctl Rule Configuration](lab10-auditctl-rule-configuration.png)
*Figure 1: Clearing active rules, reloading persistent custom rules, verifying kernel status (`enabled 2`), and listing active rule watches.*

### 2. Audit Log Filtering & Security Querying
Utilized `ausearch` to inspect failed login attempts (`USER_LOGIN --success no`) and identify suspicious access attempts recorded by the audit subsystem.

![Ausearch Log Filtering](lab10-ausearch-log-filtering.png)
*Figure 2: Querying failed authentication attempts using `ausearch`.*

### 3. Service Verification & Subsystem Health Check
Verified that `auditd.service` is active (`running`) and checked kernel backlog status via `auditctl -s`.

![Auditd Service and Rule Status](lab10-auditd-service-and-rule-status.png)
*Figure 3: Inspecting systemd service state, active rule lists, and backlog status.*

### 4. Automated Daily Audit Analysis Execution
Executed `audit_analysis.sh` to extract system summaries, authentication events, failed logins, and file access patterns.

![Automated Audit Analysis Report](lab10-automated-audit-analysis-report.png)
*Figure 4: Executing the custom audit analysis script and viewing the generated daily report header.*

---

## Conclusion

By configuring `auditd`, defining persistent file and system call monitoring rules, locking down configuration immutability, and automating report generation, the system maintains strong security auditability. The environment is now equipped for real-time tracking, compliance enforcement, and forensic investigation.