#!/bin/bash

echo "=== CRITICAL SECURITY FINDINGS ANALYSIS ==="
echo "Generated on: $(date)"
echo ""

echo "DISA STIG Critical Failures:"
echo "----------------------------"
if [ -f "results/disa-stig/stig-results.xml" ]; then
    grep -A 5 -B 5 'result="fail"' results/disa-stig/stig-results.xml | \
    grep -E "(rule id|title)" | head -20
else
    echo "DISA STIG results file not found"
fi

echo ""
echo "PCI-DSS Critical Failures:"
echo "---------------------------"
if [ -f "results/pci-dss/pci-results.xml" ]; then
    grep -A 5 -B 5 'result="fail"' results/pci-dss/pci-results.xml | \
    grep -E "(rule id|title)" | head -20
else
    echo "PCI-DSS results file not found"
fi

echo ""
echo "=== REMEDIATION PRIORITY ==="
echo "1. Review failed rules in HTML reports"
echo "2. Focus on high-severity findings first"
echo "3. Implement fixes systematically"
echo "4. Re-scan to verify remediation"
