-- ============================================
-- TestHub Java版本 测试数据清理脚本
-- 执行前请备份数据库
-- ============================================

-- 设置最大执行时间（防止锁表）
SET SESSION MAX_EXECUTION_TIME=30000;

-- 开启事务（可选，回滚用）
-- START TRANSACTION;

-- ============================================
-- 1. 清理测试项目 (TEST_ 前缀)
-- ============================================
DELETE FROM project_environments WHERE project_id IN (
    SELECT id FROM projects WHERE name LIKE 'TEST_%'
);
DELETE FROM project_members WHERE project_id IN (
    SELECT id FROM projects WHERE name LIKE 'TEST_%'
);
DELETE FROM projects WHERE name LIKE 'TEST_%';

-- ============================================
-- 2. 清理测试API项目
-- ============================================
DELETE FROM api_request_histories WHERE request_id IN (
    SELECT id FROM api_requests WHERE collection_id IN (
        SELECT id FROM api_collections WHERE name LIKE 'TEST_%'
    )
);
DELETE FROM api_requests WHERE collection_id IN (
    SELECT id FROM api_collections WHERE name LIKE 'TEST_%'
);
DELETE FROM api_collections WHERE name LIKE 'TEST_%';
DELETE FROM api_environments WHERE name LIKE '测试%';
DELETE FROM api_projects WHERE name LIKE 'TEST_%';

-- ============================================
-- 3. 清理测试套件
-- ============================================
DELETE FROM api_scheduled_tasks WHERE suite_id IN (
    SELECT id FROM api_test_suites WHERE name LIKE 'TEST_%'
);
DELETE FROM api_test_suites WHERE name LIKE 'TEST_%';

-- ============================================
-- 4. 清理测试通知配置
-- ============================================
DELETE FROM notification_logs WHERE config_id IN (
    SELECT id FROM notification_configs WHERE name LIKE '测试%'
);
DELETE FROM notification_configs WHERE name LIKE '测试%';

-- ============================================
-- 5. 清理测试操作日志
-- ============================================
DELETE FROM operation_logs WHERE description LIKE '%测试%' OR description LIKE '%TEST%';

-- ============================================
-- 6. 清理测试用户
-- ============================================
DELETE FROM user_profiles WHERE user_id IN (
    SELECT id FROM users WHERE username LIKE 'test_user_%'
);
DELETE FROM users WHERE username LIKE 'test_user_%';

-- ============================================
-- 7. 清理过期请求历史记录
-- ============================================
DELETE FROM api_request_histories WHERE executed_at < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- ============================================
-- 8. 清理过期操作日志
-- ============================================
DELETE FROM operation_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- ============================================
-- 提交或回滚
-- ============================================
-- 提交更改
COMMIT;

-- 如需回滚，执行：
-- ROLLBACK;

-- ============================================
-- 验证清理结果
-- ============================================
SELECT '清理完成' AS status;
SELECT COUNT(*) AS remaining_test_projects FROM projects WHERE name LIKE 'TEST_%';
SELECT COUNT(*) AS remaining_test_users FROM users WHERE username LIKE 'test_user_%';
