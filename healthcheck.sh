#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print timestamped message
timestamp() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

##############################
# Function: Check System Uptime
##############################
check_uptime() {
    local uptime_days
    uptime_days=$(awk '{print int($1/86400) " days"}' /proc/uptime)
    timestamp "System Uptime: $uptime_days"
    echo ""
}

##################################
# Function: Check Disk Usage
##################################
check_disk_usage() {
    timestamp "Disk Usage Check:"
    df -h | awk 'NR>1 {print $1, $5}' | while read fs per; do
        usage=${per%\%}  # remove %
        if [ "$usage" -gt 80 ]; then
            echo -e "${RED}FAILED${NC} :: $fs usage is $per (above 80%)"
        else
            echo -e "${GREEN}PASS${NC} :: $fs usage is $per"
        fi
    done
    echo ""
}

##################################
# Function: Check Load Average
##################################
check_load() {
    local nproc load1
    nproc=$(nproc)
    load1=$(uptime | awk -F'load average: ' '{print $2}' | awk -F, '{print $1}')

    if (( $(echo "$load1 <= $nproc" | bc -l) )); then
        echo -e "$(timestamp "Load Check:") ${GREEN}PASS${NC} ($load1 / $nproc cores)"
    else
        echo -e "$(timestamp "Load Check:") ${RED}FAIL${NC} ($load1 / $nproc cores)"
    fi
    echo ""
}

##################################
# Function: Check Kernel Version
##################################
check_kernel() {
    timestamp "Kernel Version: $(uname -r)"
    echo ""
}

##################################
# Function: Check MySQL
##################################
check_mysql() {
    timestamp "Checking MySQL Process..."
    if pgrep -x "mysqld" > /dev/null; then
        echo -e "${GREEN}PASS${NC} :: MySQL is running"
        # Placeholder for replication check
    else
        echo -e "${RED}FAIL${NC} :: MySQL is NOT running"
    fi
    echo ""
}

##################################
# Function: Check Critical Services
##################################
check_services() {
    local services=("DIDOMAIN_AFAD1" "DIDAI_DFMgr1")
    local failed=0

    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            echo -e "$(timestamp "$svc") ${GREEN}PASS${NC} :: Running"
        else
            echo -e "$(timestamp "$svc") ${RED}FAIL${NC} :: NOT running"
            failed=$((failed+1))
        fi
    done

    if [ "$failed" -eq "${#services[@]}" ]; then
        echo -e "${RED}CRITICAL: Both critical services are down!${NC}"
        exit 1
    fi
    echo ""
}

##############################
# Main Script Execution
##############################

timestamp "Starting System Healthcheck..."
sleep 1

check_uptime
sleep 1

check_disk_usage
sleep 1

check_load
sleep 1

check_kernel
sleep 1

check_mysql
sleep 1

check_services

timestamp "System Healthcheck Completed."
