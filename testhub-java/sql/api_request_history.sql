-- =========================================
-- API请求历史记录表
-- 添加日期: 2026-04-30
-- =========================================

-- 如果已存在则删除旧表
-- DROP TABLE IF EXISTS api_request_history;

CREATE TABLE IF NOT EXISTS api_request_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    request_id BIGINT NOT NULL COMMENT 'API请求ID',
    suite_execution_id BIGINT COMMENT '套件执行记录ID',
    method VARCHAR(20) NOT NULL COMMENT 'HTTP方法',
    url TEXT NOT NULL COMMENT '请求URL',
    request_headers TEXT COMMENT '请求头(JSON)',
    request_body TEXT COMMENT '请求体',
    response_status_code INT COMMENT '响应状态码',
    response_headers TEXT COMMENT '响应头(JSON)',
    response_body TEXT COMMENT '响应体',
    response_time BIGINT COMMENT '响应时间(毫秒)',
    assertions TEXT COMMENT '断言结果(JSON)',
    extracted_variables TEXT COMMENT '提取变量(JSON)',
    success TINYINT(1) DEFAULT FALSE COMMENT '是否成功',
    error_message TEXT COMMENT '错误信息',
    executed_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间',
    executed_by BIGINT COMMENT '执行人ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_request_id (request_id),
    INDEX idx_executed_at (executed_at),
    INDEX idx_suite_execution_id (suite_execution_id),
    INDEX idx_success (success)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API请求历史记录表';
