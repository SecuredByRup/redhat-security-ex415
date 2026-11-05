#!/bin/bash

# OpenSCAP Compliance Remediation Template
# Generated from Lab 1 scan results

echo "Starting compliance remediation..."
echo "Date: $(date)"

echo "Applying common DISA STIG fixes..."
chmod 644 /etc/passwd
chmod 600 /etc/shadow
chmod 644 /etc/group

systemctl enable firewalld
systemctl start firewalld

dnf update -y

systemctl enable auditd
systemctl start auditd

echo "Basic remediation steps completed."
echo "Review scan reports for specific additional requirements."
echo "Re-run scans to verify improvements."
