#!/bin/bash
clear

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"
SEPARATOR="--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--"

# Basic System Info
echo -e "${GREEN}Hostname: $(hostname 2>/dev/null)"
echo -e "Uptime: $(uptime 2>/dev/null | awk '{gsub(/,/, "", $4); print $3, $4}')"
echo -e "Kernel: $(uname -r 2>/dev/null)"
echo -e "OS Version: $(cat /etc/system-release 2>/dev/null)"
echo -e "MySQL Version: $(mysql -V 2>/dev/null)"
echo -e "Containers Running (esmadmin): $(ps -fu esmadmin 2>/dev/null | wc -l)${RESET}"
echo -e "${SEPARATOR}"

# DIDOMAIN check
if ll /ibus 2>/dev/null | grep -q "DIDOMAIN"; then
  echo -e "${GREEN}DIDOMAIN Entries:"
  ll /ibus 2>/dev/null | grep "DIDOMAIN" | awk -F'DIDOMAIN_' '{print "\033[32m" $2 "\033[0m"}'
else
  echo -e "${RED}domain not present.${RESET}"
fi
echo -e "${SEPARATOR}"

# Hardware Model and Product Check
PRODUCT_NAME=$(dmidecode | grep -i "Product Name" | head -n 1 | awk -F':' '{print $2}' | xargs)
echo -e "${GREEN}Product Name (DMIDECODE): ${PRODUCT_NAME}${RESET}"
echo -e "${SEPARATOR}"

# Skip iLO DNS/IP for VMware VMs
if [[ "$PRODUCT_NAME" == *"VMware"* ]]; then
  echo -e "${YELLOW}VMware VM detected - skipping iLO DNS/IP lookup.${RESET}"
else
  ILO_SERIAL=$(dmidecode --type 1 2>/dev/null | grep 'Serial Number' | awk '{print $3}')
  IPMI_IP=$(ipmitool lan print 2>/dev/null | grep '^IP Address  ' | awk '{print $NF}')
  echo -e "${GREEN}DNS: https://iLO${ILO_SERIAL}.cernerasp.com"
  echo -e "IP: https://${IPMI_IP}${RESET}"
fi
echo -e "${SEPARATOR}"

# MySQL Replication Check
echo -e "${GREEN}Checking MySQL replication status...${RESET}"
REPL_OUTPUT=$(mysql -u root -p@dmin1 -h 127.0.0.1 -e "SHOW SLAVE STATUS \G" 2>&1)

if echo "$REPL_OUTPUT" | grep -q "Access denied for user"; then
  echo -e "${YELLOW}MySQL access denied - likely incorrect password.${RESET}"
  hostname=$(hostname)
  fqdn=$(hostname -f)
  altid=$(echo "${hostname//mdbus/}" | sed 's/[0-9]*//g; s/\(.*\)\(..\)$/\U\1_\U2/')
  echo -e "${YELLOW}For password, visit:${RESET}"
  echo -e "  https://vault.cerner.com/vault/msvs?alternateid=${altid}&server=${hostname^^}"
  echo -e "  https://cwx2.cerner.com/myremedy/system/${fqdn}"
elif [[ -z "$REPL_OUTPUT" || "$REPL_OUTPUT" == *"Empty set."* ]]; then
  echo -e "${YELLOW}MySQL is running but not clustered (replication not configured).${RESET}"
else
  echo -e "${GREEN}MySQL replication status:${RESET}"
  echo "$REPL_OUTPUT" | grep -iE "Slave_IO_State|Slave_.*_Running|Master_Host|Seconds_Behind_Master|Last_Err.*|Last_IO_Err.*|Last_SQL_Err.*" || echo -e "${YELLOW}Replication active but no matching fields to display.${RESET}"
fi
echo -e "${SEPARATOR}"

# CWX Health Check
echo -e "${GREEN}#### Running CWX Health Check ####${RESET}"
/ibus/ibus-automation-utils/cwx_health_check.sh || echo -e "${YELLOW}Health check script not found or failed to run.${RESET}"
echo -e "${SEPARATOR}"
