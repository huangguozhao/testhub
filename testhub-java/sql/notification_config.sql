-- =========================================
-- 通知配置表
-- 添加日期: 2026-04-30
-- =========================================

CREATE TABLE IF NOT EXISTS notification_config (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    name VARCHAR(100) NOT NULL COMMENT '配置名称',
    config_type VARCHAR(50) NOT NULL COMMENT '配置类型: webhook_feishu, webhook_wechat, webhook_dingtalk, email',
    webhook_config TEXT COMMENT 'Webhook配置(JSON)',
    is_default TINYINT(1) DEFAULT FALSE COMMENT '是否默认',
    is_active TINYINT(1) DEFAULT TRUE COMMENT '是否启用',
    remark TEXT COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    is_deleted TINYINT(1) DEFAULT FALSE COMMENT '是否删除',
    INDEX idx_config_type (config_type),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知配置表';

-- =========================================
-- 通知日志表
-- 添加日期: 2026-04-30
-- =========================================

CREATE TABLE IF NOT EXISTS notification_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    task_id BIGINT COMMENT '关联任务ID',
    task_type VARCHAR(50) COMMENT '任务类型: api_test, ui_automation, app_automation',
    notification_type VARCHAR(50) DEFAULT 'manual' COMMENT '通知类型: task_execution, system_alert, manual',
    channel VARCHAR(20) NOT NULL COMMENT '通知渠道: feishu, wechat, dingtalk, email',
    status VARCHAR(20) DEFAULT 'pending' COMMENT '发送状态: pending, sending, success, failed',
    config_id BIGINT COMMENT '通知配置ID',
    recipient_info TEXT COMMENT '收件人信息(JSON)',
    content TEXT COMMENT '通知内容(JSON)',
    error_message TEXT COMMENT '错误信息',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    sent_at DATETIME COMMENT '发送时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    is_deleted TINYINT(1) DEFAULT FALSE COMMENT '是否删除',
    INDEX idx_task_id (task_id),
    INDEX idx_task_type (task_type),
    INDEX idx_channel (channel),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知日志表';
