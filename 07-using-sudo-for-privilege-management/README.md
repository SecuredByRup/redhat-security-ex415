# Lab 7: Using sudo for Privilege Management

[![Red Hat Enterprise Linux](https://img.shields.io/badge/OS-Red%20Hat%20Enterprise%20Linux-CC0000?style=flat&logo=redhat&logoColor=white)](https://www.redhat.com)
[![Linux Sudo](https://img.shields.io/badge/Security-Sudo%20Privilege%20Management-4E9A06?style=flat&logo=linux&logoColor=white)](https://www.sudo.ws)
[![Bash Shell](https://img.shields.io/badge/Shell-Bash Scripting-4EAA25?style=flat&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Rsyslog](https://img.shields.io/badge/Logging-Rsyslog-00599C?style=flat&logo=linux&logoColor=white)](https://www.rsyslog.com)
[![Git](https://img.shields.io/badge/VCS-Git-F05032?style=flat&logo=git&logoColor=white)](https://git-scm.com)

---

## 📋 Project Overview

This repository contains the configuration files, automated auditing scripts, and verification logs for **Lab 7: Using sudo for Privilege Management** under the Red Hat Certified Specialist in Security curriculum (`EX415`).

The objective of this project is to implement enterprise-grade privilege escalation controls using `sudo`, enforce the Principle of Least Privilege across organizational roles (`developers`, `operators`, `auditors`), establish enhanced logging (`/var/log/sudo.log`) via `rsyslog`, and automate security auditing and log rotation.

---

## 🏗️ System Architecture & Role-Based Rules

Administrative privileges are enforced via granular modular drop-in configuration files located in `/etc/sudoers.d/`:

* **`custom-rules` & `role-based-access`:**
  * **Developers (`%developers`, `alice`, `bob`):** Permitted to restart/check web services (`httpd`, `nginx`), view web logs, edit `/etc/hosts`, and access database binaries (`mysql`, `mysqldump`). Blacklisted from executing dangerous commands (`!/bin/su`, `!/usr/bin/passwd root`, `!/usr/sbin/visudo`).
  * **Operators (`%operators`, `charlie`):** Authorized for general system service lifecycle management (`systemctl *`), processes inspection (`top`, `htop`, `ps`), and storage operations (`mount`, `umount`, `fsck`).
  * **Auditors (`%auditors`, `diana`):** Granted passwordless read-only access (`NOPASSWD:`) to system logs (`/var/log/*`), active session utilities (`who`, `last`), and process structures (`ps aux`).
  * **Network Administrators (`NETADMINS` Alias):** Command group mapping (`NETWORKING`) covering routing, network interface, and firewall utilities (`route`, `ifconfig`, `ping`, `iptables`).

* **`logging-config`:**
  * Configured dedicated log storage (`logfile="/var/log/sudo.log"`), session input/output logging (`log_input`, `log_output` for sensitive users), syslog facility binding (`syslog=authpriv`), and audit tracking for both allowed and denied execution attempts.

---

## ⚙️ Repository Artifacts & Automation Scripts

The project scripts are organized inside the local workspace (`scripts/`):

* `custom-rules`: Modular `sudoers` rule file defining group permissions and command blacklists.
* `role-based-access`: Modular RBAC configuration mapping `Cmnd_Alias` sets to administrative personas.
* `logging-config`: Modular `sudoers` default directives defining audit logging parameters.
* `test_sudo.sh`: Automated privilege validation script testing allowed vs. denied command execution per user context.
* `generate_sudo_activity.sh`: Simulation harness generating valid and invalid `sudo` events for auditing.
* `analyze_sudo_logs.sh`: Custom parser analyzing `/var/log/sudo.log` and `/var/log/secure` for command frequencies and failed escalation attempts.
* `sudo_monitor.sh`: Real-time monitoring script auditing suspicious password changes and failed attempts.

---

## 📷 Verification Evidence & Screenshots

The screenshots are organized inside the `assets/` directory to document verification step-by-step:

### Phase 1: Syntax Validation & Least Privilege Enforcement
* **File:** `assets/01-sudoers-syntax-validation-and-least-privilege.png`

![Syntax Check & User Privileges](./assets/01-sudoers-syntax-validation-and-least-privilege.png)

* **Key Proof:** Demonstrates syntax verification (`visudo -c`) for custom rules and logging configs returning `parsed OK`. Confirms `alice`'s restricted command list (`sudo -l`), successful authorized execution (`sudo systemctl status httpd`), strict denial of unauthorized privilege escalation (`sudo passwd root`), and initial entries recorded in `/var/log/sudo.log`.

---

### Phase 2: Log Analysis & Command Frequency Breakdown
* **File:** `assets/02-sudo-command-frequency-and-log-analysis.png`

![Log Analysis Report](./assets/02-sudo-command-frequency-and-log-analysis.png)

* **Key Proof:** Shows execution of the automated audit script (`analyze_sudo_logs.sh`), breaking down invocation frequencies per user (`centos`, `root`, `alice`, `diana`, `charlie`, `bob`), tracing recent PAM session events, and flagging failed authentication attempts.

---

### Phase 3: Audit Log User Session Analysis
* **File:** `assets/03-sudo-unique-user-session-audit.png`

![Unique Session Audit](./assets/03-sudo-unique-user-session-audit.png)

* **Key Proof:** Validates the system log audit output quantifying unique PID session instances associated with `sudo` invocations across all configured accounts.

---

### Phase 4: Command Execution Summary Metrics
* **File:** `assets/04-most-common-sudo-commands-summary.png`

![Most Common Commands](./assets/04-most-common-sudo-commands-summary.png)

* **Key Proof:** Summarizes the top administrative binary calls captured in `/var/log/secure` (e.g., `/sbin/chpasswd`, `/bin/tee`, `/usr/bin/passwd root`, `/bin/su`, `/bin/ps`), confirming complete operational visibility over privileged subsystem calls.

---

## 🎯 Conclusion

In this lab, a comprehensive privilege management framework was engineered using standard enterprise Linux mechanisms (`sudoers`, `visudo`, `rsyslog`, `logrotate`). By defining granular Role-Based Access Controls (RBAC), implementing explicit command blacklists, configuring centralized audit logging, and building automated security parsing tools, the system achieves strict defense-in-depth security alignment with Red Hat best practices and security compliance benchmarks.