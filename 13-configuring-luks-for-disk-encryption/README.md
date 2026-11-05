# Lab 13: Configuring LUKS Disk Encryption

<p align="center">
  <img src="https://img.shields.io/badge/Red_Hat_Enterprise_Linux-EE0000?style=for-the-badge&logo=redhat&logoColor=white" alt="Red Hat Linux" />
  <img src="https://img.shields.io/badge/LUKS_2-Lock_Protection-blue?style=for-the-badge&logo=linux&logoColor=white" alt="LUKS Encryption" />
  <img src="https://img.shields.io/badge/AES--XTS--512-Cryptographic_Security-success?style=for-the-badge&logo=powershell&logoColor=white" alt="AES Encryption" />
  <img src="https://img.shields.io/badge/Bash-Automation-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash" />
</p>

---

## 📌 Executive Summary

This enterprise lab covers data-at-rest encryption using **Linux Unified Key Setup (LUKS2)** and `cryptsetup` on Red Hat Enterprise Linux / CentOS systems. It demonstrates end-to-end management of encrypted block storage—from initial partition provisioning and custom 512-bit cipher hardening (`aes-xts-plain64` / `sha512`) to filesystem creation (`ext4`), multi-slot key lifecycle administration, cold-storage header backups, performance benchmarking, and active device-mapper status verification.

---

## 🛠️ Technology Stack & Core Utilities

* **Operating System:** Red Hat Enterprise Linux / CentOS 9 (`x86_64`)
* **Encryption Subsystem:** LUKS2 (Linux Unified Key Setup) via `cryptsetup` 2.8.1
* **Cryptographic Algorithms:** AES-XTS (256-bit and 512-bit cipher keys), Argon2id PBKDF, SHA-256 / SHA-512 hashes
* **Storage Architecture:** Amazon Elastic Block Store (NVMe block device `/dev/nvme1n1`), Device Mapper (`/dev/mapper/encrypted_volume`)
* **Filesystem & Management Tools:** `ext4`, `fdisk`, `lsblk`, `dmsetup`, `dd`, `hexdump`

---

## 🚀 Step-by-Step Implementation Workflow

### Task 1: Partition Setup & Basic LUKS Formatting
1. Inspected available NVMe disk topology using `lsblk` and initialized a partition using `fdisk /dev/nvme1n1`.
2. Initialized LUKS encryption on the primary storage device with `cryptsetup luksFormat`.
3. Verified LUKS2 header structures, UUID, metadata size, and key slot allocation using `cryptsetup luksDump`.

```bash
sudo fdisk /dev/nvme1n1
sudo cryptsetup luksFormat /dev/nvme1n1
sudo cryptsetup luksDump /dev/nvme1n1
```

### Task 2: Opening Mappings & Filesystem Deployment
1. Mapped the encrypted block device to `/dev/mapper/encrypted_volume` using `cryptsetup luksOpen`.
2. Created an `ext4` filesystem directly inside the mapped virtual device.
3. Created directory `/mnt/encrypted_data`, mounted the volume, and populated test data to verify persistence.

```bash
sudo cryptsetup luksOpen /dev/nvme1n1 encrypted_volume
sudo mkfs.ext4 /dev/mapper/encrypted_volume
sudo mkdir -p /mnt/encrypted_data
sudo mount /dev/mapper/encrypted_volume /mnt/encrypted_data
```

### Task 3: Key Slot Management, Header Backups & Performance Tests
1. Added secondary passphrases with `luksAddKey` and pruned specific slots with `luksKillSlot`.
2. Created a binary cold backup of the LUKS header using `luksHeaderBackup` to ensure disaster recovery capability.
3. Conducted `dd` read/write throughput tests and cryptographic benchmarking (`cryptsetup benchmark`).
4. Closed the mapper device and performed raw `hexdump` analysis on `/dev/nvme1n1` to confirm raw binary scrambling.

```bash
sudo cryptsetup luksAddKey /dev/nvme1n1
sudo cryptsetup luksKillSlot /dev/nvme1n1 1
sudo cryptsetup luksHeaderBackup /dev/nvme1n1 --header-backup-file /root/luks-header-backup
cryptsetup benchmark
```

