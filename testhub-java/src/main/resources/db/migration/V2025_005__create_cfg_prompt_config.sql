CREATE TABLE IF NOT EXISTS cfg_prompt_config (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '配置名称',
    prompt_type VARCHAR(20) NOT NULL COMMENT '提示词类型: writer/reviewer',
    content TEXT NOT NULL COMMENT '提示词内容',
    is_enabled TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    is_deleted TINYINT(1) DEFAULT 0 COMMENT '逻辑删除',
    created_by BIGINT COMMENT '创建者ID',
    updated_by BIGINT COMMENT '更新者ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_prompt_type (prompt_type),
    INDEX idx_is_enabled (is_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='提示词配置表';
