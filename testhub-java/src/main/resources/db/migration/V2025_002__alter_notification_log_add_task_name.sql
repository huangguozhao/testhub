-- 给 notification_log 表添加 task_name 字段
ALTER TABLE notification_log ADD COLUMN task_name VARCHAR(200) COMMENT '任务名称快照' AFTER task_id;
