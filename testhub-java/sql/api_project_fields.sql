-- =========================================
-- API项目表字段补充
-- =========================================

-- 添加缺失字段到 api_project 表（兼容 MySQL 5.7+）
ALTER TABLE api_project
ADD COLUMN project_type VARCHAR(20) DEFAULT 'HTTP' COMMENT '项目类型: HTTP, WEBSOCKET' AFTER description;

ALTER TABLE api_project
ADD COLUMN status VARCHAR(20) DEFAULT 'NOT_STARTED' COMMENT '项目状态: NOT_STARTED, IN_PROGRESS, COMPLETED' AFTER project_type;

ALTER TABLE api_project
ADD COLUMN start_date DATE NULL COMMENT '开始日期' AFTER status;

ALTER TABLE api_project
ADD COLUMN end_date DATE NULL COMMENT '结束日期' AFTER start_date;

ALTER TABLE api_project
ADD COLUMN owner_id BIGINT NULL COMMENT '负责人ID' AFTER end_date;

ALTER TABLE api_project
ADD INDEX idx_owner_id (owner_id);

-- =========================================
-- API项目成员表（多对多关系）
-- =========================================
CREATE TABLE IF NOT EXISTS api_project_member (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    project_id BIGINT NOT NULL COMMENT 'API项目ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role VARCHAR(20) DEFAULT 'member' COMMENT '角色: owner, admin, member',
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    is_deleted TINYINT DEFAULT 0 COMMENT '是否删除',
    UNIQUE KEY uk_project_user (project_id, user_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API项目成员表';

-- =========================================
-- 更新现有数据
-- =========================================
-- 现有项目补充 owner_id（使用 created_by 作为 owner）
UPDATE api_project SET owner_id = created_by WHERE owner_id IS NULL AND created_by IS NOT NULL;

-- 现有项目补充 project_type 和 status 默认值
UPDATE api_project SET project_type = 'HTTP' WHERE project_type IS NULL OR project_type = '';
UPDATE api_project SET status = 'IN_PROGRESS' WHERE status IS NULL OR status = '';
