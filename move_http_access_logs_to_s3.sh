#!/bin/bash

TODAY=$(date +%Y-%m-%d)
LOG_DIR="/var/log/httpd"
TMP_DIR="/tmp/logs-wave"
ARCHIVE_NAME="httpd_logs_$TODAY.tar.gz"

mkdir -p $TMP_DIR
cd $LOG_DIR
tar -czvf $ARCHIVE_NAME access_log error_log
mv $ARCHIVE_NAME $TMP_DIR/
aws s3 sync $TMP_DIR/ s3://my-ec2-logs-durga/
