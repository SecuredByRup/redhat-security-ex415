# Lab 12: Encrypting Data with GPG, Digital Signatures & Key Management

<p align="center">
  <img src="https://img.shields.io/badge/GnuPG-GPG-0093DD?style=for-the-badge&logo=gnupg&logoColor=white" alt="GnuPG / GPG" />
  <img src="https://img.shields.io/badge/Red_Hat_Enterprise_Linux-RHEL-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat Enterprise Linux" />
  <img src="https://img.shields.io/badge/GNU_Bash-Shell-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="GNU Bash" />
  <img src="https://img.shields.io/badge/Linux_Security-Cryptography-000000?style=for-the-badge&logo=linux&logoColor=white" alt="Linux Security" />
</p>

---

## 📌 Executive Summary
This lab covers hands-on enterprise cryptography, GPG key management, symmetric and asymmetric data encryption, digital signature creation/verification, and shell script automation on Red Hat Linux enterprise systems. The procedures implemented establish secure data handling workflows, integrity checking mechanisms, and key backup policies compliant with industry security standards.

---

## 🛠️ Technology Stack & Core Tools
* **Encryption Suite:** GnuPG (GPG / GPG2) — OpenPGP standard implementation.
* **Asymmetric Key Algorithm:** RSA 4096-bit (Public/Private Key Pair with 1-year expiration).
* **Symmetric Cipher:** AES-256 (Password-based symmetric file protection).
* **Automation Framework:** GNU Bash (Batch file encryption script).
* **Operating System:** Red Hat Enterprise Linux / CentOS Linux (`centos@ip-172-31-10-4`).

---

## 🔑 Key Management Details
* **Primary Key ID / Fingerprint:** `8F56 10A3 36F8 6E36 8E4E  9734 BB22 7610 A973 1C07`
* **User ID (UID):** `Rupal Student (Lab Practice Key) <rupal.student@example.com>`
* **Key Type & Expiration:** `rsa4096 / 2026-11-04 [SC]` (Expires: `2027-11-04`)
* **Secondary Lab Partner UID:** `Lab Partner <partner@example.com>` (`FC69 7E4D D178 29E7 79D0  A671 7A20 566E 3C72 78A0`)

---

## 🚀 Lab Implementation & Execution Steps

### Task 1: Key Generation & ASCII Export
1. Generated a 4096-bit RSA key pair with expiration and ultimate trust level set for local user operations.
2. Exported the public key in ASCII armor format for public distribution and peer exchange.
```bash
gpg --full-generate-key
gpg --armor --export rupal.student@example.com > my-public-key.asc
```

### Task 2: Symmetric and Asymmetric File Protection
1. **Symmetric Encryption:** Applied AES-256 cipher encryption to confidential data using local passphrases.
2. **Asymmetric Encryption:** Encrypted sensitive financial records against public keys on the local keyring.
3. **Multi-Recipient Setup:** Combined recipient flags to allow multiple authorized parties (e.g., student and lab partner) to decrypt shared data.
```bash
# Asymmetric encryption pipeline
gpg --armor --recipient rupal.student@example.com --recipient partner@example.com --encrypt personal-info.txt
```

### Task 3: Combined Digital Signatures & Verification
1. Created detached digital signatures (`.asc`) to verify message integrity without modifying source files.
2. Formatted combined sign-and-encrypt pipelines, ensuring GPG operational options (`--armor`, `--recipient`, `--output`) precede primary action flags (`--sign`, `--encrypt`).
```bash
gpg --armor --recipient rupal.student@example.com --output secure-document.asc --sign --encrypt financial-data.txt
gpg --verify secret-message.txt.asc secret-message.txt
```

### Task 4: Automation via Batch Processing Script
Developed and executed `batch-encrypt.sh` to iterate through all text files in the working directory and automatically generate encrypted ASCII armor outputs while bypassing interactive prompt failures.

```bash
#!/bin/bash
for file in *.txt; do
    if [ -f "$file" ]; then
        gpg --trust-model always --encrypt --armor \
            --recipient rupal.student@example.com \
            --output "${file}.encrypted" \
            "$file"
        echo "Encrypted: $file"
    fi
done
```

---

## 📸 Lab Execution Evidence

### 1. Batch Encryption Script & Keyring Status
The terminal capture below confirms the automated execution of `batch-encrypt.sh` across all target `.txt` files, alongside a complete query of local public (`gpg --list-keys`) and secret (`gpg --list-secret-keys`) keyrings showing trust metrics and fingerprints.

![Batch Encryption Script and Keyring Verification](screenshots/batch-encryption-and-keyring.png)

### 2. Public Key Export & Repository Workspace
The screenshot below confirms the ASCII armor public key export (`my-public-key.asc`) generated via `gpg --armor --export` and the verified contents of the working directory (`/home/centos/redhat-security-ex415/12-encrypting-data-with-gpp/scripts`).

![Public Key Export and Workspace Directory](screenshots/public-key-export.png)

---

## 🔒 Best Practices & Lessons Learned
1. **GPG Syntax Rule:** Operational flags (`--armor`, `--recipient`, `--output`) must precede command action flags (`--sign`, `--encrypt`) to avoid syntax parsing errors.
2. **Local Key Lookup:** Specifying direct email UIDs or explicit key fingerprints prevents unnecessary Web Key Directory (WKD) lookup failures on isolated systems.
3. **Key Lifecycle Management:** Key pair generation policies should always include designated expiration dates and secure offline backups of private keys (`private-key-backup.asc`).

---

## 🎯 Conclusion
Lab 12 successfully demonstrated the end-to-end implementation of GnuPG cryptography on Linux enterprise infrastructure. Through key management, symmetric/asymmetric file encryption, digital signatures, and automated batch scripting, the environment was configured to guarantee data confidentiality, operational authenticity, and strict integrity verification across systems.