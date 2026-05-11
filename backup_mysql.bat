@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

set BACKUP_DIR=D:\Project\testhub_platform\backup\mysql
set CONTAINER_NAME=testhub-xxl-job-mysql
set MYSQL_USER=root
set MYSQL_PASSWORD=root
set RETENTION_DAYS=7

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value') do set "dt=%%i"
set TIMESTAMP=!dt:~0,8!_!dt:~8,6!

echo =========================================
echo MySQL 备份任务开始
echo =========================================

echo 开始备份数据库: testhub_java
docker exec !CONTAINER_NAME! mysqldump -u!MYSQL_USER! -p!MYSQL_PASSWORD! --single-transaction --routines --triggers --events --databases testhub_java > "!BACKUP_DIR!\testhub_java_!TIMESTAMP!.sql" 2>nul
if !errorlevel! equ 0 (
    for %%F in ("!BACKUP_DIR!\testhub_java_!TIMESTAMP!.sql") do echo 备份成功: testhub_java_!TIMESTAMP!.sql
) else (
    echo 备份失败: testhub_java
)

echo 开始备份数据库: xxl_job
docker exec !CONTAINER_NAME! mysqldump -u!MYSQL_USER! -p!MYSQL_PASSWORD! --single-transaction --routines --triggers --events --databases xxl_job > "!BACKUP_DIR!\xxl_job_!TIMESTAMP!.sql" 2>nul
if !errorlevel! equ 0 (
    for %%F in ("!BACKUP_DIR!\xxl_job_!TIMESTAMP!.sql") do echo 备份成功: xxl_job_!TIMESTAMP!.sql
) else (
    echo 备份失败: xxl_job
)

echo 清理超过 !RETENTION_DAYS! 天的旧备份...
powershell -Command "Get-ChildItem '!BACKUP_DIR!\*.sql' | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-!RETENTION_DAYS!) } | Remove-Item -Force"

echo =========================================
echo MySQL 备份任务完成
echo =========================================
