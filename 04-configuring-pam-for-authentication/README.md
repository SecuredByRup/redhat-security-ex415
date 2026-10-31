# Lab 4: Configuring Pluggable Authentication Modules (PAM) for Authentication

<p align="left">
  <img src="https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat">
  <img src="https://img.shields.io/badge/CentOS-26252D?style=for-the-badge&logo=centos&logoColor=white" alt="CentOS">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/Security-007ACC?style=for-the-badge&logo=security&logoColor=white" alt="Security">
</p>

## Executive Summary

This laboratory focuses on hardening Enterprise Linux authentication mechanisms by configuring **Pluggable Authentication Modules (PAM)**, enforcement of **Password Quality (`pam_pwquality`)**, **Account Lockout (`pam_faillock`)**, **Time-Based Access Controls (`pam_time`)**, **Resource Limits (`pam_limits`)**, and **Legal Login Notifications (`pam_issue` / `pam_lastlog`)** on Enterprise Linux (RHEL/CentOS 9).

## Technical Objectives & Architecture

1. **Password Aging & Quality Standards:** Implement strict password complexity metrics (`minlen`, `dcredit`, `ucredit`, `lcredit`, `ocredit`) and age boundaries using `/etc/security/pwquality.conf`, `/etc/login.defs`, and `chage`.

2. **Brute-Force Mitigation:** Deploy `pam_faillock` to enforce account lockout policies following 3 consecutive authentication failures, with configurable unlock thresholds.

3. **Time-Based & Resource Controls:** Restrict login schedules via `/etc/security/time.conf` (`pam_time.so`) and enforce maximum user process/file handle resource limits via `/etc/security/limits.conf` (`pam_limits.so`).

4. **Legal Banners & Failure Auditing:** Enforce system warning banners via `/etc/issue` (`pam_issue.so`) and present failed login counts during session startup (`pam_lastlog.so`).

## Implementation & Verification Workflow

### 1. Password Aging & Complexity Configuration

Configured password complexity parameters within `/etc/security/pwquality.conf` and updated global aging parameters (`PASS_MAX_DAYS 90`, `PASS_MIN_DAYS 1`, `PASS_WARN_AGE 7`) in `/etc/login.defs`. Applied and verified policies against `testuser1`:

```bash
# Set password aging for testuser1
sudo chage -M 90 -m 1 -W 7 testuser1

# Inspect active user password aging attributes
sudo chage -l testuser1
```

### 2. Account Lockout Implementation & Testing (`pam_faillock`)

Configured `pam_faillock.so` in `/etc/pam.d/system-auth` and `/etc/pam.d/password-auth` to lock accounts after 3 failed attempts for 600 seconds. Verified active locking mechanics:

```bash
# Attempt failed authentication attempts
su - testuser2

# Inspect user failure log records
sudo faillock --user testuser2

# Manually reset user lockout status
sudo faillock --user testuser2 --reset
```

#### Verification Evidence:

![PAM Faillock and Auth Failure](screenshots/01-pam-faillock-and-auth-failure.png)
*Figure 1: Authentication failure tracking and `faillock` module logging entries.*

### 3. Comprehensive Login Policy Configuration

Integrated time restrictions (`/etc/security/time.conf`), process limits (`/etc/security/limits.conf`), and legal banners (`/etc/issue`) into the PAM stack (`/etc/pam.d/system-auth` and `/etc/pam.d/login`):

```bash
# Configure time-based access control
sudo tee -a /etc/security/time.conf << 'EOF'
*;*;testuser1;MoTuWeThFr0800-1800
*;*;!testuser2;SaSu0000-2400
EOF

# Append resource limits for testuser1
sudo tee -a /etc/security/limits.conf << 'EOF'
testuser1    soft    nproc    50
testuser1    hard    nproc    100
testuser1    soft    nofile   1024
testuser1    hard    nofile   2048
testuser1    soft    as       102400
testuser1    hard    as       204800
EOF

# Bind modules to PAM stack
sudo tee -a /etc/pam.d/system-auth << 'EOF'
account     required       pam_time.so
session     required       pam_limits.so
session     optional       pam_lastlog.so showfailed
EOF
```

#### Verification Evidence:

![PAM Policy Configuration and Chage](screenshots/02-pam-policy-config-and-chage.png)
*Figure 2: Execution of automated policy configurations and successful `chage` policy inspection.*

### 4. User Session & Resource Limit Validation

Validated user session creation, compliance banner injection, and resource limits under active user contexts:

```bash
# Switch context to testuser1 and evaluate resource limits
sudo su - testuser1
ulimit -a
```

#### Verification Evidence:

![User Session and Ulimit Verification](screenshots/03-user-session-and-ulimit-verification.png)
*Figure 3: Active user login session confirming applied security banners and resource restrictions via `ulimit -a`.*

---

## Conclusion

This lab successfully established a defense-in-depth security configuration across the Linux Pluggable Authentication Module (PAM) architecture. By enforcing password complexity, automated account lockout rules, time-bound session access, and process resource caps, the operating system is fortified against brute-force attacks and resource exhaustion vector attacks while meeting stringent enterprise compliance frameworks.