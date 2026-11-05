#!/bin/bash

POLICY_NAME="mywebapp_v2"
POLICY_DIR="/root/selinux-lab"
BACKUP_DIR="/root/selinux-backups"

# Create backup directory
mkdir -p $BACKUP_DIR

case "$1" in
    backup)
        echo "Backing up current policy..."
        semodule -E $POLICY_NAME -o $BACKUP_DIR/${POLICY_NAME}-$(date +%Y%m%d).pp
        echo "Backup completed: $BACKUP_DIR/${POLICY_NAME}-$(date +%Y%m%d).pp"
        ;;
    
    update)
        echo "Updating policy from source..."
        cd $POLICY_DIR
        make -f /usr/share/selinux/devel/Makefile ${POLICY_NAME}.pp
        semodule -u ${POLICY_NAME}.pp
        echo "Policy updated successfully"
        ;;
    
    remove)
        echo "Removing policy..."
        semodule -r $POLICY_NAME
        echo "Policy removed"
        ;;
    
    status)
        echo "Policy Status:"
        semodule -l | grep $POLICY_NAME
        echo "File contexts:"
        semanage fcontext -l | grep mywebapp
        ;;
    
    *)
        echo "Usage: $0 {backup|update|remove|status}"
        exit 1
        ;;
esac
