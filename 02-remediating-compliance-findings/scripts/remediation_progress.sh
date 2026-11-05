#!/bin/bash

echo "=== REMEDIATION PROGRESS REPORT ==="
echo "Generated on: $(date)"
echo ""

# Initial scan results
INITIAL_FAILED=$(grep -c "fail" initial_results.xml 2>/dev/null || echo "0")
echo "Initial Failed Rules: $INITIAL_FAILED"

# Post-auto remediation results
AUTO_FAILED=$(grep -c "fail" post_auto_remediation.xml 2>/dev/null || echo "0")
echo "Failed After Auto Remediation: $AUTO_FAILED"

# Final results after manual remediation
FINAL_FAILED=$(grep -c "fail" final_results.xml 2>/dev/null || echo "0")
echo "Final Failed Rules: $FINAL_FAILED"

# Calculate improvements
AUTO_IMPROVEMENT=$((INITIAL_FAILED - AUTO_FAILED))
MANUAL_IMPROVEMENT=$((AUTO_FAILED - FINAL_FAILED))
TOTAL_IMPROVEMENT=$((INITIAL_FAILED - FINAL_FAILED))

echo ""
echo "=== IMPROVEMENTS ==="
echo "Rules Fixed by Auto Remediation: $AUTO_IMPROVEMENT"
echo "Rules Fixed by Manual Remediation: $MANUAL_IMPROVEMENT"
echo "Total Rules Fixed: $TOTAL_IMPROVEMENT"

if [ $INITIAL_FAILED -gt 0 ]; then
    IMPROVEMENT_PERCENT=$(echo "scale=2; ($TOTAL_IMPROVEMENT * 100) / $INITIAL_FAILED" | bc)
    echo "Overall Improvement: $IMPROVEMENT_PERCENT%"
fi
