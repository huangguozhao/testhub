-- =========================================
-- 修复 prj_project_environment 表结构
-- 添加 base_url 字段
-- 执行日期: 2026-04-29
-- =========================================

USE testhub_java;

-- 添加 base_url 字段
ALTER TABLE prj_project_environment
ADD COLUMN base_url VARCHAR(500) DEFAULT '' COMMENT '基础URL' AFTER name;
