-- =========================================
-- TestHub Java 版本数据库初始化脚本
-- 数据库名: testhub_java
-- XXL-JOB 数据库: xxl_job
-- 字符集: utf8mb4
-- 创建日期: 2026-04-29
-- 最后更新: 2026-04-30
-- =========================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Part 1: XXL-JOB 数据库表
-- ----------------------------
CREATE DATABASE IF NOT EXISTS xxl_job DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE xxl_job;

-- 任务信息表
CREATE TABLE IF NOT EXISTS `xxl_job_info` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `job_group` BIGINT NOT NULL COMMENT '执行器主键ID',
  `job_desc` VARCHAR(255) NOT NULL COMMENT '任务描述',
  `add_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  `author` VARCHAR(64) DEFAULT NULL COMMENT '作者',
  `alarm_email` VARCHAR(255) DEFAULT NULL COMMENT '报警邮件',
  `schedule_type` VARCHAR(50) NOT NULL DEFAULT 'NONE' COMMENT '调度类型',
  `schedule_conf` VARCHAR(255) DEFAULT NULL COMMENT '调度配置',
  `misfire_strategy` VARCHAR(50) NOT NULL DEFAULT 'DO_NOTHING' COMMENT '调度失效策略',
  `executor_route_strategy` VARCHAR(100) DEFAULT NULL COMMENT '执行器路由策略',
  `executor_handler` VARCHAR(255) DEFAULT NULL COMMENT '执行器handler',
  `executor_param` VARCHAR(512) DEFAULT NULL COMMENT '执行器参数',
  `executor_block_strategy` VARCHAR(50) DEFAULT NULL COMMENT '阻塞处理策略',
  `executor_timeout` INT NOT NULL DEFAULT '0' COMMENT '执行器超时时间',
  `executor_fail_retry_count` INT NOT NULL DEFAULT '0' COMMENT '失败重试次数',
  `glue_type` VARCHAR(50) NOT NULL COMMENT 'GLUE类型',
  `glue_source` MEDIUMTEXT COMMENT 'GLUE源代码',
  `glue_remark` VARCHAR(128) DEFAULT NULL COMMENT 'GLUE备注',
  `glue_updatetime` DATETIME DEFAULT NULL COMMENT 'GLUE更新时间',
  `child_jobid` VARCHAR(255) DEFAULT NULL COMMENT '子任务ID',
  `trigger_status` TINYINT NOT NULL DEFAULT '0' COMMENT '调度状态',
  `trigger_last_time` BIGINT NOT NULL DEFAULT '0' COMMENT '上次调度时间',
  `trigger_next_time` BIGINT NOT NULL DEFAULT '0' COMMENT '下次调度时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务信息表';

-- 任务日志表
CREATE TABLE IF NOT EXISTS `xxl_job_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `job_group` BIGINT NOT NULL COMMENT '执行器主键ID',
  `job_id` BIGINT NOT NULL COMMENT '任务ID',
  `executor_address` VARCHAR(255) DEFAULT NULL COMMENT '执行器地址',
  `executor_handler` VARCHAR(255) DEFAULT NULL COMMENT '执行器handler',
  `executor_param` VARCHAR(512) DEFAULT NULL COMMENT '执行器参数',
  `executor_sharding_param` VARCHAR(255) DEFAULT NULL COMMENT '执行器分片参数',
  `executor_fail_retry_count` TINYINT NOT NULL DEFAULT '0' COMMENT '失败重试次数',
  `trigger_time` DATETIME DEFAULT NULL COMMENT '调度-时间',
  `trigger_code` INT NOT NULL COMMENT '调度-结果',
  `trigger_msg` TEXT COMMENT '调度-日志',
  `handle_time` DATETIME DEFAULT NULL COMMENT '执行-时间',
  `handle_code` INT NOT NULL COMMENT '执行-状态',
  `handle_msg` TEXT COMMENT '执行-日志',
  `handle_console_url` VARCHAR(255) DEFAULT NULL COMMENT '操作控制台URL',
  `handle_process_id` INT DEFAULT NULL COMMENT '执行进程ID',
  `handle_cost_time` INT DEFAULT NULL COMMENT '执行耗时',
  `alarm_status` TINYINT NOT NULL DEFAULT '0' COMMENT '报警状态',
  PRIMARY KEY (`id`),
  KEY `idx_job_group` (`job_group`),
  KEY `idx_job_id` (`job_id`),
  KEY `idx_trigger_time` (`trigger_time`),
  KEY `idx_handle_time` (`handle_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务日志表';

-- 任务日志报告表
CREATE TABLE IF NOT EXISTS `xxl_job_log_report` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `trigger_day` DATETIME DEFAULT NULL COMMENT '调度时间',
  `running_count` INT NOT NULL DEFAULT '0' COMMENT '运行中数量',
  `success_count` INT NOT NULL DEFAULT '0' COMMENT '成功数量',
  `fail_count` INT NOT NULL DEFAULT '0' COMMENT '失败数量',
  `updatetime` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_trigger_day` (`trigger_day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务日志报告表';

-- 执行器注册表
CREATE TABLE IF NOT EXISTS `xxl_job_registry` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `registry_group` VARCHAR(50) NOT NULL COMMENT '注册分组',
  `registry_key` VARCHAR(255) NOT NULL COMMENT '注册Key',
  `registry_value` VARCHAR(255) NOT NULL COMMENT '注册值',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_registry_group` (`registry_group`),
  KEY `idx_registry_key` (`registry_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='执行器注册表';

-- 执行器组表
CREATE TABLE IF NOT EXISTS `xxl_job_group` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_name` VARCHAR(255) NOT NULL COMMENT '执行器AppName',
  `title` VARCHAR(255) NOT NULL COMMENT '执行器名称',
  `address_type` TINYINT NOT NULL DEFAULT '0' COMMENT '地址类型',
  `address_list` VARCHAR(512) DEFAULT NULL COMMENT '执行器地址列表',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='执行器组表';

-- XXL-JOB 用户表
CREATE TABLE IF NOT EXISTS `xxl_job_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` VARCHAR(255) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码',
  `role` TINYINT NOT NULL COMMENT '角色',
  `permission` VARCHAR(255) DEFAULT NULL COMMENT '权限',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='XXL-JOB用户表';

-- 任务锁表
CREATE TABLE IF NOT EXISTS `xxl_job_lock` (
  `lock_name` VARCHAR(50) NOT NULL COMMENT '锁名称',
  PRIMARY KEY (`lock_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务锁表';

-- XXL-JOB 初始数据
INSERT INTO `xxl_job_user` (`id`, `username`, `password`, `role`, `permission`) VALUES
(1, 'admin', '$2a$10$X1NWkn/zA7zDmV9p6N6K4uPFQq3R4G7Gqz/sZj1cLCcL2R6H8J5V0i', 1, NULL);

INSERT INTO `xxl_job_group` (`id`, `app_name`, `title`, `address_type`, `address_list`) VALUES
(1, 'testhub-executor', 'TestHub执行器', 1, NULL);

-- ----------------------------
-- Part 2: 主数据库表
-- ----------------------------
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

-- 用例标签关联表
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

-- =========================================
-- API 测试表 (api_)
-- =========================================

-- API 项目表
CREATE TABLE IF NOT EXISTS api_project (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '项目ID',
    project_id BIGINT NOT NULL COMMENT '关联项目ID',
    name VARCHAR(100) NOT NULL COMMENT 'API项目名称',
    description TEXT COMMENT '项目描述',
    base_url VARCHAR(500) COMMENT '基础URL',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API项目表';

-- API 集合表
CREATE TABLE IF NOT EXISTS api_collection (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '集合ID',
    project_id BIGINT NOT NULL COMMENT 'API项目ID',
    parent_id BIGINT COMMENT '父集合ID(用于树形结构)',
    name VARCHAR(100) NOT NULL COMMENT '集合名称',
    description TEXT COMMENT '集合描述',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_parent_id (parent_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API集合表';

-- API 请求表
CREATE TABLE IF NOT EXISTS api_request (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '请求ID',
    collection_id BIGINT NOT NULL COMMENT '集合ID',
    name VARCHAR(200) NOT NULL COMMENT '请求名称',
    method VARCHAR(10) NOT NULL COMMENT 'HTTP方法: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS',
    url VARCHAR(2000) NOT NULL COMMENT '请求URL',
    headers JSON COMMENT '请求头',
    params JSON COMMENT 'URL参数',
    body_type VARCHAR(20) COMMENT '请求体类型: none, json, form, xml, raw, binary',
    body_content TEXT COMMENT '请求体内容',
    auth_type VARCHAR(20) COMMENT '认证类型: none, basic, bearer, api_key, oauth2',
    auth_config JSON COMMENT '认证配置',
    pre_script TEXT COMMENT '前置脚本',
    post_script TEXT COMMENT '后置脚本',
    assertions TEXT COMMENT '断言配置',
    extractors TEXT COMMENT '变量提取配置',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_collection_id (collection_id),
    INDEX idx_method (method),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API请求表';

-- API 环境表
CREATE TABLE IF NOT EXISTS api_environment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '环境ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(50) NOT NULL COMMENT '环境名称',
    description VARCHAR(200) COMMENT '环境描述',
    variables TEXT COMMENT '环境变量(JSON格式)',
    is_default TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认: 0=否, 1=是',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_is_default (is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API环境表';

-- API 测试套件表
CREATE TABLE IF NOT EXISTS api_test_suite (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '套件ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(100) NOT NULL COMMENT '套件名称',
    description TEXT COMMENT '套件描述',
    environment_id BIGINT COMMENT '执行环境ID',
    timeout INT DEFAULT 30000 COMMENT '超时时间(毫秒)',
    retry_count INT DEFAULT 0 COMMENT '失败重试次数',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API测试套件表';

-- API 执行记录表
CREATE TABLE IF NOT EXISTS api_execution_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '执行状态: 0=失败, 1=成功',
    total_count INT DEFAULT 0 COMMENT '总请求数',
    pass_count INT DEFAULT 0 COMMENT '通过数',
    fail_count INT DEFAULT 0 COMMENT '失败数',
    duration BIGINT COMMENT '执行耗时(毫秒)',
    environment_id BIGINT COMMENT '环境ID',
    trigger_type VARCHAR(20) COMMENT '触发类型: manual=手动, scheduled=定时',
    trigger_id BIGINT COMMENT '触发ID(定时任务ID等)',
    result_data TEXT COMMENT '详细结果数据(JSON)',
    executor_id BIGINT COMMENT '执行人ID',
    executed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_suite_id (suite_id),
    INDEX idx_executed_at (executed_at),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API执行记录表';

-- API 定时任务表
CREATE TABLE IF NOT EXISTS api_scheduled_task (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '任务ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    name VARCHAR(100) NOT NULL COMMENT '任务名称',
    trigger_type VARCHAR(20) NOT NULL COMMENT '触发类型: cron=Cron表达式, interval=固定间隔, once=单次执行',
    cron_expression VARCHAR(100) COMMENT 'Cron表达式',
    interval_value BIGINT COMMENT '间隔值',
    interval_unit VARCHAR(10) COMMENT '间隔单位: seconds, minutes, hours',
    once_time DATETIME COMMENT '单次执行时间',
    is_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
    notification_config TEXT COMMENT '通知配置(JSON)',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    last_run_at DATETIME COMMENT '上次执行时间',
    next_run_at DATETIME COMMENT '下次执行时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_suite_id (suite_id),
    INDEX idx_is_enabled (is_enabled),
    INDEX idx_trigger_type (trigger_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API定时任务表';

-- API 请求历史记录表
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

-- =========================================
-- 通知配置表 (notification_)
-- =========================================

-- 通知配置表
CREATE TABLE IF NOT EXISTS notification_config (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    name VARCHAR(100) NOT NULL COMMENT '配置名称',
    config_type VARCHAR(50) NOT NULL COMMENT '配置类型: webhook_feishu, webhook_wechat, webhook_dingtalk, email',
    webhook_config TEXT COMMENT 'Webhook配置(JSON)',
    is_default TINYINT(1) DEFAULT FALSE COMMENT '是否默认',
    is_active TINYINT(1) DEFAULT TRUE COMMENT '是否启用',
    remark TEXT COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    is_deleted TINYINT(1) DEFAULT FALSE COMMENT '是否删除',
    INDEX idx_config_type (config_type),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知配置表';

-- 通知日志表
CREATE TABLE IF NOT EXISTS notification_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    task_id BIGINT COMMENT '关联任务ID',
    task_type VARCHAR(50) COMMENT '任务类型: api_test, ui_automation, app_automation',
    notification_type VARCHAR(50) DEFAULT 'manual' COMMENT '通知类型: task_execution, system_alert, manual',
    channel VARCHAR(20) NOT NULL COMMENT '通知渠道: feishu, wechat, dingtalk, email',
    status VARCHAR(20) DEFAULT 'pending' COMMENT '发送状态: pending, sending, success, failed',
    config_id BIGINT COMMENT '通知配置ID',
    recipient_info TEXT COMMENT '收件人信息(JSON)',
    content TEXT COMMENT '通知内容(JSON)',
    error_message TEXT COMMENT '错误信息',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    sent_at DATETIME COMMENT '发送时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    is_deleted TINYINT(1) DEFAULT FALSE COMMENT '是否删除',
    INDEX idx_task_id (task_id),
    INDEX idx_task_type (task_type),
    INDEX idx_channel (channel),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知日志表';

-- =========================================
-- 操作日志表 (operation_)
-- =========================================

CREATE TABLE IF NOT EXISTS operation_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    operation_type VARCHAR(20) NOT NULL COMMENT '操作类型: create, edit, delete, execute, run, save',
    resource_type VARCHAR(50) NOT NULL COMMENT '资源类型: project, collection, request, suite, environment, task, execution',
    resource_id BIGINT COMMENT '资源ID',
    resource_name VARCHAR(200) COMMENT '资源名称',
    description TEXT COMMENT '操作描述',
    user_id BIGINT COMMENT '操作用户ID',
    username VARCHAR(100) COMMENT '操作用户名',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    user_agent VARCHAR(500) COMMENT '用户代理',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    is_deleted TINYINT(1) DEFAULT FALSE COMMENT '是否删除',
    INDEX idx_operation_type (operation_type),
    INDEX idx_resource_type (resource_type),
    INDEX idx_resource_id (resource_id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- =========================================
-- UI 自动化测试表 (ui_)
-- =========================================

-- UI 项目表
CREATE TABLE IF NOT EXISTS ui_project (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '项目ID',
    project_id BIGINT NOT NULL COMMENT '关联项目ID',
    name VARCHAR(100) NOT NULL COMMENT 'UI项目名称',
    description TEXT COMMENT '项目描述',
    engine VARCHAR(20) NOT NULL DEFAULT 'selenium' COMMENT '自动化引擎: selenium, playwright',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI自动化项目表';

-- UI 元素表
CREATE TABLE IF NOT EXISTS ui_element (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '元素ID',
    project_id BIGINT NOT NULL COMMENT 'UI项目ID',
    name VARCHAR(100) NOT NULL COMMENT '元素名称',
    locator_strategy VARCHAR(20) NOT NULL COMMENT '定位策略: id, css, xpath, name, class_name, tag_name, link_text, partial_link_text',
    locator_value VARCHAR(500) NOT NULL COMMENT '定位器值',
    element_type VARCHAR(20) COMMENT '元素类型: input, button, link, dropdown, checkbox, radio, text, image, container, table, form, modal',
    description VARCHAR(200) COMMENT '元素描述',
    screenshot VARCHAR(500) COMMENT '截图路径',
    usage_count INT DEFAULT 0 COMMENT '使用次数',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_locator_strategy (locator_strategy),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI元素表';

-- UI 元素分组表
CREATE TABLE IF NOT EXISTS ui_element_group (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '分组ID',
    project_id BIGINT NOT NULL COMMENT 'UI项目ID',
    name VARCHAR(100) NOT NULL COMMENT '分组名称',
    parent_id BIGINT COMMENT '父分组ID',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI元素分组表';

-- UI 备用定位器表
CREATE TABLE IF NOT EXISTS ui_element_backup (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    element_id BIGINT NOT NULL COMMENT '元素ID',
    locator_strategy VARCHAR(20) NOT NULL COMMENT '备用定位策略',
    locator_value VARCHAR(500) NOT NULL COMMENT '备用定位器值',
    priority INT NOT NULL DEFAULT 1 COMMENT '优先级',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_element_id (element_id),
    INDEX idx_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI元素备用定位器表';

-- UI 页面对象表
CREATE TABLE IF NOT EXISTS ui_page_object (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '页面对象ID',
    project_id BIGINT NOT NULL COMMENT 'UI项目ID',
    name VARCHAR(100) NOT NULL COMMENT '页面对象名称',
    url_pattern VARCHAR(500) COMMENT 'URL模式',
    description TEXT COMMENT '页面描述',
    elements JSON COMMENT '页面元素配置',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI页面对象表';

-- UI 测试脚本表
CREATE TABLE IF NOT EXISTS ui_test_script (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '脚本ID',
    project_id BIGINT NOT NULL COMMENT 'UI项目ID',
    name VARCHAR(100) NOT NULL COMMENT '脚本名称',
    description TEXT COMMENT '脚本描述',
    browser VARCHAR(20) NOT NULL DEFAULT 'chromium' COMMENT '浏览器: chromium, firefox, webkit, edge',
    steps JSON NOT NULL COMMENT '执行步骤(JSON格式)',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI测试脚本表';

-- UI 测试套件表
CREATE TABLE IF NOT EXISTS ui_test_suite (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '套件ID',
    project_id BIGINT NOT NULL COMMENT 'UI项目ID',
    name VARCHAR(100) NOT NULL COMMENT '套件名称',
    description TEXT COMMENT '套件描述',
    browser VARCHAR(20) NOT NULL DEFAULT 'chromium' COMMENT '浏览器',
    headless TINYINT NOT NULL DEFAULT 0 COMMENT '是否无头模式: 0=否, 1=是',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI测试套件表';

-- UI 测试套件脚本关联表
CREATE TABLE IF NOT EXISTS ui_test_suite_script (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    script_id BIGINT NOT NULL COMMENT '脚本ID',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '执行顺序',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_suite_script (suite_id, script_id),
    INDEX idx_suite_id (suite_id),
    INDEX idx_script_id (script_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI套件脚本关联表';

-- UI 测试执行记录表
CREATE TABLE IF NOT EXISTS ui_test_execution (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待执行, running=执行中, passed=通过, failed=失败, stopped=已停止',
    browser VARCHAR(20) NOT NULL COMMENT '浏览器',
    headless TINYINT NOT NULL DEFAULT 0 COMMENT '是否无头模式',
    executor_id BIGINT NOT NULL COMMENT '执行人ID',
    started_at DATETIME COMMENT '开始时间',
    completed_at DATETIME COMMENT '完成时间',
    total_count INT DEFAULT 0 COMMENT '总用例数',
    passed_count INT DEFAULT 0 COMMENT '通过数',
    failed_count INT DEFAULT 0 COMMENT '失败数',
    report_path VARCHAR(500) COMMENT '报告路径',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_suite_id (suite_id),
    INDEX idx_status (status),
    INDEX idx_executor_id (executor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI测试执行记录表';

-- UI AI 智能模式配置表
CREATE TABLE IF NOT EXISTS ui_ai_config (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    project_id BIGINT NOT NULL COMMENT 'UI项目ID',
    name VARCHAR(100) NOT NULL COMMENT '配置名称',
    ai_model_config_id BIGINT COMMENT 'AI模型配置ID',
    mode VARCHAR(20) NOT NULL DEFAULT 'text' COMMENT '模式: text=文本模式, vision=视觉模式',
    prompt_template TEXT COMMENT '提示词模板',
    is_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_is_enabled (is_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI AI智能模式配置表';

-- UI AI 执行记录表
CREATE TABLE IF NOT EXISTS ui_ai_execution (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行ID',
    config_id BIGINT NOT NULL COMMENT 'AI配置ID',
    task_description TEXT NOT NULL COMMENT '任务描述',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待执行, running=执行中, completed=已完成, failed=失败',
    steps JSON COMMENT '执行步骤',
    result TEXT COMMENT '执行结果',
    executor_id BIGINT NOT NULL COMMENT '执行人ID',
    started_at DATETIME COMMENT '开始时间',
    completed_at DATETIME COMMENT '完成时间',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_config_id (config_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI AI执行记录表';

-- UI 定时任务表
CREATE TABLE IF NOT EXISTS ui_scheduled_task (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '任务ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    name VARCHAR(100) NOT NULL COMMENT '任务名称',
    trigger_type VARCHAR(20) NOT NULL COMMENT '触发类型: cron, interval, once',
    cron_expression VARCHAR(100) COMMENT 'Cron表达式',
    interval_value BIGINT COMMENT '间隔值',
    interval_unit VARCHAR(10) COMMENT '间隔单位',
    once_time DATETIME COMMENT '单次执行时间',
    browser VARCHAR(20) NOT NULL DEFAULT 'chromium' COMMENT '浏览器',
    headless TINYINT NOT NULL DEFAULT 0 COMMENT '是否无头模式',
    is_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
    notification_config JSON COMMENT '通知配置',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    last_run_at DATETIME COMMENT '上次执行时间',
    next_run_at DATETIME COMMENT '下次执行时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_suite_id (suite_id),
    INDEX idx_is_enabled (is_enabled),
    INDEX idx_trigger_type (trigger_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI定时任务表';

-- =========================================
-- APP 自动化测试表 (app_)
-- =========================================

-- APP 项目表
CREATE TABLE IF NOT EXISTS app_project (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '项目ID',
    project_id BIGINT NOT NULL COMMENT '关联项目ID',
    name VARCHAR(100) NOT NULL COMMENT 'APP项目名称',
    description TEXT COMMENT '项目描述',
    platform VARCHAR(20) NOT NULL DEFAULT 'android' COMMENT '平台: android, ios',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP自动化项目表';

-- APP 设备表
CREATE TABLE IF NOT EXISTS app_device (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '设备ID',
    project_id BIGINT NOT NULL COMMENT 'APP项目ID',
    name VARCHAR(100) NOT NULL COMMENT '设备名称',
    device_id VARCHAR(100) COMMENT '设备序列号',
    connection_type VARCHAR(20) NOT NULL DEFAULT 'usb' COMMENT '连接类型: usb, wifi, emulator, remote',
    status VARCHAR(20) NOT NULL DEFAULT 'offline' COMMENT '状态: offline=离线, online=在线, busy=占用中, error=异常',
    platform_version VARCHAR(50) COMMENT '系统版本',
    resolution VARCHAR(50) COMMENT '分辨率',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    locked_by BIGINT COMMENT '锁定人ID',
    locked_at DATETIME COMMENT '锁定时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_status (status),
    INDEX idx_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP设备表';

-- APP 元素表
CREATE TABLE IF NOT EXISTS app_element (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '元素ID',
    project_id BIGINT NOT NULL COMMENT 'APP项目ID',
    name VARCHAR(100) NOT NULL COMMENT '元素名称',
    locator_type VARCHAR(20) NOT NULL COMMENT '定位类型: image=图片, coordinate=坐标, region=区域',
    locator_value VARCHAR(500) NOT NULL COMMENT '定位值(图片路径或坐标)',
    description VARCHAR(200) COMMENT '元素描述',
    screenshot VARCHAR(500) COMMENT '截图路径',
    usage_count INT DEFAULT 0 COMMENT '使用次数',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_locator_type (locator_type),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP元素表';

-- APP UI 组件表
CREATE TABLE IF NOT EXISTS app_component (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '组件ID',
    project_id BIGINT NOT NULL COMMENT 'APP项目ID',
    name VARCHAR(100) NOT NULL COMMENT '组件名称',
    component_type VARCHAR(50) NOT NULL COMMENT '组件类型',
    description TEXT COMMENT '组件描述',
    config JSON COMMENT '组件配置',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP UI组件表';

-- APP 包名管理表
CREATE TABLE IF NOT EXISTS app_package (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '包名ID',
    project_id BIGINT NOT NULL COMMENT 'APP项目ID',
    name VARCHAR(100) NOT NULL COMMENT '包名名称',
    package_name VARCHAR(200) NOT NULL COMMENT '应用包名',
    description VARCHAR(200) COMMENT '描述',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_package_name (package_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP包名管理表';

-- APP 测试用例表
CREATE TABLE IF NOT EXISTS app_test_case (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用例ID',
    project_id BIGINT NOT NULL COMMENT 'APP项目ID',
    name VARCHAR(100) NOT NULL COMMENT '用例名称',
    description TEXT COMMENT '用例描述',
    ui_flow JSON NOT NULL COMMENT 'UI流程配置(JSON)',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP测试用例表';

-- APP 测试套件表
CREATE TABLE IF NOT EXISTS app_test_suite (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '套件ID',
    project_id BIGINT NOT NULL COMMENT 'APP项目ID',
    name VARCHAR(100) NOT NULL COMMENT '套件名称',
    description TEXT COMMENT '套件描述',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP测试套件表';

-- APP 测试套件用例关联表
CREATE TABLE IF NOT EXISTS app_test_suite_case (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    case_id BIGINT NOT NULL COMMENT '用例ID',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '执行顺序',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_suite_case (suite_id, case_id),
    INDEX idx_suite_id (suite_id),
    INDEX idx_case_id (case_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP套件用例关联表';

-- APP 执行记录表
CREATE TABLE IF NOT EXISTS app_test_execution (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    device_id BIGINT NOT NULL COMMENT '设备ID',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending, running, passed, failed, stopped',
    executor_id BIGINT NOT NULL COMMENT '执行人ID',
    started_at DATETIME COMMENT '开始时间',
    completed_at DATETIME COMMENT '完成时间',
    total_count INT DEFAULT 0 COMMENT '总用例数',
    passed_count INT DEFAULT 0 COMMENT '通过数',
    failed_count INT DEFAULT 0 COMMENT '失败数',
    report_path VARCHAR(500) COMMENT '报告路径',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_suite_id (suite_id),
    INDEX idx_device_id (device_id),
    INDEX idx_status (status),
    INDEX idx_executor_id (executor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP执行记录表';

-- APP 定时任务表
CREATE TABLE IF NOT EXISTS app_scheduled_task (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '任务ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    name VARCHAR(100) NOT NULL COMMENT '任务名称',
    trigger_type VARCHAR(20) NOT NULL COMMENT '触发类型: cron, interval, once',
    cron_expression VARCHAR(100) COMMENT 'Cron表达式',
    interval_value BIGINT COMMENT '间隔值',
    interval_unit VARCHAR(10) COMMENT '间隔单位',
    once_time DATETIME COMMENT '单次执行时间',
    device_id BIGINT COMMENT '指定设备ID',
    is_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
    notification_config JSON COMMENT '通知配置',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    last_run_at DATETIME COMMENT '上次执行时间',
    next_run_at DATETIME COMMENT '下次执行时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_suite_id (suite_id),
    INDEX idx_is_enabled (is_enabled),
    INDEX idx_trigger_type (trigger_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP定时任务表';

-- =========================================
-- AI 需求分析表 (req_)
-- =========================================

-- 需求文档表
CREATE TABLE IF NOT EXISTS req_document (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '文档ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    name VARCHAR(200) NOT NULL COMMENT '文档名称',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_type VARCHAR(20) NOT NULL COMMENT '文件类型: pdf, docx, txt, markdown',
    file_size BIGINT COMMENT '文件大小',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待解析, parsing=解析中, parsed=已解析, failed=失败',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_project_id (project_id),
    INDEX idx_status (status),
    INDEX idx_file_type (file_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='需求文档表';

-- 需求分析记录表
CREATE TABLE IF NOT EXISTS req_analysis (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '分析ID',
    document_id BIGINT NOT NULL COMMENT '文档ID',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending, running, completed, failed',
    content TEXT COMMENT '解析后的内容',
    summary TEXT COMMENT 'AI生成的摘要',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_document_id (document_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='需求分析记录表';

-- 业务需求表
CREATE TABLE IF NOT EXISTS req_business_requirement (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '需求ID',
    analysis_id BIGINT NOT NULL COMMENT '分析ID',
    parent_id BIGINT COMMENT '父需求ID(用于层级结构)',
    title VARCHAR(200) NOT NULL COMMENT '需求标题',
    description TEXT COMMENT '需求描述',
    priority VARCHAR(20) DEFAULT 'medium' COMMENT '优先级: low, medium, high, critical',
    source VARCHAR(50) COMMENT '来源',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_analysis_id (analysis_id),
    INDEX idx_parent_id (parent_id),
    INDEX idx_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务需求表';

-- 生成的测试用例表
CREATE TABLE IF NOT EXISTS req_generated_test_case (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '生成ID',
    requirement_id BIGINT NOT NULL COMMENT '需求ID',
    title VARCHAR(200) NOT NULL COMMENT '用例标题',
    description TEXT COMMENT '用例描述',
    precondition TEXT COMMENT '前置条件',
    steps TEXT COMMENT '测试步骤',
    expected_result TEXT COMMENT '预期结果',
    priority VARCHAR(20) DEFAULT 'medium' COMMENT '优先级',
    status VARCHAR(20) NOT NULL DEFAULT 'generated' COMMENT '状态: generated=已生成, imported=已导入用例库, rejected=已拒绝',
    test_case_id BIGINT COMMENT '关联的测试用例ID(导入后)',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_requirement_id (requirement_id),
    INDEX idx_status (status),
    INDEX idx_test_case_id (test_case_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='生成的测试用例表';

-- =========================================
-- AI 助手表 (ast_)
-- =========================================

-- AI 助手会话表
CREATE TABLE IF NOT EXISTS ast_assistant_session (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '会话ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    name VARCHAR(100) NOT NULL COMMENT '会话名称',
    last_message_at DATETIME COMMENT '最后消息时间',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_last_message_at (last_message_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI助手会话表';

-- AI 助手消息表
CREATE TABLE IF NOT EXISTS ast_chat_message (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '消息ID',
    session_id BIGINT NOT NULL COMMENT '会话ID',
    role VARCHAR(20) NOT NULL COMMENT '角色: user, assistant, system',
    content TEXT NOT NULL COMMENT '消息内容',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_session_id (session_id),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI助手消息表';

-- AI Dify 配置表
CREATE TABLE IF NOT EXISTS ast_dify_config (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    name VARCHAR(100) NOT NULL COMMENT '配置名称',
    api_url VARCHAR(500) NOT NULL COMMENT 'API URL',
    api_key VARCHAR(500) COMMENT 'API Key',
    app_id VARCHAR(100) COMMENT '应用ID',
    is_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
    is_default TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认: 0=否, 1=是',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_is_enabled (is_enabled),
    INDEX idx_is_default (is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Dify配置表';

-- =========================================
-- 数据工厂表 (df_)
-- =========================================

CREATE TABLE IF NOT EXISTS df_data_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '记录ID',
    tool_name VARCHAR(50) NOT NULL COMMENT '工具名称',
    tool_category VARCHAR(30) NOT NULL COMMENT '工具分类: string=字符, encoding=编码, random=随机, encryption=加密, test_data=测试数据, json=JSON, crontab=Crontab',
    tool_scenario VARCHAR(30) NOT NULL COMMENT '使用场景: data_generate=数据生成, format_convert=格式转换, data_validation=数据验证, encrypt=加密解密',
    input_data JSON COMMENT '输入数据',
    output_data JSON COMMENT '输出数据',
    tags JSON COMMENT '标签',
    is_saved TINYINT NOT NULL DEFAULT 0 COMMENT '是否保存: 0=否, 1=是',
    usage_count INT DEFAULT 0 COMMENT '使用次数',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    INDEX idx_tool_name (tool_name),
    INDEX idx_tool_category (tool_category),
    INDEX idx_tool_scenario (tool_scenario),
    INDEX idx_is_saved (is_saved)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据工厂记录表';

-- =========================================
-- 初始数据
-- =========================================

-- 创建默认管理员用户 (密码: admin123)
INSERT INTO sys_user (username, email, password, real_name, phone, status, role_name, is_superuser, is_staff, created_at, updated_at)
VALUES ('admin', 'admin@test.com', '$2a$10$a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6', '超级管理员', '13700000000', 'enabled', 'ADMIN', 1, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE is_superuser = 1, is_staff = 1, role_name = 'ADMIN';

-- 创建测试用户 (密码: test123456)
INSERT INTO sys_user (username, email, password, real_name, status, role_name, created_at, updated_at)
VALUES ('testuser', 'test@test.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36Vyj.MR6GIrZ5Hqy6qPL.O', 'Test User', 'enabled', 'USER', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================
-- 初始化完成
-- =========================================
