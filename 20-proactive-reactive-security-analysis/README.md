# Lab 20: Performing Proactive and Reactive Security Analysis

<p align="left">
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/redhat/redhat-original.svg" alt="Red Hat" width="40" height="40"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/linux/linux-original.svg" alt="Linux" width="40" height="40"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/bash/bash-original.svg" alt="Bash" width="40" height="40"/>
</p>

## 📌 Executive Summary

This project establishes a comprehensive, multi-layered security analysis architecture on **Red Hat Enterprise Linux (RHEL) / CentOS Stream**. Combining low-level system call auditing via `auditctl`, log correlation across `journalctl` and `/var/log/*`, custom Bash analysis daemons, and automated threat response procedures, this setup provides both **proactive monitoring** (early detection of unauthorized file access and system tampering) and **reactive incident response** (automated IP evaluation, privilege escalation detection, and persistent rule enforcement).

---

## 🏗️ Architecture & Monitoring Strategy

The monitoring framework is divided into three core operational layers:

| Layer | Subsystem / Tools | Key Responsibilities |
| :--- | :--- | :--- |
| **Kernel Audit Subsystem** | `auditd`, `auditctl`, `augenrules` | Real-time tracking of file system access (`/etc/passwd`, `/etc/shadow`), system call invocation (`setuid`, `execve`), network sockets, and execution attempts. |
| **Log Inspection & Correlation** | `ausearch`, `aureport`, `journalctl`, `/var/log/secure` | Querying structured audit logs and systemd journal events to extract auth failures, root escalations, and system errors. |
| **Automated Response & Persistence** | Custom Bash Scripts (`scripts/`), `/etc/audit/rules.d/` | Continuous background monitoring, threat analysis, daily summary generation, and persistent rule loading across reboots. |

---

## 🛡️ Key Configurations & Scripts

### 1. Persistent Security Audit Rules (`/etc/audit/rules.d/security-monitoring.rules`)

Custom audit rules written to track sensitive configuration files, privilege escalation system calls, process executions, network connections, and time alterations:

```text
# Security Monitoring Rules
# File access monitoring
-w /etc/passwd -p rwxa -k passwd_changes
-w /etc/shadow -p rwxa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/ssh/sshd_config -p wa -k ssh_config_changes
-w /etc/hosts -p wa -k hosts_changes
-w /tmp -p wa -k tmp_activity

# Process monitoring
-w /bin/su -p x -k su_usage
-w /usr/bin/sudo -p x -k sudo_execution

# System call monitoring
-a always,exit -F arch=b64 -S setuid -S setgid -S setreuid -S setregid -k privilege_escalation
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -k file_deletion
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -k permission_changes
-a always,exit -F arch=b64 -S execve -k process_execution

# Network monitoring
-a always,exit -F arch=b64 -S socket -S connect -S accept -k network_activity

# Time change monitoring
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time_change
```

### 2. Automated Script Suite (`scripts/`)

* **`security_analysis.sh`**: Aggregates `ausearch` statistics for authentication failures, privilege escalations, file deletions, and sudo usage.
* **`log_analyzer.sh`**: Evaluates system security logs (`/var/log/secure`, `/var/log/messages`) and identifies root access attempts.
* **`threat_response.sh`**: Scans `journalctl` for brute-force SSH candidates, validates file integrity, and flags privilege escalation attempts.
* **`security_monitor.sh`**: Continuous monitoring daemon evaluating system activity against thresholds and logging alerts to `/var/log/security_monitor.log`.
* **`daily_security_report.sh`**: Compiles comprehensive daily health, authentication, disk usage, and audit metrics into `/tmp/daily_security_report_YYYYMMDD.txt`.

---

## 🔬 Audit Verification & Workflow Evidence

### 1. Active Audit Rules & Initial Security Analysis Execution

Loading active kernel watch keys (`passwd_changes`, `shadow_changes`, `privilege_escalation`) and running the automated `security_analysis.sh` audit tool.

![Active Audit Rules and Security Analysis](assets/auditctl_rules_and_analysis_output.png)

### 2. Deep Inspection of Critical File Access (`/etc/shadow`)

Detailed audit record correlation using `ausearch -k shadow_changes`, tracking non-interactive process calls (`unix_chkpwd`) and elevated `sudo` invocations accessing shadow credentials.

![Ausearch Detailed Audit Log Analysis](assets/ausearch_shadow_changes_detail.png)

### 3. Multi-Log Security Inspection (`log_analyzer.sh`)

Automated scanning across `/var/log/secure` and system message logs to detect root session openings, command executions, and log rotation states.

![Comprehensive Log Analyzer Output](assets/log_analyzer_execution.png)

### 4. Threat Detection & Response (`threat_response.sh`)

Execution of real-time threat response routines flagging privilege escalation system calls and tracking modifications to sensitive files (`/etc/passwd`).

![Automated Threat Response Execution](assets/threat_response_execution.png)

### 5. Persistent Rules Rule-Set Reload & Verification

Applying persistent rules using `augenrules --load` and verifying active kernel-level monitoring rules via `auditctl -l`.

![Persistent Rules Reload and Verification](assets/persistent_augenrules_verification.png)

---

## 🎯 Conclusion

Lab 20 successfully demonstrates an enterprise-ready security auditing and threat analysis pipeline on RHEL/CentOS Stream. By establishing granular file watches, system call monitoring, automated log parsing, continuous background daemons, and persistent configuration management via `augenrules`, the target environment achieves robust alignment with standard Linux security benchmarks (such as CIS Controls and DISA STIG guidelines).