### Task 4: Security Hardening & Device Mapper Troubleshooting
1. Unmounted `/mnt/encrypted_data` and closed `encrypted_volume` to release active device locks.
2. Reformatted the raw device using custom 512-bit AES-XTS specifications and SHA-512 hashing.
3. Re-created the filesystem, remounted the volume, and verified active target status using `dmsetup info` and `dmsetup status`.

```bash
sudo umount /mnt/encrypted_data
sudo cryptsetup luksClose encrypted_volume
sudo cryptsetup luksFormat /dev/nvme1n1 --cipher aes-xts-plain64 --key-size 512 --hash sha512
sudo cryptsetup luksOpen /dev/nvme1n1 encrypted_volume
sudo mkfs.ext4 /dev/mapper/encrypted_volume
sudo mount /dev/mapper/encrypted_volume /mnt/encrypted_data
sudo dmsetup status encrypted_volume
```

---

## 📸 Technical Evidence & Screenshots

### 1. Storage Partitioning & Initial Inspection
Demonstrates NVMe storage topology inspection via `lsblk` and new partition table creation using `fdisk`.
![Storage Partitioning](screenshots/01-disk-partitioning.png)

### 2. Initial LUKS Formatting & Header Dump
Shows LUKS2 container initialization confirmation and header header inspection (`Version: 2`, key slot allocation).
![LUKS Formatting](screenshots/02-luks-formatting-and-dump.png)

### 3. LUKS Volume Unlocking & Device Mapping
Shows passphrase authentication, active mapper symlink creation (`/dev/mapper/encrypted_volume`), and active status verification.
![Volume Opening](screenshots/03-volume-opening-and-status.png)

### 4. Filesystem Provisioning & Data Verification
Demonstrates `mkfs.ext4` creation on the virtual mapping, filesystem mounting to `/mnt/encrypted_data`, and file read/write verification.
![Filesystem Mount](screenshots/04-filesystem-creation-and-mount.png)

### 5. Multi-Slot Key Administration & Header Backup
Demonstrates adding/deleting passphrase slots (`luksAddKey`, `luksKillSlot`) and generating the header backup file `/root/luks-header-backup`.
![Key Management](screenshots/05-key-management-and-header-backup.png)

### 6. Performance Benchmarking & Raw Data Isolation
Displays `dd` I/O speed tests, algorithm performance comparisons, and `hexdump` inspection demonstrating complete unreadable cipher text on raw block storage.
![Benchmarking and Hexdump](screenshots/06-performance-benchmark-and-hexdump.png)

### 7. Hardened Re-formatting & Active Mapper Validation
Demonstrates custom 512-bit AES-XTS re-formatting, resolution of active device locks, `mkfs.ext4` rebuild, and `dmsetup info` verification showing active `CRYPT-LUKS2` status.
![Hardened Reformat and dmsetup](screenshots/07-hardened-cipher-reformat-and-dmsetup.png)

---

## 🔒 Security Best Practices Implemented

1. **High-Entropy Cryptographic Ciphers:** Escalated standard disk encryption to 512-bit key sizes with `aes-xts-plain64` and SHA-512 hashing for enhanced cryptographic protection.
2. **Device Lock Hygiene:** Strictly closing active mapper instances (`luksClose`) and unmounting filesystems (`umount`) prior to administrative formatting actions to protect against filesystem corruption.
3. **Disaster Recovery Preparedness:** Exporting cold binary copies of LUKS header metadata (`luksHeaderBackup`) to mitigate risk against partition header corruption.
4. **Key Slot Hygiene:** Removing temporary or revoked access keys (`luksKillSlot`) to adhere to least-privilege principles without compromising operational availability.

---

## 🎯 Conclusion

Lab 13 demonstrates the configuration of block-level disk encryption using LUKS2 on Red Hat Enterprise Linux. By combining custom 512-bit AES-XTS cipher specifications, virtual device mapping, `ext4` filesystem administration, multi-slot key lifecycle control, and header recovery practices, this implementation satisfies enterprise compliance standards (PCI-DSS, HIPAA, GDPR) for data-at-rest protection on cloud-hosted and physical infrastructure.