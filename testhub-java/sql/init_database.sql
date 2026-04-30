-- =========================================
-- TestHub Java 版本数据库表结构
-- 数据库名: testhub_java
-- 字符集: utf8mb4
-- 排序规则: utf8mb4_general_ci
-- 创建日期: 2026-04-29
-- =========================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS testhub_java DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE testhub_java;

-- =========================================
-- 系统表 (sys_)
-- =========================================

-- 用户表
CREATE TABLE IF NOT EXISTS sys_user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    password VARCHAR(255) NOT NULL COMMENT '密码(BCrypt加密)',
    real_name VARCHAR(50) COMMENT '真实姓名',
    phone VARCHAR(20) COMMENT '手机号',
    avatar VARCHAR(500) COMMENT '头像URL',
    status VARCHAR(20) NOT NULL DEFAULT 'enabled' COMMENT '状态: enabled=启用, disabled=禁用',
    role_name VARCHAR(50) NOT NULL DEFAULT 'USER' COMMENT '角色: ADMIN=管理员, USER=普通用户',
    is_superuser TINYINT NOT NULL DEFAULT 0 COMMENT '是否超级管理员: 0=否, 1=是',
    is_staff TINYINT NOT NULL DEFAULT 0 COMMENT '是否可以登录管理后台: 0=否, 1=是',
    last_login_time DATETIME COMMENT '最后登录时间',
    last_login_ip VARCHAR(50) COMMENT '最后登录IP',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_role_name (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 用户配置表
CREATE TABLE IF NOT EXISTS sys_user_profile (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    user_id BIGINT NOT NULL UNIQUE COMMENT '用户ID',
    theme VARCHAR(20) NOT NULL DEFAULT 'light' COMMENT '主题: light=浅色, dark=深色',
    language VARCHAR(20) NOT NULL DEFAULT 'zh-hans' COMMENT '语言: zh-hans=简体中文, en-us=英文',
    timezone VARCHAR(50) NOT NULL DEFAULT 'Asia/Shanghai' COMMENT '时区',
    bio VARCHAR(500) COMMENT '个人简介',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户配置表';

-- Token 黑名单表
CREATE TABLE IF NOT EXISTS sys_token_blacklist (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    token_id VARCHAR(100) NOT NULL UNIQUE COMMENT 'Token JTI(唯一标识)',
    user_id BIGINT COMMENT '用户ID',
    expire_time DATETIME NOT NULL COMMENT 'Token过期时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入黑名单时间',
    remark VARCHAR(500) COMMENT '备注',
    INDEX idx_token_id (token_id),
    INDEX idx_user_id (user_id),
    INDEX idx_expire_time (expire_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Token黑名单表';

-- =========================================
-- 项目表 (prj_)
-- =========================================

-- 项目表
CREATE TABLE IF NOT EXISTS prj_project (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '项目ID',
    name VARCHAR(100) NOT NULL COMMENT '项目名称',
    description TEXT COMMENT '项目描述',
    status VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT '状态: active=进行中, paused=暂停, completed=已完成, archived=已归档',
    owner_id BIGINT NOT NULL COMMENT '项目负责人ID',
    icon VARCHAR(500) COMMENT '项目图标',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    include_test_cases TINYINT NOT NULL DEFAULT 1 COMMENT '是否包含测试用例: 0=否, 1=是',
    include_automated_tests TINYINT NOT NULL DEFAULT 0 COMMENT '是否包含自动化测试: 0=否, 1=是',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_owner_id (owner_id),
    INDEX idx_status (status),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目表';

-- 项目成员表
CREATE TABLE IF NOT EXISTS prj_project_member (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role VARCHAR(20) NOT NULL DEFAULT 'tester' COMMENT '角色: owner=负责人, admin=管理员, developer=开发者, tester=测试者, viewer=观察者',
    joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    UNIQUE KEY uk_project_user (project_id, user_id),
    INDEX idx_project_id (project_id),
    INDEX idx_user_id (user_id),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目成员表';

-- 项目环境表
CREATE TABLE IF NOT EXISTS prj_project_environment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '环境ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(50) NOT NULL COMMENT '环境名称',
    base_url VARCHAR(500) DEFAULT '' COMMENT '基础URL',
    description VARCHAR(200) COMMENT '环境描述',
    variables JSON COMMENT '环境变量(JSON格式)',
    is_default TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认环境: 0=否, 1=是',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目环境表';

-- =========================================
-- 测试用例表 (tc_)
-- =========================================

-- 测试用例表
CREATE TABLE IF NOT EXISTS tc_test_case (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用例ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    title VARCHAR(200) NOT NULL COMMENT '用例标题',
    description TEXT COMMENT '用例描述',
    priority VARCHAR(20) NOT NULL DEFAULT 'medium' COMMENT '优先级: low=低, medium=中, high=高, critical=紧急',
    type VARCHAR(20) NOT NULL DEFAULT 'functional' COMMENT '类型: functional=功能测试, integration=集成测试, api=API测试, ui=UI测试, performance=性能测试, security=安全测试',
    status VARCHAR(20) NOT NULL DEFAULT 'draft' COMMENT '状态: draft=草稿, active=激活, deprecated=废弃',
    precondition TEXT COMMENT '前置条件',
    expected_result TEXT COMMENT '预期结果',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_priority (priority),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_title (title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试用例表';

-- 用例步骤表
CREATE TABLE IF NOT EXISTS tc_test_case_step (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '步骤ID',
    test_case_id BIGINT NOT NULL COMMENT '用例ID',
    step_number INT NOT NULL COMMENT '步骤序号',
    description TEXT NOT NULL COMMENT '步骤描述',
    expected_result TEXT COMMENT '预期结果',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_test_case_id (test_case_id),
    INDEX idx_step_number (step_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用例步骤表';

-- 用例附件表
CREATE TABLE IF NOT EXISTS tc_test_case_attachment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '附件ID',
    test_case_id BIGINT NOT NULL COMMENT '用例ID',
    file_name VARCHAR(255) NOT NULL COMMENT '文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_type VARCHAR(50) COMMENT '文件类型',
    file_size BIGINT COMMENT '文件大小(字节)',
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_test_case_id (test_case_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用例附件表';

-- 用例评论表
CREATE TABLE IF NOT EXISTS tc_test_case_comment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '评论ID',
    test_case_id BIGINT NOT NULL COMMENT '用例ID',
    content TEXT NOT NULL COMMENT '评论内容',
    parent_id BIGINT COMMENT '父评论ID(回复)',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_test_case_id (test_case_id),
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用例评论表';

-- 用例标签表
CREATE TABLE IF NOT EXISTS tc_test_case_label (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '标签ID',
    test_case_id BIGINT NOT NULL COMMENT '用例ID',
    label_id BIGINT NOT NULL COMMENT '标签ID',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_test_case_id (test_case_id),
    INDEX idx_label_id (label_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用例标签关联表';

-- =========================================
-- 测试套件表 (ts_)
-- =========================================

-- 测试套件表
CREATE TABLE IF NOT EXISTS ts_test_suite (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '套件ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(100) NOT NULL COMMENT '套件名称',
    description TEXT COMMENT '套件描述',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试套件表';

-- 套件用例关联表
CREATE TABLE IF NOT EXISTS ts_test_suite_case (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    test_case_id BIGINT NOT NULL COMMENT '用例ID',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    created_by BIGINT COMMENT '创建人',
    UNIQUE KEY uk_suite_case (suite_id, test_case_id),
    INDEX idx_suite_id (suite_id),
    INDEX idx_test_case_id (test_case_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='套件用例关联表';

-- =========================================
-- 测试执行表 (exec_)
-- =========================================

-- 测试计划表
CREATE TABLE IF NOT EXISTS exec_test_plan (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '计划ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(100) NOT NULL COMMENT '计划名称',
    description TEXT COMMENT '计划描述',
    start_date DATETIME COMMENT '开始日期',
    end_date DATETIME COMMENT '结束日期',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待执行, in_progress=执行中, completed=已完成',
    assignee_id BIGINT COMMENT '负责人ID',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_assignee_id (assignee_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试计划表';

-- 测试执行记录表
CREATE TABLE IF NOT EXISTS exec_test_run (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行ID',
    plan_id BIGINT NOT NULL COMMENT '计划ID',
    suite_id BIGINT COMMENT '套件ID',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待执行, running=执行中, completed=已完成, failed=失败',
    executor_id BIGINT NOT NULL COMMENT '执行人ID',
    started_at DATETIME COMMENT '开始时间',
    completed_at DATETIME COMMENT '完成时间',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_plan_id (plan_id),
    INDEX idx_suite_id (suite_id),
    INDEX idx_executor_id (executor_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试执行记录表';

-- 执行用例记录表
CREATE TABLE IF NOT EXISTS exec_test_run_case (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    run_id BIGINT NOT NULL COMMENT '执行ID',
    test_case_id BIGINT NOT NULL COMMENT '用例ID',
    status VARCHAR(20) NOT NULL DEFAULT 'untested' COMMENT '状态: untested=未测试, passed=通过, failed=失败, blocked=阻塞, retest=重测',
    result TEXT COMMENT '执行结果',
    bug_ids VARCHAR(500) COMMENT '关联的缺陷ID(逗号分隔)',
    executor_id BIGINT NOT NULL COMMENT '执行人ID',
    executed_at DATETIME COMMENT '执行时间',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_run_id (run_id),
    INDEX idx_test_case_id (test_case_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='执行用例记录表';

-- =========================================
-- 版本管理表 (ver_)
-- =========================================

CREATE TABLE IF NOT EXISTS prj_version (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '版本ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(100) NOT NULL COMMENT '版本名称',
    description TEXT COMMENT '版本描述',
    status VARCHAR(20) NOT NULL DEFAULT 'planning' COMMENT '状态: planning=规划中, released=已发布, archived=已归档',
    release_date DATE COMMENT '发布日期',
    is_baseline TINYINT NOT NULL DEFAULT 0 COMMENT '是否基线版本: 0=否, 1=是',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='版本表';

-- =========================================
-- 用例评审表 (rv_)
-- =========================================

CREATE TABLE IF NOT EXISTS rv_test_case_review (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '评审ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(100) NOT NULL COMMENT '评审名称',
    description TEXT COMMENT '评审描述',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待评审, in_progress=评审中, passed=通过, rejected=拒绝, needs_revision=需修改',
    template_id BIGINT COMMENT '评审模板ID',
    assignee_id BIGINT COMMENT '评审人ID',
    due_date DATE COMMENT '截止日期',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_status (status),
    INDEX idx_assignee_id (assignee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试用例评审表';

CREATE TABLE IF NOT EXISTS rv_review_assignment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    review_id BIGINT NOT NULL COMMENT '评审ID',
    test_case_id BIGINT NOT NULL COMMENT '用例ID',
    reviewer_id BIGINT NOT NULL COMMENT '评审人ID',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待评审, approved=通过, rejected=拒绝, needs_revision=需修改',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_review_case (review_id, test_case_id),
    INDEX idx_review_id (review_id),
    INDEX idx_test_case_id (test_case_id),
    INDEX idx_reviewer_id (reviewer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评审分配表';

CREATE TABLE IF NOT EXISTS rv_review_comment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '评论ID',
    assignment_id BIGINT NOT NULL COMMENT '分配ID',
    test_case_step_id BIGINT COMMENT '用例步骤ID(可为NULL表示整体意见)',
    content TEXT NOT NULL COMMENT '评论内容',
    is_resolved TINYINT NOT NULL DEFAULT 0 COMMENT '是否已解决: 0=否, 1=是',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_assignment_id (assignment_id),
    INDEX idx_test_case_step_id (test_case_step_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评审意见表';

CREATE TABLE IF NOT EXISTS rv_review_template (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '模板ID',
    name VARCHAR(100) NOT NULL COMMENT '模板名称',
    description TEXT COMMENT '模板描述',
    checklist JSON COMMENT '检查清单(JSON格式)',
    is_default TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认模板: 0=否, 1=是',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评审模板表';

-- =========================================
-- 测试报告表 (rpt_)
-- =========================================

CREATE TABLE IF NOT EXISTS rpt_test_report (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '报告ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(200) NOT NULL COMMENT '报告名称',
    report_type VARCHAR(50) NOT NULL COMMENT '报告类型: execution=执行报告, summary=汇总报告',
    content JSON COMMENT '报告内容(JSON格式)',
    generated_by BIGINT NOT NULL COMMENT '生成人',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_project_id (project_id),
    INDEX idx_generated_by (generated_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试报告表';

-- =========================================
-- 统一配置表 (cfg_)
-- =========================================

CREATE TABLE IF NOT EXISTS cfg_notification_config (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    name VARCHAR(100) NOT NULL COMMENT '配置名称',
    type VARCHAR(50) NOT NULL COMMENT '类型: webhook_feishu=飞书, webhook_wechat=企业微信, webhook_dingtalk=钉钉, email=邮件',
    config JSON NOT NULL COMMENT '配置内容(JSON格式)',
    is_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
    is_default TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认: 0=否, 1=是',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_type (type),
    INDEX idx_is_enabled (is_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知配置表';

CREATE TABLE IF NOT EXISTS cfg_ai_model_config (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    name VARCHAR(100) NOT NULL COMMENT '模型名称',
    provider VARCHAR(50) NOT NULL COMMENT '提供商: deepseek=DeepSeek, qwen=通义千问, siliconflow=硅基流动, openai=OpenAI, anthropic=Anthropic',
    model_name VARCHAR(100) NOT NULL COMMENT '模型名称',
    api_key VARCHAR(500) COMMENT 'API Key(加密存储)',
    base_url VARCHAR(500) COMMENT 'API Base URL',
    temperature DECIMAL(3,2) DEFAULT 0.7 COMMENT '温度参数',
    max_tokens INT DEFAULT 2048 COMMENT '最大Token数',
    role VARCHAR(50) NOT NULL COMMENT '角色: testcase_writer=用例编写, testcase_reviewer=用例评审, browser_use_text=Browser文本模式, browser_use_vision=Browser视觉模式',
    is_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_provider (provider),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI模型配置表';

-- =========================================
-- 标签表 (lbl_)
-- =========================================

CREATE TABLE IF NOT EXISTS lbl_label (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '标签ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(50) NOT NULL COMMENT '标签名称',
    color VARCHAR(20) NOT NULL DEFAULT '#666666' COMMENT '标签颜色',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    UNIQUE KEY uk_project_label (project_id, name),
    INDEX idx_project_id (project_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签表';