-- 创建定时任务通知设置表
CREATE TABLE IF NOT EXISTS api_task_notification_settings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    task_id BIGINT NOT NULL COMMENT '关联的定时任务ID',
    notification_type VARCHAR(20) NOT NULL DEFAULT 'both' COMMENT '通知类型: email/webhook/both',
    notification_config_id BIGINT COMMENT '通知配置ID (关联 notification_config 表)',
    is_enabled TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用通知',
    notify_on_success TINYINT(1) NOT NULL DEFAULT 1 COMMENT '成功时通知',
    notify_on_failure TINYINT(1) NOT NULL DEFAULT 1 COMMENT '失败时通知',
    notify_on_timeout TINYINT(1) NOT NULL DEFAULT 0 COMMENT '超时时通知',
    notify_on_error TINYINT(1) NOT NULL DEFAULT 1 COMMENT '错误时通知',
    custom_webhook_bots JSON COMMENT '自定义Webhook机器人配置',
    custom_recipients JSON COMMENT '自定义收件人邮箱列表',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    is_deleted TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否删除',
    UNIQUE KEY uk_task_id (task_id),
    KEY idx_notification_type (notification_type),
    KEY idx_is_enabled (is_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='定时任务通知设置';
