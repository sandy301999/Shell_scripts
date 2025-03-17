================================================================
Task 1: Automate Log Rotation
Write a shell script that:

Finds all log files (*.log) in /var/log/myapp/.
Compresses log files older than 7 days into a .tar.gz archive.
Deletes compressed logs older than 30 days.
Logs its own actions to /var/log/myapp/log_rotation.log.
================================================================
Task 2: Monitor Disk Usage and Send Alerts
Write a shell script that:

Checks the disk usage of / (root) and /var partitions.
If usage exceeds 80%, log the warning to /var/log/disk_alert.log.
If usage exceeds 90%, send an email alert (use mail or sendmail).
================================================================
