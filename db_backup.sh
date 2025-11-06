#!/bin/bash

# MySQL 配置
DB_USER="root"
DB_PASSWORD="your_password"
DB_HOST="localhost"
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/db_backup_$DATE.sql"

# 创建备份目录（如果不存在）
mkdir -p $BACKUP_DIR

# 执行 MySQL 备份
mysqldump -u$DB_USER -p$DB_PASSWORD -h$DB_HOST --all-databases > $BACKUP_FILE

# 输出备份信息
if [ $? -eq 0 ]; then
    echo "数据库备份成功：$BACKUP_FILE"
else
    echo "数据库备份失败！"
fi
