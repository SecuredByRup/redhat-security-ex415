#!/bin/bash

# OpenSCAP Automated Security Scan Script
# Saved locally inside the repository portfolio directory

# Variables
SCAN_DATE=$(date +"%Y%m%d_%H%M%S")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
REPORT_DIR="$SCRIPT_DIR/../reports"
PROFILE="xccdf_org.ssgproject.content_profile_cis"
CONTENT_FILE="/usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml"

# Create local directories if they don't exist
mkdir -p $REPORT_DIR
mkdir -p $LOG_DIR

# Log start of scan
echo "$(date): Starting OpenSCAP security scan" >> $LOG_DIR/oscap-scan.log

# Run OpenSCAP scan (using sudo for the scanner execution itself)
sudo oscap xccdf eval \
    --profile $PROFILE \
    --results $REPORT_DIR/oscap-results-$SCAN_DATE.xml \
    --report $REPORT_DIR/oscap-report-$SCAN_DATE.html \
    $CONTENT_FILE >> $LOG_DIR/oscap-scan.log 2>&1

# Check scan completion
if [ $? -eq 0 ] || [ $? -eq 2 ]; then
    echo "$(date): OpenSCAP scan completed successfully" >> $LOG_DIR/oscap-scan.log
    SCAN_STATUS="SUCCESS"
else
    echo "$(date): OpenSCAP scan failed with error code $?" >> $LOG_DIR/oscap-scan.log
    SCAN_STATUS="FAILED"
fi

# Generate summary
FAILED_RULES=$(grep -c "result=\"fail\"" $REPORT_DIR/oscap-results-$SCAN_DATE.xml 2>/dev/null || echo "0")
PASSED_RULES=$(grep -c "result=\"pass\"" $REPORT_DIR/oscap-results-$SCAN_DATE.xml 2>/dev/null || echo "0")

# Create summary report
cat > $REPORT_DIR/scan-summary-$SCAN_DATE.txt << SUMMARY_EOF
OpenSCAP Security Scan Summary
==============================
Date: $(date)
Status: $SCAN_STATUS
Profile: $PROFILE
Failed Rules: $FAILED_RULES
Passed Rules: $PASSED_RULES
Report Location: $REPORT_DIR/oscap-report-$SCAN_DATE.html
Results Location: $REPORT_DIR/oscap-results-$SCAN_DATE.xml
SUMMARY_EOF

echo "$(date): Scan summary created at $REPORT_DIR/scan-summary-$SCAN_DATE.txt" >> $LOG_DIR/oscap-scan.log
