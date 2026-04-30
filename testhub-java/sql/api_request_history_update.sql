-- =========================================
-- API请求历史记录表 - 补充缺失列
-- 添加日期: 2026-04-30
-- =========================================

-- 添加缺失的列 (使用存储过程检查是否存在)
DELIMITER //

DROP PROCEDURE IF EXISTS add_column_if_not_exists//

CREATE PROCEDURE add_column_if_not_exists()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'suite_execution_id') THEN
        ALTER TABLE api_request_history ADD COLUMN suite_execution_id BIGINT COMMENT '套件执行记录ID' AFTER request_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'request_headers') THEN
        ALTER TABLE api_request_history ADD COLUMN request_headers TEXT COMMENT '请求头(JSON)' AFTER url;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'request_body') THEN
        ALTER TABLE api_request_history ADD COLUMN request_body TEXT COMMENT '请求体' AFTER request_headers;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'response_status_code') THEN
        ALTER TABLE api_request_history ADD COLUMN response_status_code INT COMMENT '响应状态码' AFTER request_body;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'response_headers') THEN
        ALTER TABLE api_request_history ADD COLUMN response_headers TEXT COMMENT '响应头(JSON)' AFTER response_status_code;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'response_body') THEN
        ALTER TABLE api_request_history ADD COLUMN response_body TEXT COMMENT '响应体' AFTER response_headers;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'response_time') THEN
        ALTER TABLE api_request_history ADD COLUMN response_time BIGINT COMMENT '响应时间(毫秒)' AFTER response_body;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'assertions') THEN
        ALTER TABLE api_request_history ADD COLUMN assertions TEXT COMMENT '断言结果(JSON)' AFTER response_time;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'extracted_variables') THEN
        ALTER TABLE api_request_history ADD COLUMN extracted_variables TEXT COMMENT '提取变量(JSON)' AFTER assertions;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'success') THEN
        ALTER TABLE api_request_history ADD COLUMN success TINYINT(1) DEFAULT FALSE COMMENT '是否成功' AFTER extracted_variables;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'error_message') THEN
        ALTER TABLE api_request_history ADD COLUMN error_message TEXT COMMENT '错误信息' AFTER success;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'executed_at') THEN
        ALTER TABLE api_request_history ADD COLUMN executed_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间' AFTER error_message;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'executed_by') THEN
        ALTER TABLE api_request_history ADD COLUMN executed_by BIGINT COMMENT '执行人ID' AFTER executed_at;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'api_request_history'
                   AND COLUMN_NAME = 'created_at') THEN
        ALTER TABLE api_request_history ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER executed_by;
    END IF;
END//

DELIMITER ;

-- 执行存储过程
CALL add_column_if_not_exists();

-- 删除存储过程
DROP PROCEDURE IF EXISTS add_column_if_not_exists;
