# Lab 16: Automating Security with Ansible

![Ansible](https://img.shields.io/badge/Ansible-E00A00?style=for-the-badge&logo=ansible&logoColor=white)
![Red Hat](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Security](https://img.shields.io/badge/Security-005571?style=for-the-badge&logo=security&logoColor=white)

## 📌 Executive Summary

This repository contains the completed artifacts and automation playbooks for **Lab 16: Automating Security with Ansible** under the **Red Hat Security EX415** curriculum. The project demonstrates enterprise Infrastructure as Code (IaC) principles by programmatically enforcing security baselines, hardening services, and validating compliance across Linux nodes.

To optimize for local execution and cloud lab constraints, the multi-node lab environment is adapted to run on a single cloud instance (`172.31.10.234`) using Ansible local connection mode (`ansible_connection=local`), ensuring complete idempotency and zero network timeout friction.

---

## 📂 Repository Structure

```text
redhat-security-ex415/
└── 16-automating-with-ansible/
    ├── README.md
    ├── scripts/
    │   ├── inventory.ini
    │   ├── ansible.cfg
    │   ├── ssh-hardening.yml
    │   ├── firewall-hardening.yml
    │   ├── system-hardening.yml
    │   ├── master-security.yml
    │   ├── security-validation.yml
    │   ├── security-monitoring.yml
    │   └── compliance-check.yml
    ├── reports/
    │   ├── web1_security_report.txt
    │   └── db1_security_report.txt
    ├── monitoring/
    │   ├── web1_2026-11-05.txt
    │   └── db1_2026-11-05.txt
    └── screenshots/
        ├── 01-inventory-and-ssh-hardening.png
        ├── 02-firewall-hardening-execution.png
        ├── 03-firewall-rules-verification.png
        ├── 04-master-orchestration-playbook.png
        ├── 05-master-playbook-and-reports.png
        ├── 06-validation-and-monitoring.png
        └── 07-monitoring-reports-verification.png
```

---

## ⚙️ Core Automation Components

### 1. Environment Configuration & Inventory
* **`inventory.ini`**: Maps target groups (`webservers`, `databases`) to local execution endpoints (`127.0.0.1`) with passwordless sudo integration.
* **`ansible.cfg`**: Configures optimized defaults, timeout parameters, and disables host key checking for streamlined execution.

### 2. Hardening Playbooks
* **SSH Hardening (`ssh-hardening.yml`)**: Disables root login via SSH, restricts password authentication in favor of key-based access, and limits authentication retry attempts.
* **Firewall Hardening (`firewall-hardening.yml`)**: Installs and enables `firewalld`, opening mandatory ports (`22/tcp`, `80/tcp`, `443/tcp`) with robust exception handling (`ignore_errors`) for shared loopback hosts.
* **System Hardening (`system-hardening.yml`)**: Secures kernel parameters and configures intrusion prevention tools (`fail2ban`).

### 3. Orchestration, Reporting & Monitoring
* **Master Orchestration (`master-security.yml`)**: Chains all hardening playbooks into a unified pipeline and extracts baseline configuration reports.
* **Validation & Monitoring (`security-validation.yml` & `security-monitoring.yml`)**: Programmatically verifies compliance states and gathers operational metrics (failed logins, active ports, disk utilization, system load) into centralized local logs (`./reports/` and `./monitoring/`).

---

## 🎯 Conclusion

Lab 16 establishes a repeatable, automated baseline for enterprise Linux security management. By treating security configurations as code, administrators can eliminate configuration drift, audit compliance programmatically, and scale hardening across infrastructure deployments seamlessly.