#!/bin/bash
# AIDE Automated Monitoring Script
# This script performs AIDE checks and handles alerting

# Configuration variables
AIDE_CONFIG="/etc/aide.conf"
AIDE_DB="/var/lib/aide/aide.db.gz"
LOG_DIR="/var/log/aide"
REPORT_FILE="$LOG_DIR/aide-report-$(date +%Y%m%d-%H%M%S).log"
ALERT_EMAIL="admin@company.com"
ALERT_THRESHOLD=1

# Ensure log directory exists
mkdir -p $LOG_DIR

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_DIR/aide-monitor.log
}

# Function to send alerts
send_alert() {
    local message="$1"
    log_message "ALERT: $message"
    
    # Send email alert (requires mail command)
    if command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "AIDE Security Alert - $(hostname)" $ALERT_EMAIL
    fi
    
    # Log to syslog
    logger -p security.warning "AIDE: $message"
}

# Function to update AIDE database
update_database() {
    log_message "Updating AIDE database..."
    if aide --init >/dev/null 2>&1; then
        mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
        log_message "Database updated successfully"
        return 0
    else
        log_message "ERROR: Failed to update database"
        return 1
    fi
}

# Function to perform AIDE check
perform_check() {
    log_message "Starting AIDE integrity check..."
    
    # Run AIDE check and capture output
    aide --check > $REPORT_FILE 2>&1
    local exit_code=$?
    
    # Analyze results
    if [ $exit_code -eq 0 ]; then
        log_message "No changes detected - system integrity maintained"
        return 0
    else
        local changes=$(grep -c "^changed:\|^added:\|^removed:" $REPORT_FILE)
        
        if [ $changes -gt $ALERT_THRESHOLD ]; then
            send_alert "File system integrity violation detected! $changes changes found. Check $REPORT_FILE for details."
        fi
        
        log_message "Changes detected: $changes files modified"
        return 1
    fi
}

# Function to generate summary report
generate_summary() {
    local report_file="$1"
    local summary_file="$LOG_DIR/aide-summary-$(date +%Y%m%d).log"
    
    echo "=== AIDE Security Summary Report ===" > $summary_file
    echo "Generated: $(date)" >> $summary_file
    echo "Hostname: $(hostname)" >> $summary_file
    echo "====================================" >> $summary_file
    
    if [ -f "$report_file" ]; then
        echo "Changes Summary:" >> $summary_file
        grep "^changed:" $report_file | wc -l | xargs echo "Modified files:" >> $summary_file
        grep "^added:" $report_file | wc -l | xargs echo "Added files:" >> $summary_file
        grep "^removed:" $report_file | wc -l | xargs echo "Removed files:" >> $summary_file
        echo "" >> $summary_file
        
        echo "Detailed Changes:" >> $summary_file
        grep "^changed:\|^added:\|^removed:" $report_file >> $summary_file
    fi
    
    log_message "Summary report generated: $summary_file"
}

# Main execution
main() {
    log_message "AIDE monitoring script started"
    
    # Check if AIDE database exists
    if [ ! -f "$AIDE_DB" ]; then
        log_message "AIDE database not found. Initializing..."
        update_database
    fi
    
    # Perform integrity check
    if perform_check; then
        log_message "Integrity check completed successfully"
    else
        log_message "Integrity violations detected"
        generate_summary $REPORT_FILE
    fi
    
    log_message "AIDE monitoring script completed"
}

# Handle command line arguments
case "$1" in
    --init)
        update_database
        ;;
    --check)
        perform_check
        ;;
    --update)
        update_database
        ;;
    *)
        main
        ;;
esac
