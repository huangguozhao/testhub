-- 重命名 notification_config 表的 webhook_config 字段为 webhook_bots
-- 原 webhook_config 存储单个 webhook 配置: {"webhook": "url", "secret": "xxx"}
-- 新 webhook_bots 存储多机器人配置: {"feishu": {"name", "webhook_url", "enabled", ...}}
ALTER TABLE notification_config CHANGE COLUMN webhook_config webhook_bots TEXT COMMENT 'Webhook机器人配置(JSON)';
