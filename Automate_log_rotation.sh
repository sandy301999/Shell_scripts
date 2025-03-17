#!/bin/sh

# Compress log files older than 7 days
#If a file is named my file.txt, xargs will treat my and file.txt as two separate arguments, causing it to fail so use print0 & -0
find /var/log/myapp/ -type f -name "*.log" -mtime +7 -print0 | xargs -0 tar -czvf weekly_log_files.tar.gz

# Move the compressed archive to archive directory
mv weekly_log_files.tar.gz /var/log/myapp/archive/

# Remove compressed logs older than 30 days
find /var/log/myapp/archive/ -type f -name "*.tar.gz" -mtime +30 -exec rm -rf {} +

# Log the operation
echo "$(date): Log rotation completed" >> /var/log/myapp/log_rotation.log
