#!/bin/bash

# Configuration
LOG_DIR="/ibus/FLPROD/logs"
ARC_LOG="/ibus/arcview"
ALERT_LOG="/tmp/daily_log_alerts_$(date +%F).log"
RETENTION_DAYS=15
EMAIL="sandesh.cta506@gmail.com"

# Ensure archive directory exists
mkdir -p "$ARC_LOG"

# Define today's log file path
TODAY_LOG="$LOG_DIR/ibus_$(date +%F).log"

if [[ ! -f "$TODAY_LOG" ]]; then
    echo "Log not found for Today - $(date +%F)"
    exit 1
fi

# Extract critical logs
grep -Ei "error|fail|warning" "$TODAY_LOG" > "$ALERT_LOG"

# Alert or cleanup
if [[ -s "$ALERT_LOG" ]]; then
    echo "Sending alerts to $EMAIL..."
    mail -s "Daily Alert: Errors found in logs - $(date +%F)" "$EMAIL" < "$ALERT_LOG"
else
    echo "No Critical logs found for today"
    rm -f "$ALERT_LOG"
fi

# Archive yesterday's log
YESTERDAY=$(date --date="yesterday" +%F)
YESTERDAY_LOG="$LOG_DIR/ibus_${YESTERDAY}.log"

if [[ -f "$YESTERDAY_LOG" ]]; then
    tar -czf "$ARC_LOG/ibus_${YESTERDAY}.tar.gz" "$YESTERDAY_LOG" && rm -f "$YESTERDAY_LOG"
    echo "Archived yesterday's log: $YESTERDAY_LOG"
fi

# Cleanup old archives
find "$ARC_LOG" -name "*.tar.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

echo "Old logs cleanup done."
exit 0
