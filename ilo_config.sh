#!/bin/bash

# === COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "[$(date '+%F %T')] $1"; }
pass() { echo -e "${GREEN}PASS${NC} :: $1"; }
fail() { echo -e "${RED}FAIL${NC} :: $1"; }
warn() { echo -e "${YELLOW}WARN${NC} :: $1"; }

# === Usage ===
usage() {
    echo "Usage: $0 <ILO_IP> <SUBNET_MASK> <GATEWAY>"
    echo "Example: $0 192.168.1.50 255.255.255.0 192.168.1.1"
    exit 1
}

# === Check arguments ===
if [ $# -ne 3 ]; then
    usage
fi

ILO_IP=$1
SUBNET_MASK=$2
GATEWAY=$3
TMP_FILE="/tmp/ilo.out"

# === Step 1: Dump current iLO configuration ===
log "Dumping current iLO configuration..."
hponcfg -w $TMP_FILE
if [ $? -ne 0 ]; then
    fail "Failed to dump iLO configuration. Make sure hponcfg is installed and run as root."
    exit 1
fi
pass "iLO configuration dumped to $TMP_FILE"

# === Step 2: Modify the XML automatically ===
log "Modifying iLO configuration..."

# Disable DHCP settings
sed -i 's/\(<DHCP_ENABLE>\).*\(<\/DHCP_ENABLE>\)/\1N\2/' $TMP_FILE
sed -i 's/\(<DHCP_GATEWAY>\).*\(<\/DHCP_GATEWAY>\)/\1N\2/' $TMP_FILE
sed -i 's/\(<DHCP_DNS_SERVER>\).*\(<\/DHCP_DNS_SERVER>\)/\1N\2/' $TMP_FILE
sed -i 's/\(<DHCP_STATIC_ROUTE>\).*\(<\/DHCP_STATIC_ROUTE>\)/\1N\2/' $TMP_FILE
sed -i 's/\(<DHCP_WINS_SERVER>\).*\(<\/DHCP_WINS_SERVER>\)/\1N\2/' $TMP_FILE

# Set static IP configuration
sed -i "s/\(<IP_ADDRESS>\).*\(<\/IP_ADDRESS>\)/\1$ILO_IP\2/" $TMP_FILE
sed -i "s/\(<SUBNET_MASK>\).*\(<\/SUBNET_MASK>\)/\1$SUBNET_MASK\2/" $TMP_FILE
sed -i "s/\(<GATEWAY_IP_ADDRESS>\).*\(<\/GATEWAY_IP_ADDRESS>\)/\1$GATEWAY\2/" $TMP_FILE

pass "iLO configuration updated in $TMP_FILE"

# === Step 3: Apply the new configuration ===
log "Applying new iLO configuration..."
hponcfg -f $TMP_FILE
if [ $? -ne 0 ]; then
    fail "Failed to apply iLO configuration."
    exit 1
fi
pass "iLO configuration applied successfully"

# === Step 4: Clean up ===
log "Cleaning up temporary file..."
rm -f $TMP_FILE
pass "Temporary file $TMP_FILE removed"

log "===== iLO Configuration Automation Completed Successfully ====="
