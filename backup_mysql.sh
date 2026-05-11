#!/bin/bash
# MySQL 数据库定时备份脚本
# 备份 testhub_java 和 xxl_job 两个数据库

# 配置
CONTAINER_NAME="testhub-xxl-job-mysql"
BACKUP_DIR="D:/Project/testhub_platform/backup/mysql"
MYSQL_USER="root"
MYSQL_PASSWORD="root"
RETENTION_DAYS=7  # 保留最近 7 天的备份

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 生成时间戳
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATE_PREFIX=$(date +"%Y%m%d")

# 备份函数
backup_database() {
    local db_name=$1
    local output_file="${BACKUP_DIR}/${db_name}_${TIMESTAMP}.sql"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始备份数据库: $db_name"

    # 执行备份
    docker exec "$CONTAINER_NAME" mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --databases "$db_name" > "$output_file" 2>/dev/null

    if [ $? -eq 0 ]; then
        local file_size=$(du -h "$output_file" | cut -f1)
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 备份成功: $output_file (大小: $file_size)"
        return 0
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 备份失败: $db_name"
        return 1
    fi
}

# 清理旧备份（保留最近 N 天）
cleanup_old_backups() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 清理超过 ${RETENTION_DAYS} 天的旧备份..."
    find "$BACKUP_DIR" -name "*.sql" -mtime +$RETENTION_DAYS -delete
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 清理完成"
}

# 检查容器是否运行
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 错误: 容器 $CONTAINER_NAME 未运行，跳过备份"
    exit 1
fi

echo "========================================="
echo "MySQL 备份任务开始 - $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="

# 备份两个数据库
backup_database "testhub_java"
backup_database "xxl_job"

# 清理旧备份
cleanup_old_backups

echo "========================================="
echo "MySQL 备份任务完成 - $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="
