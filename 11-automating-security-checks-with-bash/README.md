# Lab 11: Automating Security Checks with Bash Scripts

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Red Hat](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Cron](https://img.shields.io/badge/Cron-412991?style=for-the-badge&logo=clock&logoColor=white)

## Executive Summary

This lab focuses on designing, implementing, scheduling, and monitoring modular Bash automation scripts to enforce system hardening, security patching, account auditing, and file integrity checks on Enterprise Linux. The ultimate goal is to eliminate manual compliance checks through automated orchestration via `crond`, ensuring a continuous and auditable security posture.

## Lab Objectives & Key Technical Implementations

1. **System Hardening & Network Port Security (`port_security.sh`)**
   * Programmed automated port scanning using `netstat -tuln` to audit active listening sockets.
   * Automated service enforcement to stop and disable legacy/unnecessary services (`telnet`, `rsh`, `rlogin`, `vsftpd`, `xinetd`).
   * Configured `firewalld` integration to remove insecure public zone services (`cockpit`, `dhcpv6-client`) dynamically.

2. **Automated Patch Management & Backups (`patch_management.sh`)**
   * Engineered automated pre-patch timestamped system backups for critical identity configuration files (`/etc/passwd`, `/etc/shadow`, `/etc/group`, `/etc/ssh/`) under `/backup/YYYYMMDD_HHMMSS/`.
   * Cross-platform package manager support (`yum`, `dnf`, `apt`) targeting security-only package updates (`yum update --security -y`).
   * Automated reboot condition flags detection based on kernel updates in update histories.

3. **Comprehensive Security Auditing (`security_audit.sh`)**
   * Programmed critical file permission auditing (`/etc/passwd`, `/etc/shadow`, `/etc/gshadow`).
   * Automated detection of privileged SUID/SGID binaries (`find / -perm -4000 -o -perm -2000`).
   * Evaluated account security (UID 0 privilege audit, passwordless account checks, and `lastlog` recency analysis).
   * Monitored network security state, system integrity, world-writable files (`find / -perm -002`), and security event logs (`/var/log/secure`).

4. **Master Orchestration & Cron Health Monitoring (`master_security.sh` & `cron_monitor.sh`)**
   * Built a centralized master controller (`master_security.sh`) to execute daily and weekly operational workflows with logging and email notification abstractions.
   * Configured root crontab with 4 scheduled security maintenance jobs.
   * Developed `cron_monitor.sh` to validate `crond` status, verify scheduled jobs, audit log freshness/rotation thresholds (>10MB warnings), and generate consolidated health reports (`/var/log/cron_monitoring_report.txt`).

---

## Technical Verification & Screenshot Evidence

### 1. Port Hardening & Patch Management Script Execution

Verified the execution of `port_security.sh` and `patch_management.sh`. Confirmed open listening ports, service disabling checks, and automated system configuration backups under `/backup/`.

![Port and Patch Management Execution](lab11-port-and-patch-management.png)
*Figure 1: `port_security.sh` scanning open ports and `patch_management.sh` creating timestamped configuration backups.*

### 2. Security Patch Installation & Verification

Executed system package cache cleanup, refreshed repository metadata, applied security updates, verified history transactions, and confirmed system post-patch cleanup.

![Patch Management Deep Dive](lab11-patch-management-execution.png)
*Figure 2: Repository metadata cache refresh, security update verification via `yum history`, and automated post-patch cleanup.*

### 3. Comprehensive Security Audit Execution

Ran `security_audit.sh` to audit permissions on sensitive configuration files (`/etc/shadow`, `/etc/gshadow`), list active SUID/SGID executable binaries, and identify permission warnings.

![Security Audit Script Execution](lab11-security-audit-execution.png)
*Figure 3: `security_audit.sh` detecting critical file permissions and auditing privileged SUID/SGID binaries.*

### 4. Master Script Workflow Orchestration

Invoked `master_security.sh daily` and `weekly` tasks to verify that individual sub-scripts run sequentially with output piped into `/var/log/master_security.log`.

![Master Security Script Orchestration](lab11-master-script-orchestration.png)
*Figure 4: Master orchestration script executing daily security task modules and logging results.*

### 5. Cron Job Scheduling & Health Monitoring

Verified active crontab entries (`crontab -l`) for daily, weekly, 6-hour, and business-day execution intervals, followed by running `cron_monitor.sh` to validate the `crond` daemon.

![Cron Scheduling & Monitoring](lab11-cron-schedule-and-monitoring.png)
*Figure 5: Root crontab entries listing and `cron_monitor.sh` validating `crond` service status.*

### 6. Automated Cron Monitoring Report Output

Inspected `/var/log/cron_monitoring_report.txt` confirming active crontab job validation, execution tracking, and daemon status.

![Cron Monitoring Report Summary](lab11-cron-monitoring-report.txt.png)
*Figure 6: Generated cron monitoring report displaying scheduled security jobs and log file validation.*

---

## Conclusion

By developing custom modular Bash security scripts, orchestrating their execution via a master controller, scheduling automated cadences in `crontab`, and establishing dedicated cron health monitoring, the host environment maintains automated operational security compliance. The implemented suite guarantees repeatable system hardening, auditable patching, continuous vulnerability detection, and automated log management.