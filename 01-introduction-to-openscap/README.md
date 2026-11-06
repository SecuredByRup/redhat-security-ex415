# Lab 1: Introduction to OpenSCAP

<p align="center">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux" />
  <img src="https://img.shields.io/badge/Red_Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat" />
  <img src="https://img.shields.io/badge/CentOS-262577?style=for-the-badge&logo=centos&logoColor=white" alt="CentOS" />
  <img src="https://img.shields.io/badge/OpenSCAP-00599C?style=for-the-badge&logo=shield&logoColor=white" alt="OpenSCAP" />
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash" />
</p>

## 📌 Executive Summary
This project demonstrates automated security compliance scanning, auditing, and reporting on an enterprise Linux environment using **OpenSCAP** (`oscap`). The lab covers inspecting data streams, executing compliance evaluations against **DISA STIG** and **PCI-DSS** benchmarks, parsing raw evaluation results into structured summaries, and building automated remediation templates.

---

## 🎯 Objectives
* Install and verify OpenSCAP scanning tools and security guides on Linux systems.
* Explore available SCAP compliance profiles (DISA STIG, PCI-DSS, CIS, NIST).
* Execute automated compliance scans producing XCCDF XML and OVAL results.
* Generate human-readable HTML reporting assets and custom analytical text summaries.
* Extract critical vulnerability metrics and build executable bash remediation scripts.

---

## 📁 Repository & Directory Structure
```text
redhat-security-ex415/
└── 01-introduction-to-openscap/
    └── scripts/
        ├── analyze_findings.sh
        ├── remediation_template.sh
        └── results/
            ├── disa-stig/
            │   ├── stig-results.xml
            │   └── stig-report.html
            ├── pci-dss/
            │   ├── pci-results.xml
            │   └── pci-report.html
            └── reports/
                ├── compliance-summary.txt
                ├── critical-findings.txt
                ├── scores.txt
                ├── stig-detailed-report.html
                └── stig-summary.html
```

---

## 🛠️ Step-by-Step Implementation & Verification

### Task 1: Environment Setup & Tool Verification
Installed `openscap-scanner` and `scap-security-guide` packages to establish the core auditing suite.

Command executed:
```bash
oscap --version
```

![OpenSCAP Version Verification](./openscap-version-verification.png)

*Figure 1: Verification of installed OpenSCAP specifications (SCAP 1.3, XCCDF 1.2, OVAL 5.11.1) and loaded Linux probes.*

---

### Task 2 & 3: Compliance Scanning, Metric Extraction & Verification
Evaluated the system state against standard security benchmarks and extracted aggregated metrics.

Commands executed:
```bash
# View command execution history for evaluation
history | grep "oscap xccdf eval"

# Verify all generated lab assets (XML, HTML, TXT)
find ~/redhat-security-ex415/01-introduction-to-openscap -name "*.xml" -o -name "*.html" -o -name "*.txt" | wc -l

# Display parsed compliance scan summary
cat results/reports/compliance-summary.txt
```

![Scan Execution and Summary Proof](./scan-execution-and-summary.png)

*Figure 2: Execution history, confirmation of 13 generated reporting assets, and output of the parsed DISA STIG and PCI-DSS compliance metrics.*

---

## 📊 Key Security Findings Summary

| Profile Standard | Total Rules Evaluated | Result Status |
| :--- | :--- | :--- |
| **DISA STIG** | 96 Rules | Evaluated (Failures flagged for remediation) |
| **PCI-DSS** | 52 Rules | Evaluated (Payment security benchmarks applied) |

---

## 🔧 Automated Remediation Workflow
An initial baseline remediation script (`remediation_template.sh`) was generated to automate system hardening for high-priority DISA STIG failures:
* Secure permissions on critical files (`/etc/passwd`, `/etc/shadow`, `/etc/group`).
* Host-based firewall enforcement via `firewalld`.
* Audit logging service initialization (`auditd`).
* Automated core system package updates (`dnf update`).

---

## 🏁 Conclusion
This lab successfully established a baseline for automated compliance auditing and reporting using OpenSCAP on Linux. By integrating standardized SCAP content streams with automated reporting and custom bash scripts, enterprise environments can maintain continuous security alignment with DISA STIG and PCI-DSS compliance frameworks.