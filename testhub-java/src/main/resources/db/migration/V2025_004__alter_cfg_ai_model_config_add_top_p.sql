-- 给 cfg_ai_model_config 表添加 top_p 列
ALTER TABLE cfg_ai_model_config ADD COLUMN top_p DECIMAL(3,2) DEFAULT 0.90 COMMENT 'Top P参数' AFTER temperature;
