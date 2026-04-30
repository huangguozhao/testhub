-- =========================================
-- TestHub Java 版本数据库表结构 - 自动化测试和AI模块
-- 创建日期: 2026-04-29
-- =========================================

USE testhub_java;

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
    variables JSON NOT NULL COMMENT '环境变量(JSON格式)',
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

-- API 测试套件请求关联表
CREATE TABLE IF NOT EXISTS api_test_suite_request (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    suite_id BIGINT NOT NULL COMMENT '套件ID',
    request_id BIGINT NOT NULL COMMENT '请求ID',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '执行顺序',
    assertions JSON COMMENT '断言配置',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_suite_request (suite_id, request_id),
    INDEX idx_suite_id (suite_id),
    INDEX idx_request_id (request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='套件请求关联表';

-- API 请求历史表
CREATE TABLE IF NOT EXISTS api_request_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '历史ID',
    request_id BIGINT NOT NULL COMMENT '请求ID',
    suite_id BIGINT COMMENT '套件ID(如果通过套件执行)',
    environment_id BIGINT COMMENT '环境ID',
    method VARCHAR(10) NOT NULL COMMENT 'HTTP方法',
    url VARCHAR(2000) NOT NULL COMMENT '请求URL',
    request_headers JSON COMMENT '请求头',
    request_body TEXT COMMENT '请求体',
    response_status INT COMMENT '响应状态码',
    response_headers JSON COMMENT '响应头',
    response_body TEXT COMMENT '响应体',
    response_time INT COMMENT '响应时间(毫秒)',
    assertion_results JSON COMMENT '断言结果',
    executed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间',
    executor_id BIGINT COMMENT '执行人ID',
    INDEX idx_request_id (request_id),
    INDEX idx_suite_id (suite_id),
    INDEX idx_executed_at (executed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API请求历史表';

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API定时任务表';

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