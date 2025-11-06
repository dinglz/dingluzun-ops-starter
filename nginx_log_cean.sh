#!/bin/bash

# Nginx 日志目录
LOG_DIR="/var/log/nginx"

# 日志文件前缀
LOG_PREFIX="access.log"

# 清理前的保留天数（例如，保留最近7天的日志）
RETENTION_DAYS=7

# 删除超过 RETENTION_DAYS 天的日志文件
find $LOG_DIR -name "${LOG_PREFIX}*" -type f -mtime +$RETENTION_DAYS -exec rm -f {} \;

echo "Nginx 日志清理完成！"
