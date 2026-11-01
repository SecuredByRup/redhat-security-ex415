# Lab 3: Centralized Authentication Setup using FreeIPA (IdM) on RHEL/CentOS 9

<p align="left">
  <img src="https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat">
  <img src="https://img.shields.io/badge/CentOS-26252D?style=for-the-badge&logo=centos&logoColor=white" alt="CentOS">
  <img src="https://img.shields.io/badge/FreeIPA-007ACC?style=for-the-badge&logo=linux&logoColor=white" alt="FreeIPA">
  <img src="https://img.shields.io/badge/Kerberos-00599C?style=for-the-badge&logo=key&logoColor=white" alt="Kerberos">
  <img src="https://img.shields.io/badge/Security-007ACC?style=for-the-badge&logo=security&logoColor=white" alt="Security">
</p>

## Executive Summary

This laboratory details the deployment, configuration, and practical verification of a centralized **Identity, Policy, and Audit (IPA)** architecture using **FreeIPA** on RHEL/CentOS 9. The objective is to establish single sign-on (SSO) authentication, centralize directory user and group management, configure **System Security Services Daemon (SSSD)** local caching, enforce **PAM (`pam_sss.so`)** authentication hooks, and manage **Kerberos** principals and ticket-granting tokens (TGT).

---

## Infrastructure Overview

| Parameter | Value | 
| :--- | :--- | 
| **Operating System** | RHEL / CentOS Stream 9 | 
| **Hostname** | `idm-server.example.com` | 
| **IP Address** | `172.31.10.213` | 
| **Kerberos Realm** | `EXAMPLE.COM` | 
| **Domain** | `example.com` | 

---

## Key Technical Objectives

1. **Service Verification:** Validate all underlying FreeIPA components including Directory Service (389 Directory Server), KRB5 KDC, Apache HTTP server, and DNS services.
2. **Centralized Identity Management:** Provision central directory users (`testuser1`, `testuser2`) and assign group memberships (`testgroup`).
3. **SSSD & Name Service Switch Integration:** Configure local identity resolution and offline credentials caching via SSSD.
4. **Pluggable Authentication Modules (PAM):** Ensure standard Linux authentication stacks (`system-auth`, `password-auth`) enforce `pam_sss.so`.
5. **Kerberos Ticket Lifecycle:** Authenticate against the KDC, retrieve Ticket-Granting Tickets (TGT), handle initial password expiration prompts, and list active principal tickets.
6. **Group-Based Access Control (RBAC):** Restrict system directory privileges (`/tmp/testgroup_access`) and verify inherited group membership execution contexts.

---

## Detailed Execution & Verification

### Phase 1: Service Health & Directory Search

All core components of the FreeIPA stack were validated using `ipactl status`. The LDAP backend was subsequently queried to confirm identity entries.

```bash
# Verify IdM service stack status
sudo ipactl status

# Search active LDAP user entries in FreeIPA
ipa user-find
```

#### Verification Evidence:
![FreeIPA Status and User Search](screenshots/01-ipactl-and-user-find.png)

---

### Phase 2: Group Mapping & SSSD Client Caching

Group attributes were inspected using `ipa group-show`. SSSD was verified to ensure that remote directory records properly bind to the local Linux Name Service Switch (`getent`).

```bash
# Query group membership attributes
ipa group-show testgroup

# Check system status of SSSD
sudo systemctl status sssd

# Test local identity resolution for LDAP user
getent passwd testuser1
```

#### Verification Evidence:
![Group Show and SSSD Status](screenshots/02-group-show-and-sssd-status.png)

---

### Phase 3: Kerberos Authentication & Shared Folder Access Control

Authentication against the Kerberos KDC was tested using `kinit`, which successfully prompted for forced initial password changes on newly minted directory users. Group-based Access Control Lists (ACLs) were verified by switching user contexts and writing to POSIX-restricted group directories.

```bash
# Authenticate against KDC and obtain TGT
kinit testuser1@EXAMPLE.COM

# Display active Kerberos tickets
klist

# Verify effective UID, GID, and secondary groups
id testuser1

# Test write permissions in group-restricted folder (/tmp/testgroup_access)
sudo su - testuser1 -c "cd /tmp/testgroup_access && touch test_file_user1 && ls -la"
```

#### Verification Evidence:
![Kerberos Ticket and Access Validation](screenshots/03-kerberos-kinit-and-shared-access.png)

---

## Screenshot Mapping Strategy

| Original Image Filename | New Portfolio Filename | Description / Core Output Captured |
| :--- | :--- | :--- |
| `Screenshot (770).png` | `01-ipactl-and-user-find.png` | `ipactl status` verification showing running daemons and `ipa user-find` output. |
| `Screenshot (772).png` | `02-group-show-and-sssd-status.png` | `ipa group-show`, active SSSD service daemon, and `getent` lookup. |
| `Screenshot (773).png` | `03-kerberos-kinit-and-shared-access.png` | Kerberos ticket validation (`kinit`/`klist`) and group directory write verification. |

---

## Conclusion

The FreeIPA centralized authentication deployment was successfully verified. The system demonstrates robust integration across Directory Services, Kerberos ticket management, SSSD caching, and PAM stack authentication. Centralized group rules seamlessly translate into local POSIX security enforcement, fulfilling modern enterprise security auditing and access control requirements.