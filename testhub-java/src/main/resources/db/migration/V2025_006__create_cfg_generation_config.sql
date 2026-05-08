CREATE TABLE IF NOT EXISTS cfg_generation_config (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL DEFAULT '默认生成配置' COMMENT '配置名称',
    default_output_mode VARCHAR(10) NOT NULL DEFAULT 'stream' COMMENT '默认输出模式: stream/complete',
    enable_auto_review TINYINT(1) DEFAULT 1 COMMENT '启用AI评审',
    review_timeout INT DEFAULT 120 COMMENT '评审超时时间(秒)',
    is_enabled TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    is_deleted TINYINT(1) DEFAULT 0 COMMENT '逻辑删除',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='生成行为配置表';
