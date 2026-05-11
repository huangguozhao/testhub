# MySQL Backup Script

$ContainerName = "testhub-xxl-job-mysql"
$BackupDir = "D:\Project\testhub_platform\backup\mysql"
$MySqlUser = "root"
$MySqlPassword = "root"
$RetentionDays = 7

if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "========================================="
Write-Host "MySQL Backup Start"
Write-Host "========================================="

$container = docker ps --format "{{.Names}}" | Where-Object { $_ -eq $ContainerName }
if (-not $container) {
    Write-Host "[ERROR] Container $ContainerName is not running"
    exit 1
}

function Backup-Database {
    param([string]$DbName)
    $outputFile = Join-Path $BackupDir "${DbName}_${Timestamp}.sql"
    Write-Host "Backing up: $DbName"
    $cmd = "docker exec $ContainerName mysqldump -u$MySqlUser -p$MySqlPassword --single-transaction --routines --triggers --events --databases $DbName"
    Invoke-Expression $cmd 2>$null | Out-File -FilePath $outputFile -Encoding utf8
    if ($LASTEXITCODE -eq 0) {
        $fileInfo = Get-Item $outputFile
        $sizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
        Write-Host "  OK: $outputFile ($sizeKB KB)"
    } else {
        Write-Host "  FAILED: $DbName"
    }
}

Backup-Database -DbName "testhub_java"
Backup-Database -DbName "xxl_job"

Write-Host ""
Write-Host "Cleaning backups older than $RetentionDays days..."
$cutoffDate = (Get-Date).AddDays(-$RetentionDays)
Get-ChildItem -Path $BackupDir -Filter "*.sql" | Where-Object { $_.LastWriteTime -lt $cutoffDate } | ForEach-Object {
    Write-Host "  Deleted: $($_.Name)"
    Remove-Item $_.FullName -Force
}

Write-Host ""
Write-Host "========================================="
Write-Host "MySQL Backup Complete"
Write-Host "========================================="
