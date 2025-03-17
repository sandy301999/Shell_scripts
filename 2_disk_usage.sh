#!/bin/sh

# Define thresholds and variables
warn=80
crit=90
log_file="/var/log/disk_alert.log"
email="sandesh.cta506@gmail.com"
partitions=("/" "/var")

# Function to check disk usage
check_disk() {
    for i in "${partitions[@]}"; do
        usage=$(df -h "$i" | awk 'NR==2 {print $5}' | sed 's/%//')  # Get usage percentage

        if [ "$usage" -ge "$crit" ]; then
            echo "$(date): CRITICAL - $i is at ${usage}%" >> "$log_file"
            echo "$(date): CRITICAL - $i is at ${usage}%" | mail -s "Critical Disk Usage Alert: $i" "$email"
        elif [ "$usage" -ge "$warn" ]; then
            echo "$(date): WARNING - $i is at ${usage}%" >> "$log_file"
        fi
    done
}

# Run the disk check
check_disk
