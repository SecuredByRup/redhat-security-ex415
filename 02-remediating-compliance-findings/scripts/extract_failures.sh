#!/bin/bash

echo "=== REMAINING COMPLIANCE VIOLATIONS ===" > remaining_violations.txt
echo "Generated on: $(date)" >> remaining_violations.txt
echo "" >> remaining_violations.txt

# Extract failed rules with titles using RHEL 9 datastream
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_pci-dss /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml 2>&1 | \
grep -A1 -B1 "fail" | \
grep -E "(Title|fail)" >> remaining_violations.txt

echo "" >> remaining_violations.txt
echo "=== REMEDIATION RECOMMENDATIONS ===" >> remaining_violations.txt
echo "1. Review failed rules in the detailed HTML report" >> remaining_violations.txt
echo "2. Consult organization security policies for manual fixes" >> remaining_violations.txt
echo "3. Consider risk acceptance for non-critical violations" >> remaining_violations.txt
echo "4. Schedule regular compliance scans" >> remaining_violations.txt
