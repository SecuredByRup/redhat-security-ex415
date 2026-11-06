# Lab 18: Securing File Access with ACLs

![Red Hat Enterprise Linux](https://img.shields.io/badge/Red%20Hat%20Enterprise%20Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS](https://img.shields.io/badge/CentOS%20Stream-262577?style=for-the-badge&logo=centos&logoColor=white)
![Linux Systems](https://img.shields.io/badge/Linux%20Security-POSIX%20ACLs-000000?style=for-the-badge&logo=linux&logoColor=white)
![Bash Scripting](https://img.shields.io/badge/Bash%20Scripting-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## 📌 Executive Summary
Standard Linux discretionary access control (DAC) models rely on basic permissions (`owner`, `group`, `others`) that are often too broad for enterprise workloads requiring fine-grained authorization. This lab demonstrates how to design, implement, and audit **POSIX Access Control Lists (ACLs)** using `setfacl` and `getfacl` on Red Hat Enterprise Linux / CentOS Stream 9.

All configuration files, test scripts, backups, and output verification logs are completely contained within the local project structure to ensure repository portability and maintain portfolio compliance.

---

## 🎯 Key Objectives
- **ACL Capability & Mount Verification:** Confirm file system ACL support using `tune2fs` and `getfacl`.
- **Granular User & Group Permissions:** Assign explicit read, write, and execute permissions to specific users (`alice`, `bob`, `charlie`, `diana`) and groups (`developers`, `managers`, `auditors`).
- **Default ACL Inheritance:** Enforce baseline directory permissions so that new files and subdirectories automatically inherit security policies.
- **Backup & Recovery Operations:** Export ACL states using `getfacl -R` and restore configurations dynamically with `setfacl --restore`.
- **Access Restriction Audit:** Conduct switch-user access testing (`sudo su - <user>`) to validate privilege boundaries and traversal rules.

---

## 🏗️ Environment & Architecture

### Environment Details
* **Operating System:** CentOS Stream 9 / RHEL Cloud Instance (`centos@ip-172-31-10-93`)
* **Core Utilities:** `setfacl`, `getfacl` (`acl` package)
* **Local Project Root:** `~/redhat-security-ex415/18-securing-file-access-with-acls/`

### Directory Layout
```text
18-securing-file-access-with-acls/
├── project/
│   ├── src/                # Development source files
│   ├── docs/               # Documentation files
│   ├── config/             # Configuration files
│   ├── sensitive/          # Restricted operational configurations
│   ├── shared/             # Multi-role shared team files
│   └── inheritance_test/   # Automated default ACL propagation testing
├── logs/
│   └── project_acls_backup.txt  # State backup file
├── scripts/                # Execution and test scripts
└── README.md
```

---

## 🚀 Lab Execution & Task Breakdown

### Task 1: Environment Setup & Directory Creation
1. Initialized local project hierarchy (`project/src`, `project/docs`, `project/config`).
2. Provisioned operational service users (`alice`, `bob`, `charlie`, `diana`) and security groups (`developers`, `managers`, `auditors`).
3. Set base standard directory permissions (`chmod 755`).

---

### Task 2: Advanced ACL Configuration & Backup Management

#### 2.1 Basic & Recursive ACL Operations
Configured direct user access and applied group policies recursively across project subdirectories:
```bash
# Modify specific permissions for user alice and group developers
sudo setfacl -R -m u:alice:rwx project/
sudo setfacl -R -m g:developers:r-x project/

# Set recursive default inheritance on directory structures
find project/ -type d -exec sudo setfacl -d -m u:alice:rwx {} \;
find project/ -type d -exec sudo setfacl -d -m g:developers:r-x {} \;
```

#### 2.2 Backup and Restoration Strategy
Captured complete file system ACL architecture to an export log and performed recovery validation:
```bash
# Export full state backup
getfacl -R project/ > logs/project_acls_backup.txt

# Remove all extended ACL entries (strip to standard DAC)
sudo setfacl -R -b project/

# Restore ACL configurations from backup
sudo setfacl --restore=logs/project_acls_backup.txt
```

---

### Task 3: Access Validation & Verification

#### 3.1 Sensitive Data Protection
Created restricted files (`database.conf` and `api_keys.txt`) inside `project/sensitive/` and enforced isolated permissions:
```bash
sudo setfacl -m u:alice:rw project/sensitive/database.conf
sudo setfacl -m u:charlie:r project/sensitive/database.conf
sudo setfacl -m u:diana:r project/sensitive/api_keys.txt
```

#### 3.2 Verification & Test Screenshot

![ACL Verification and Testing](./assets/acl_verification_and_testing.png)

* **Figure 1 (`acl_verification_and_testing.png`):** Demonstrates `getfacl` verification on `project/src`, execution of recursive backup logging into `logs/project_acls_backup.txt`, validation of access enforcement for user `charlie` (reading succeeded, unauthorized append denied), and group ACL rules on `project/shared/team_document.txt`.

#### 3.3 Default Inheritance Propagation

```bash
# Set default rules on test directory
sudo setfacl -d -m u:alice:rwx project/inheritance_test
sudo setfacl -d -m g:developers:rw project/inheritance_test
sudo setfacl -d -m other::--- project/inheritance_test
```

#### 3.4 Inheritance Verification Screenshot

![ACL Inheritance Verification](./assets/acl_inheritance_verification.png)

* **Figure 2 (`acl_inheritance_verification.png`):** Demonstrates automated inheritance on newly generated subdirectories (`subdir/`) and files (`nested_file.txt`). The masks and default `other::---` permissions successfully restrict unauthorized account access while preserving explicit access for `alice` and `developers`.

---

## 📊 Summary Matrix of User Permission Rules

| User / Role | Directory / File Path | Configured ACL | Observed Behavior | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Alice** | `sensitive/database.conf` | `u:alice:rw-` | Read/Write granted | ✅ Passed |
| **Charlie** | `sensitive/database.conf` | `u:charlie:r--` | Read granted, Write denied (`Permission denied`) | ✅ Passed |
| **Charlie** | `sensitive/api_keys.txt` | *None* | Read denied (`Permission denied`) | ✅ Passed |
| **Diana** | `sensitive/api_keys.txt` | `u:diana:r--` | Blocked without parent directory execute (`x`) | ✅ Passed |
| **Developers Group** | `shared/team_document.txt` | `g:developers:rw-` | Full Read/Write access granted | ✅ Passed |
| **Managers Group** | `shared/team_document.txt` | `g:managers:r--` | Read granted, Write denied | ✅ Passed |
| **Auditors Group** | `shared/team_document.txt` | `g:auditors:r--` | Read granted, Write denied | ✅ Passed |

---

## 💡 Key Takeaways & Best Practices
1. **Directory Traversal Rule (`+x`):** An ACL entry on a file inside a directory is ineffective if the user lacks execute (`x`) permission on all parent directories along the path.
2. **Effective Mask Management:** POSIX ACL masks (`mask::`) dynamically cap maximum permissions for named users and groups. Modifying base group permissions can alter the active mask.
3. **Inheritance Control (`default:`):** Always combine default directory ACLs (`setfacl -d`) with standard directory permissions to guarantee uniform security for dynamically created sub-assets.
4. **Backup Automation:** Incorporating `getfacl -R` into standard server migration or configuration audit pipelines ensures rapid restoration of complex permission structures.

---

## 🏁 Conclusion
Lab 18 successfully validates the implementation of POSIX Access Control Lists on Red Hat Enterprise Linux / CentOS Stream 9. Through granular rule definitions, group-based role assignments, default inheritance rules, and backup restoration pipelines, fine-grained file security was established while maintaining complete repository isolation for portfolio demonstration.