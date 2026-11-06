# Lab 9: Hardening SSH Configurations

<p align="left">
  <img src="https://img.shields.io/badge/OpenSSH-000000?style=for-the-badge&logo=OpenSSH&logoColor=white" alt="OpenSSH Logo" />
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux Logo" />
  <img src="https://img.shields.io/badge/Red_Hat_Enterprise_Linux-EE0000?style=for-the-badge&logo=red-hat&logoColor=white" alt="RHEL Logo" />
  <img src="https://img.shields.io/badge/SELinux-6C757D?style=for-the-badge&logo=redhat&logoColor=white" alt="SELinux Logo" />
</p>

## Executive Summary
This lab demonstrates end-to-end security hardening of the OpenSSH daemon (`sshd`) on a Enterprise Linux server. The primary objective is to transition from default password-based authentication on standard ports to a hardened, key-only SSH architecture on a custom port (`2222`), reinforced with SELinux policies and user access controls.

---

## Lab Objectives & Key Technical Implementations

1. **Cryptographic Key Management (RSA 4096-bit)**
   - Generated secure RSA key pairs using `ssh-keygen -t rsa -b 4096`.
   - Applied strict Linux file permissions to protect private cryptographic material (`700` for `~/.ssh/`, `600` for `id_rsa` and `authorized_keys`, `644` for `id_rsa.pub`).

2. **OpenSSH Daemon Hardening (`/etc/ssh/sshd_config`)**
   - **Port Reconfiguration:** Shifted standard SSH port from `22` to `2222` to mitigate automated brute-force scanning.
   - **Access Restrictions:** Restricted administrative access via `PermitRootLogin no` and enforced explicit account whitelisting with `AllowUsers centos`.
   - **Authentication Enforcement:** Completely disabled password fallback (`PasswordAuthentication no`) and empty passwords (`PermitEmptyPasswords no`) in favor of public-key authentication (`PubkeyAuthentication yes`).
   - **Brute-Force & Session Protections:** Lowered authorization retry limits (`MaxAuthTries 3`), reduced connection grace periods (`LoginGraceTime 60`), and instituted keep-alive timeouts (`ClientAliveInterval 300`, `ClientAliveCountMax 2`).

3. **Mandatory Access Control (SELinux Integration)**
   - Resolved binding conflicts caused by SELinux port labeling by registering custom TCP port `2222` under the `ssh_port_t` policy context:
     ```bash
     sudo semanage port -a -t ssh_port_t -p tcp 2222
     ```
   - Resolved systemd socket activation conflicts (`sshd.socket`) to allow standalone daemon execution on port `2222`.

---

## Verification and Security Testing

All security policies were rigorously validated to verify system posture and enforcement:

* **Port Binding Verification:** Verified `sshd` socket binding on `0.0.0.0:2222` and `[::]:2222` via `ss -tlnp`.
* **Key-Based Authentication:** Confirmed seamless non-root key authentication for user `centos`.
* **Root Access Rejection:** Confirmed direct root logins are rejected immediately (`Permission denied`).
* **Password Authentication Disable Verification:** Temporarily removed private keys and confirmed connection rejection without password prompting.
* **Account Whitelisting Enforcement:** Confirmed non-whitelisted users (`testuser`) are blocked from authentication.

### Comprehensive Evidence Screenshot

Rename your screenshot file to `lab9-ssh-hardening-verification.png` and place it in the same directory as this README file.

![SSH Hardening Verification](lab9-ssh-hardening-verification.png)

*Figure 1: Terminal evidence verifying key permissions, active custom port binding on TCP 2222, successful key-based login, root login rejection, password fallback mitigation, and `AllowUsers` enforcement.*

---

## Conclusion
By hardening the SSH configuration, implementing key-based authentication, restricting user access, and aligning SELinux security contexts, the server attack surface has been significantly minimized. The system now enforces strict cryptographic identity verification and proactive brute-force prevention aligned with enterprise cybersecurity best practices.