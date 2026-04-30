# TestHub 智能测试管理平台数据库表设计文档

## 1. 文档概述

本文档详细描述了 TestHub 智能测试管理平台的所有数据库表结构设计。平台采用 Django 4.2 + MySQL 8.0 架构设计，包含用户管理、项目协作、测试用例、测试执行、AI 分析、API 测试、UI 自动化等多个功能模块。

### 1.1 数据库概览

| 序号 | 模块名称 | 表数量 | 主要功能 |
|------|---------|--------|---------|
| 1 | users | 2 | 用户认证与配置 |
| 2 | projects | 3 | 项目与团队管理 |
| 3 | testcases | 4 | 手工测试用例管理 |
| 4 | testsuites | 2 | 测试套件管理 |
| 5 | executions | 4 | 测试执行与结果追踪 |
| 6 | reports | 2 | 测试报告管理 |
| 7 | reviews | 4 | 测试用例评审 |
| 8 | versions | 1 | 版本管理 |
| 9 | requirement_analysis | 9 | AI 需求分析与用例生成 |
| 10 | assistant | 3 | AI 助手 |
| 11 | api_testing | 14 | API 接口测试 |
| 12 | ui_automation | 24 | UI 自动化测试 |
| 13 | data_factory | 1 | 测试数据工厂 |
| 14 | core | 1 | 核心配置 |
| 15 | app_automation | 14 | APP 自动化测试 |
| **合计** | **15 个模块** | **88 张表** | **完整测试管理平台** |

### 1.2 命名规范

- **表名**：使用小写字母，单词间用下划线分隔，如 `test_runs`
- **字段名**：使用小写字母，单词间用下划线分隔，如 `created_at`
- **外键**：使用 `_id` 后缀，如 `project_id`
- **索引**：使用 `idx_` 前缀，如 `idx_user_created`

---

## 2. 用户与认证模块 (users)

### 2.1 用户表 (users_user)

`users` 表存储平台用户的基础认证信息和个人配置。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 用户唯一标识 |
| password | VARCHAR(128) | 否 | 是 | 加密后的密码 |
| last_login | DATETIME | 否 | 否 | 最后登录时间 |
| is_superuser | BOOLEAN | 否 | 是 | 是否超级管理员 |
| username | VARCHAR(150) | 否 | 是 | 用户名，唯一 |
| first_name | VARCHAR(150) | 否 | 否 | 名 |
| last_name | VARCHAR(150) | 否 | 否 | 姓 |
| email | VARCHAR(254) | 否 | 否 | 邮箱地址 |
| is_staff | BOOLEAN | 否 | 是 | 是否可访问管理后台 |
| is_active | BOOLEAN | 否 | 是 | 是否激活 |
| date_joined | DATETIME | 否 | 是 | 注册时间 |
| avatar | VARCHAR(100) | 否 | 否 | 头像URL |
| phone | VARCHAR(11) | 否 | 否 | 手机号 |
| department | VARCHAR(100) | 否 | 否 | 部门 |
| position | VARCHAR(100) | 否 | 否 | 职位 |

**建表语句**：

```sql
CREATE TABLE `users_user` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户唯一标识',
    `password` VARCHAR(128) NOT NULL COMMENT '加密后的密码',
    `last_login` DATETIME(6) DEFAULT NULL COMMENT '最后登录时间',
    `is_superuser` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否超级管理员',
    `username` VARCHAR(150) NOT NULL UNIQUE COMMENT '用户名，唯一',
    `first_name` VARCHAR(150) DEFAULT '' COMMENT '名',
    `last_name` VARCHAR(150) DEFAULT '' COMMENT '姓',
    `email` VARCHAR(254) DEFAULT '' COMMENT '邮箱地址',
    `is_staff` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否可访问管理后台',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否激活',
    `date_joined` DATETIME(6) NOT NULL COMMENT '注册时间',
    `avatar` VARCHAR(100) DEFAULT NULL COMMENT '头像URL',
    `phone` VARCHAR(11) DEFAULT NULL COMMENT '手机号',
    `department` VARCHAR(100) DEFAULT NULL COMMENT '部门',
    `position` VARCHAR(100) DEFAULT NULL COMMENT '职位',
    UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

### 2.2 用户配置表 (user_profiles)

`user_profiles` 表存储用户的个人配置信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 主键 |
| user | ONETOONE | 否 | 是 | 用户ID，外键 |
| theme | VARCHAR(20) | 否 | 是 | 主题配置 |
| language | VARCHAR(10) | 否 | 是 | 语言设置 |
| timezone | VARCHAR(50) | 否 | 是 | 时区设置 |
| notifications | JSON | 否 | 是 | 通知设置 |

**建表语句**：

```sql
CREATE TABLE `user_profiles` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL UNIQUE,
    `theme` VARCHAR(20) NOT NULL DEFAULT 'light' COMMENT '主题配置',
    `language` VARCHAR(10) NOT NULL DEFAULT 'zh-cn' COMMENT '语言设置',
    `timezone` VARCHAR(50) NOT NULL DEFAULT 'Asia/Shanghai' COMMENT '时区设置',
    `notifications` JSON DEFAULT ('{}') COMMENT '通知设置',
    CONSTRAINT `user_profiles_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户配置表';
```

---

## 3. 项目管理模块 (projects)

### 3.1 项目表 (projects)

`projects` 表存储测试项目的基本信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 项目ID |
| name | VARCHAR(200) | 否 | 是 | 项目名称 |
| description | TEXT | 否 | 否 | 项目描述 |
| status | ENUM | 否 | 是 | 项目状态 |
| owner_id | BIGINT | 否 | 是 | 负责人ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**状态枚举**：
- `active` - 进行中
- `paused` - 暂停
- `completed` - 已完成
- `archived` - 已归档

**建表语句**：

```sql
CREATE TABLE `projects` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '项目ID',
    `name` VARCHAR(200) NOT NULL COMMENT '项目名称',
    `description` TEXT DEFAULT NULL COMMENT '项目描述',
    `status` VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT '项目状态',
    `owner_id` INT NOT NULL COMMENT '负责人ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `projects_owner_id_fkey` FOREIGN KEY (`owner_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_projects_status` (`status`),
    INDEX `idx_projects_owner` (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目表';
```

### 3.2 项目成员表 (project_members)

`project_members` 表存储项目成员及其角色信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 主键 |
| project_id | BIGINT | 否 | 是 | 项目ID |
| user_id | BIGINT | 否 | 是 | 用户ID |
| role | ENUM | 否 | 是 | 成员角色 |
| joined_at | DATETIME | 否 | 是 | 加入时间 |

**角色枚举**：
- `owner` - 负责人
- `admin` - 管理员
- `developer` - 开发者
- `tester` - 测试者
- `viewer` - 观察者

**建表语句**：

```sql
CREATE TABLE `project_members` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `project_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `role` VARCHAR(20) NOT NULL DEFAULT 'tester' COMMENT '成员角色',
    `joined_at` DATETIME(6) NOT NULL COMMENT '加入时间',
    CONSTRAINT `project_members_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `project_members_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_project_user` (`project_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目成员表';
```

### 3.3 项目环境表 (project_environments)

`project_environments` 表存储项目环境配置信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 主键 |
| project_id | BIGINT | 否 | 是 | 项目ID |
| name | VARCHAR(100) | 否 | 是 | 环境名称 |
| base_url | VARCHAR(500) | 否 | 是 | 基础URL |
| description | TEXT | 否 | 否 | 环境描述 |
| variables | JSON | 否 | 是 | 环境变量 |
| is_default | BOOLEAN | 否 | 是 | 是否默认环境 |
| created_at | DATETIME | 否 | 是 | 创建时间 |

**建表语句**：

```sql
CREATE TABLE `project_environments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `project_id` BIGINT NOT NULL,
    `name` VARCHAR(100) NOT NULL COMMENT '环境名称',
    `base_url` VARCHAR(500) NOT NULL COMMENT '基础URL',
    `description` TEXT DEFAULT NULL COMMENT '环境描述',
    `variables` JSON DEFAULT ('{}') COMMENT '环境变量',
    `is_default` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否默认环境',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    CONSTRAINT `project_environments_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
    INDEX `idx_project_environments_project` (`project_id`),
    INDEX `idx_project_environments_default` (`project_id`, `is_default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目环境表';
```

---

## 4. 测试用例模块 (testcases)

### 4.1 测试用例表 (testcases)

`testcases` 表存储手工测试用例的核心信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 用例ID |
| project_id | BIGINT | 否 | 是 | 项目ID |
| title | VARCHAR(500) | 否 | 是 | 用例标题 |
| description | TEXT | 否 | 否 | 用例描述 |
| preconditions | TEXT | 否 | 否 | 前置条件 |
| steps | TEXT | 否 | 否 | 操作步骤 |
| expected_result | TEXT | 否 | 是 | 预期结果 |
| priority | ENUM | 否 | 是 | 优先级 |
| status | ENUM | 否 | 是 | 用例状态 |
| test_type | ENUM | 否 | 是 | 测试类型 |
| tags | JSON | 否 | 是 | 标签列表 |
| author_id | BIGINT | 否 | 是 | 作者ID |
| assignee_id | BIGINT | 否 | 否 | 指派人ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**优先级枚举**：
- `low` - 低
- `medium` - 中
- `high` - 高
- `critical` - 紧急

**状态枚举**：
- `draft` - 草稿
- `active` - 激活
- `deprecated` - 废弃

**测试类型枚举**：
- `functional` - 功能测试
- `integration` - 集成测试
- `api` - API测试
- `ui` - UI测试
- `performance` - 性能测试
- `security` - 安全测试

**建表语句**：

```sql
CREATE TABLE `testcases` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用例ID',
    `project_id` BIGINT NOT NULL COMMENT '项目ID',
    `title` VARCHAR(500) NOT NULL COMMENT '用例标题',
    `description` TEXT DEFAULT NULL COMMENT '用例描述',
    `preconditions` TEXT DEFAULT NULL COMMENT '前置条件',
    `steps` VARCHAR(1000) DEFAULT NULL COMMENT '操作步骤',
    `expected_result` TEXT NOT NULL COMMENT '预期结果',
    `priority` VARCHAR(20) NOT NULL DEFAULT 'medium' COMMENT '优先级',
    `status` VARCHAR(20) NOT NULL DEFAULT 'draft' COMMENT '用例状态',
    `test_type` VARCHAR(20) NOT NULL DEFAULT 'functional' COMMENT '测试类型',
    `tags` JSON DEFAULT ('[]') COMMENT '标签列表',
    `author_id` INT NOT NULL COMMENT '作者ID',
    `assignee_id` INT DEFAULT NULL COMMENT '指派人ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `testcases_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `testcases_author_id_fkey` FOREIGN KEY (`author_id`) REFERENCES `users_user` (`id`),
    CONSTRAINT `testcases_assignee_id_fkey` FOREIGN KEY (`assignee_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL,
    INDEX `idx_testcases_project` (`project_id`),
    INDEX `idx_testcases_priority` (`priority`),
    INDEX `idx_testcases_status` (`status`),
    INDEX `idx_testcases_author` (`author_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试用例表';
```

### 4.2 用例步骤表 (testcase_steps)

`testcase_steps` 表存储测试用例的详细操作步骤。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 主键 |
| testcase_id | BIGINT | 否 | 是 | 用例ID |
| step_number | INT | 否 | 是 | 步骤序号 |
| action | TEXT | 否 | 是 | 操作描述 |
| expected | TEXT | 否 | 是 | 预期结果 |

**建表语句**：

```sql
CREATE TABLE `testcase_steps` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `testcase_id` BIGINT NOT NULL,
    `step_number` INT NOT NULL COMMENT '步骤序号',
    `action` TEXT NOT NULL COMMENT '操作描述',
    `expected` TEXT NOT NULL COMMENT '预期结果',
    CONSTRAINT `testcase_steps_testcase_id_fkey` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_testcase_step` (`testcase_id`, `step_number`),
    INDEX `idx_testcase_steps_case` (`testcase_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用例步骤表';
```

### 4.3 用例附件表 (testcase_attachments)

`testcase_attachments` 表存储测试用例的附件文件。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 主键 |
| testcase_id | BIGINT | 否 | 是 | 用例ID |
| name | VARCHAR(255) | 否 | 是 | 附件名称 |
| file | VARCHAR(100) | 否 | 是 | 文件路径 |
| uploaded_by_id | BIGINT | 否 | 是 | 上传人ID |
| uploaded_at | DATETIME | 否 | 是 | 上传时间 |

**建表语句**：

```sql
CREATE TABLE `testcase_attachments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `testcase_id` BIGINT NOT NULL,
    `name` VARCHAR(255) NOT NULL COMMENT '附件名称',
    `file` VARCHAR(100) NOT NULL COMMENT '文件路径',
    `uploaded_by_id` INT NOT NULL COMMENT '上传人ID',
    `uploaded_at` DATETIME(6) NOT NULL COMMENT '上传时间',
    CONSTRAINT `testcase_attachments_testcase_id_fkey` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE,
    CONSTRAINT `testcase_attachments_uploaded_by_id_fkey` FOREIGN KEY (`uploaded_by_id`) REFERENCES `users_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用例附件表';
```

### 4.4 用例评论表 (testcase_comments)

`testcase_comments` 表存储测试用例的评论信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 主键 |
| testcase_id | BIGINT | 否 | 是 | 用例ID |
| author_id | BIGINT | 否 | 是 | 评论人ID |
| content | TEXT | 否 | 是 | 评论内容 |
| created_at | DATETIME | 否 | 是 | 评论时间 |

**建表语句**：

```sql
CREATE TABLE `testcase_comments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `testcase_id` BIGINT NOT NULL,
    `author_id` INT NOT NULL COMMENT '评论人ID',
    `content` TEXT NOT NULL COMMENT '评论内容',
    `created_at` DATETIME(6) NOT NULL COMMENT '评论时间',
    CONSTRAINT `testcase_comments_testcase_id_fkey` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE,
    CONSTRAINT `testcase_comments_author_id_fkey` FOREIGN KEY (`author_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_testcase_comments_case` (`testcase_id`),
    INDEX `idx_testcase_comments_created` (`testcase_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用例评论表';
```

---

## 5. 测试执行模块 (executions)

### 5.1 测试计划表 (test_plans)

`test_plans` 表存储测试计划的配置信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 计划ID |
| name | VARCHAR(200) | 否 | 是 | 计划名称 |
| description | TEXT | 否 | 否 | 计划描述 |
| version_id | BIGINT | 否 | 否 | 版本ID |
| creator_id | BIGINT | 否 | 是 | 创建人ID |
| is_active | BOOLEAN | 否 | 是 | 是否激活 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `test_plans` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '计划ID',
    `name` VARCHAR(200) NOT NULL COMMENT '计划名称',
    `description` TEXT DEFAULT NULL COMMENT '计划描述',
    `version_id` BIGINT DEFAULT NULL COMMENT '版本ID',
    `creator_id` INT NOT NULL COMMENT '创建人ID',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否激活',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `test_plans_creator_id_fkey` FOREIGN KEY (`creator_id`) REFERENCES `users_user` (`id`),
    CONSTRAINT `test_plans_version_id_fkey` FOREIGN KEY (`version_id`) REFERENCES `versions` (`id`) ON DELETE SET NULL,
    INDEX `idx_test_plans_creator` (`creator_id`),
    INDEX `idx_test_plans_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试计划表';
```

### 5.2 测试执行记录表 (test_runs)

`test_runs` 表存储每次测试执行的信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 执行ID |
| name | VARCHAR(200) | 否 | 是 | 执行名称 |
| description | TEXT | 否 | 否 | 执行描述 |
| test_plan_id | BIGINT | 否 | 是 | 测试计划ID |
| project_id | BIGINT | 否 | 是 | 项目ID |
| version_id | BIGINT | 否 | 否 | 版本ID |
| assignee_id | BIGINT | 否 | 否 | 执行人ID |
| creator_id | BIGINT | 否 | 是 | 创建人ID |
| status | ENUM | 否 | 是 | 执行状态 |
| started_at | DATETIME | 否 | 否 | 开始时间 |
| completed_at | DATETIME | 否 | 否 | 完成时间 |
| due_date | DATETIME | 否 | 否 | 截止日期 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**状态枚举**：
- `untested` - 未测试
- `in_progress` - 进行中
- `completed` - 已完成
- `blocked` - 已阻塞

**建表语句**：

```sql
CREATE TABLE `test_runs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行ID',
    `name` VARCHAR(200) NOT NULL COMMENT '执行名称',
    `description` TEXT DEFAULT NULL COMMENT '执行描述',
    `test_plan_id` BIGINT NOT NULL COMMENT '测试计划ID',
    `project_id` BIGINT NOT NULL COMMENT '项目ID',
    `version_id` BIGINT DEFAULT NULL COMMENT '版本ID',
    `assignee_id` INT DEFAULT NULL COMMENT '执行人ID',
    `creator_id` INT NOT NULL COMMENT '创建人ID',
    `status` VARCHAR(20) NOT NULL DEFAULT 'untested' COMMENT '执行状态',
    `started_at` DATETIME(6) DEFAULT NULL COMMENT '开始时间',
    `completed_at` DATETIME(6) DEFAULT NULL COMMENT '完成时间',
    `due_date` DATETIME(6) DEFAULT NULL COMMENT '截止日期',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `test_runs_test_plan_id_fkey` FOREIGN KEY (`test_plan_id`) REFERENCES `test_plans` (`id`) ON DELETE CASCADE,
    CONSTRAINT `test_runs_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `test_runs_assignee_id_fkey` FOREIGN KEY (`assignee_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL,
    CONSTRAINT `test_runs_creator_id_fkey` FOREIGN KEY (`creator_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_test_runs_plan` (`test_plan_id`),
    INDEX `idx_test_runs_project` (`project_id`),
    INDEX `idx_test_runs_status` (`status`),
    INDEX `idx_test_runs_assignee` (`assignee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试执行记录表';
```

### 5.3 执行用例关联表 (test_run_cases)

`test_run_cases` 表存储测试执行与用例的关联关系及执行结果。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 主键 |
| test_run_id | BIGINT | 否 | 是 | 执行ID |
| testcase_id | BIGINT | 否 | 是 | 用例ID |
| status | ENUM | 否 | 是 | 执行状态 |
| priority | ENUM | 否 | 是 | 优先级 |
| actual_result | TEXT | 否 | 否 | 实际结果 |
| comments | TEXT | 否 | 否 | 备注 |
| defects | JSON | 否 | 是 | 关联缺陷 |
| elapsed_time | BIGINT | 否 | 否 | 执行耗时(毫秒) |
| executed_by_id | BIGINT | 否 | 否 | 执行者ID |
| executed_at | DATETIME | 否 | 否 | 执行时间 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**执行状态枚举**：
- `untested` - 未测试
- `passed` - 通过
- `failed` - 失败
- `blocked` - 阻塞
- `retest` - 重测

**建表语句**：

```sql
CREATE TABLE `test_run_cases` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `test_run_id` BIGINT NOT NULL COMMENT '执行ID',
    `testcase_id` BIGINT NOT NULL COMMENT '用例ID',
    `status` VARCHAR(20) NOT NULL DEFAULT 'untested' COMMENT '执行状态',
    `priority` VARCHAR(20) NOT NULL DEFAULT 'medium' COMMENT '优先级',
    `actual_result` TEXT DEFAULT NULL COMMENT '实际结果',
    `comments` TEXT DEFAULT NULL COMMENT '备注',
    `defects` JSON DEFAULT ('[]') COMMENT '关联缺陷',
    `elapsed_time` BIGINT DEFAULT NULL COMMENT '执行耗时(毫秒)',
    `executed_by_id` INT DEFAULT NULL COMMENT '执行者ID',
    `executed_at` DATETIME(6) DEFAULT NULL COMMENT '执行时间',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `test_run_cases_test_run_id_fkey` FOREIGN KEY (`test_run_id`) REFERENCES `test_runs` (`id`) ON DELETE CASCADE,
    CONSTRAINT `test_run_cases_testcase_id_fkey` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE,
    CONSTRAINT `test_run_cases_executed_by_id_fkey` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL,
    UNIQUE KEY `uk_run_case` (`test_run_id`, `testcase_id`),
    INDEX `idx_test_run_cases_run` (`test_run_id`),
    INDEX `idx_test_run_cases_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='执行用例关联表';
```

### 5.4 执行用例历史表 (test_run_case_history)

`test_run_case_history` 表存储执行用例的状态变更历史。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 主键 |
| run_case_id | BIGINT | 否 | 是 | 执行用例ID |
| status | VARCHAR(20) | 否 | 是 | 执行状态 |
| actual_result | TEXT | 否 | 否 | 实际结果 |
| comments | TEXT | 否 | 否 | 备注 |
| executed_by_id | BIGINT | 否 | 是 | 执行者ID |
| executed_at | DATETIME | 否 | 是 | 执行时间 |

**建表语句**：

```sql
CREATE TABLE `test_run_case_history` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `run_case_id` BIGINT NOT NULL COMMENT '执行用例ID',
    `status` VARCHAR(20) NOT NULL COMMENT '执行状态',
    `actual_result` TEXT DEFAULT NULL COMMENT '实际结果',
    `comments` TEXT DEFAULT NULL COMMENT '备注',
    `executed_by_id` INT NOT NULL COMMENT '执行者ID',
    `executed_at` DATETIME(6) NOT NULL COMMENT '执行时间',
    CONSTRAINT `test_run_case_history_run_case_id_fkey` FOREIGN KEY (`run_case_id`) REFERENCES `test_run_cases` (`id`) ON DELETE CASCADE,
    CONSTRAINT `test_run_case_history_executed_by_id_fkey` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_test_run_case_history_case` (`run_case_id`),
    INDEX `idx_test_run_case_history_executed` (`executed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='执行用例历史表';
```

---

## 6. AI 需求分析模块 (requirement_analysis)

### 6.1 需求文档表 (requirement_documents)

`requirement_documents` 表存储上传的需求文档信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 文档ID |
| title | VARCHAR(200) | 否 | 是 | 文档标题 |
| file | VARCHAR(100) | 否 | 是 | 文件路径 |
| document_type | ENUM | 否 | 是 | 文档类型 |
| status | ENUM | 否 | 是 | 处理状态 |
| uploaded_by_id | BIGINT | 否 | 是 | 上传人ID |
| project_id | BIGINT | 否 | 否 | 项目ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |
| file_size | BIGINT | 否 | 否 | 文件大小 |
| extracted_text | TEXT | 否 | 否 | 提取的文本 |

**文档类型枚举**：
- `pdf` - PDF文档
- `docx` - Word文档
- `txt` - 文本文件
- `md` - Markdown文档

**状态枚举**：
- `uploaded` - 已上传
- `analyzing` - 分析中
- `analyzed` - 已分析
- `failed` - 分析失败

**建表语句**：

```sql
CREATE TABLE `requirement_documents` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '文档ID',
    `title` VARCHAR(200) NOT NULL COMMENT '文档标题',
    `file` VARCHAR(100) NOT NULL COMMENT '文件路径',
    `document_type` VARCHAR(20) NOT NULL COMMENT '文档类型',
    `status` VARCHAR(20) NOT NULL DEFAULT 'uploaded' COMMENT '处理状态',
    `uploaded_by_id` INT NOT NULL COMMENT '上传人ID',
    `project_id` BIGINT DEFAULT NULL COMMENT '项目ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    `file_size` BIGINT DEFAULT NULL COMMENT '文件大小',
    `extracted_text` LONGTEXT DEFAULT NULL COMMENT '提取的文本',
    CONSTRAINT `requirement_documents_uploaded_by_id_fkey` FOREIGN KEY (`uploaded_by_id`) REFERENCES `users_user` (`id`),
    CONSTRAINT `requirement_documents_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE SET NULL,
    INDEX `idx_requirement_documents_project` (`project_id`),
    INDEX `idx_requirement_documents_status` (`status`),
    INDEX `idx_requirement_documents_uploader` (`uploaded_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='需求文档表';
```

### 6.2 需求分析表 (requirement_analyses)

`requirement_analyses` 表存储文档的分析结果。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 分析ID |
| document_id | BIGINT | 否 | 是 | 文档ID |
| analysis_report | TEXT | 否 | 否 | 分析报告 |
| requirements_count | INT | 否 | 是 | 需求数量 |
| analysis_time | FLOAT | 否 | 否 | 分析耗时(秒) |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `requirement_analyses` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '分析ID',
    `document_id` BIGINT NOT NULL UNIQUE COMMENT '文档ID',
    `analysis_report` LONGTEXT DEFAULT NULL COMMENT '分析报告',
    `requirements_count` INT NOT NULL DEFAULT 0 COMMENT '需求数量',
    `analysis_time` FLOAT DEFAULT NULL COMMENT '分析耗时(秒)',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `requirement_analyses_document_id_fkey` FOREIGN KEY (`document_id`) REFERENCES `requirement_documents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='需求分析表';
```

### 6.3 业务需求表 (business_requirements)

`business_requirements` 表存储从文档中提取的业务需求。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 需求ID |
| analysis_id | BIGINT | 否 | 是 | 分析ID |
| requirement_id | VARCHAR(50) | 否 | 是 | 需求编号 |
| requirement_name | VARCHAR(200) | 否 | 是 | 需求名称 |
| requirement_type | ENUM | 否 | 是 | 需求类型 |
| parent_requirement_id | BIGINT | 否 | 否 | 父级需求ID |
| module | VARCHAR(100) | 否 | 是 | 所属模块 |
| requirement_level | ENUM | 否 | 是 | 需求级别 |
| reviewer | VARCHAR(50) | 否 | 是 | 评审人 |
| estimated_hours | INT | 否 | 是 | 预计工时 |
| description | TEXT | 否 | 是 | 需求描述 |
| acceptance_criteria | TEXT | 否 | 否 | 验收标准 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**需求类型枚举**：
- `functional` - 功能需求
- `performance` - 性能需求
- `security` - 安全需求
- `usability` - 易用性需求
- `interface` - 接口需求
- `other` - 其他

**需求级别枚举**：
- `high` - 高
- `medium` - 中
- `low` - 低

**建表语句**：

```sql
CREATE TABLE `business_requirements` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '需求ID',
    `analysis_id` BIGINT NOT NULL COMMENT '分析ID',
    `requirement_id` VARCHAR(50) NOT NULL COMMENT '需求编号',
    `requirement_name` VARCHAR(200) NOT NULL COMMENT '需求名称',
    `requirement_type` VARCHAR(20) NOT NULL DEFAULT 'functional' COMMENT '需求类型',
    `parent_requirement_id` BIGINT DEFAULT NULL COMMENT '父级需求ID',
    `module` VARCHAR(100) NOT NULL COMMENT '所属模块',
    `requirement_level` VARCHAR(20) NOT NULL DEFAULT 'medium' COMMENT '需求级别',
    `reviewer` VARCHAR(50) NOT NULL DEFAULT 'admin' COMMENT '评审人',
    `estimated_hours` INT NOT NULL DEFAULT 8 COMMENT '预计工时',
    `description` TEXT NOT NULL COMMENT '需求描述',
    `acceptance_criteria` TEXT DEFAULT NULL COMMENT '验收标准',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `business_requirements_analysis_id_fkey` FOREIGN KEY (`analysis_id`) REFERENCES `requirement_analyses` (`id`) ON DELETE CASCADE,
    CONSTRAINT `business_requirements_parent_id_fkey` FOREIGN KEY (`parent_requirement_id`) REFERENCES `business_requirements` (`id`) ON DELETE SET NULL,
    UNIQUE KEY `uk_analysis_req_id` (`analysis_id`, `requirement_id`),
    INDEX `idx_business_requirements_analysis` (`analysis_id`),
    INDEX `idx_business_requirements_module` (`module`),
    INDEX `idx_business_requirements_level` (`requirement_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务需求表';
```

### 6.4 AI生成用例表 (generated_test_cases)

`generated_test_cases` 表存储 AI 生成的测试用例。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 用例ID |
| requirement_id | BIGINT | 否 | 是 | 需求ID |
| case_id | VARCHAR(50) | 否 | 是 | 用例编号 |
| title | VARCHAR(300) | 否 | 是 | 用例标题 |
| priority | ENUM | 否 | 是 | 优先级 |
| precondition | TEXT | 否 | 否 | 前置条件 |
| test_steps | TEXT | 否 | 否 | 测试步骤 |
| expected_result | TEXT | 否 | 否 | 预期结果 |
| status | ENUM | 否 | 是 | 用例状态 |
| generated_by_ai | VARCHAR(50) | 否 | 是 | 生成AI模型 |
| reviewed_by_ai | VARCHAR(50) | 否 | 否 | 评审AI模型 |
| review_comments | TEXT | 否 | 否 | 评审意见 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**优先级枚举**：
- `P0` - 最高
- `P1` - 高
- `P2` - 中
- `P3` - 低

**状态枚举**：
- `generated` - 已生成
- `reviewing` - 评审中
- `reviewed` - 已评审
- `approved` - 已批准
- `rejected` - 已拒绝
- `adopted` - 已采纳
- `discarded` - 已废弃

**建表语句**：

```sql
CREATE TABLE `generated_test_cases` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用例ID',
    `requirement_id` BIGINT NOT NULL COMMENT '需求ID',
    `case_id` VARCHAR(50) NOT NULL COMMENT '用例编号',
    `title` VARCHAR(300) NOT NULL COMMENT '用例标题',
    `priority` VARCHAR(10) NOT NULL DEFAULT 'P2' COMMENT '优先级',
    `precondition` TEXT DEFAULT NULL COMMENT '前置条件',
    `test_steps` TEXT DEFAULT NULL COMMENT '测试步骤',
    `expected_result` TEXT DEFAULT NULL COMMENT '预期结果',
    `status` VARCHAR(20) NOT NULL DEFAULT 'generated' COMMENT '用例状态',
    `generated_by_ai` VARCHAR(50) NOT NULL DEFAULT 'AI-A' COMMENT '生成AI模型',
    `reviewed_by_ai` VARCHAR(50) DEFAULT NULL COMMENT '评审AI模型',
    `review_comments` TEXT DEFAULT NULL COMMENT '评审意见',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `generated_test_cases_requirement_id_fkey` FOREIGN KEY (`requirement_id`) REFERENCES `business_requirements` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_requirement_case` (`requirement_id`, `case_id`),
    INDEX `idx_generated_test_cases_requirement` (`requirement_id`),
    INDEX `idx_generated_test_cases_status` (`status`),
    INDEX `idx_generated_test_cases_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI生成用例表';
```

### 6.5 AI模型配置表 (ai_model_config)

`ai_model_config` 表存储 AI 模型的配置信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 配置ID |
| name | VARCHAR(100) | 否 | 是 | 配置名称 |
| model_type | ENUM | 否 | 是 | 模型类型 |
| role | ENUM | 否 | 是 | 角色类型 |
| api_key | VARCHAR(200) | 否 | 否 | API密钥 |
| base_url | VARCHAR(500) | 否 | 是 | API Base URL |
| model_name | VARCHAR(100) | 否 | 是 | 模型名称 |
| max_tokens | INT | 否 | 是 | 最大Token数 |
| temperature | FLOAT | 否 | 是 | 温度参数 |
| top_p | FLOAT | 否 | 是 | Top P参数 |
| is_active | BOOLEAN | 否 | 是 | 是否启用 |
| created_by_id | BIGINT | 否 | 是 | 创建者ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**模型类型枚举**：
- `deepseek` - DeepSeek
- `qwen` - 通义千问
- `siliconflow` - 硅基流动
- `zhipu` - 智谱
- `other` - 其他

**角色枚举**：
- `writer` - 测试用例编写专家
- `reviewer` - 测试评审专家
- `browser_use_text` - Browser Use文本模式

**建表语句**：

```sql
CREATE TABLE `ai_model_config` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    `name` VARCHAR(100) NOT NULL COMMENT '配置名称',
    `model_type` VARCHAR(20) NOT NULL COMMENT '模型类型',
    `role` VARCHAR(20) NOT NULL COMMENT '角色类型',
    `api_key` VARCHAR(200) DEFAULT NULL COMMENT 'API密钥',
    `base_url` VARCHAR(500) NOT NULL COMMENT 'API Base URL',
    `model_name` VARCHAR(100) NOT NULL COMMENT '模型名称',
    `max_tokens` INT NOT NULL DEFAULT 4096 COMMENT '最大Token数',
    `temperature` FLOAT NOT NULL DEFAULT 0.7 COMMENT '温度参数',
    `top_p` FLOAT NOT NULL DEFAULT 0.9 COMMENT 'Top P参数',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用',
    `created_by_id` INT NOT NULL COMMENT '创建者ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `ai_model_config_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_ai_model_config_type_role` (`model_type`, `role`),
    INDEX `idx_ai_model_config_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI模型配置表';
```

### 6.6 提示词配置表 (prompt_config)

`prompt_config` 表存储 AI 提示词模板配置。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 配置ID |
| name | VARCHAR(100) | 否 | 是 | 配置名称 |
| prompt_type | ENUM | 否 | 是 | 提示词类型 |
| content | TEXT | 否 | 是 | 提示词内容 |
| is_active | BOOLEAN | 否 | 是 | 是否启用 |
| created_by_id | BIGINT | 否 | 是 | 创建者ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**提示词类型枚举**：
- `writer` - 用例编写提示词
- `reviewer` - 用例评审提示词

**建表语句**：

```sql
CREATE TABLE `prompt_config` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    `name` VARCHAR(100) NOT NULL COMMENT '配置名称',
    `prompt_type` VARCHAR(20) NOT NULL COMMENT '提示词类型',
    `content` TEXT NOT NULL COMMENT '提示词内容',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用',
    `created_by_id` INT NOT NULL COMMENT '创建者ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `prompt_config_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_prompt_config_type` (`prompt_type`),
    INDEX `idx_prompt_config_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='提示词配置表';
```

### 6.7 生成配置表 (generation_config)

`generation_config` 表存储 AI 用例生成的全局配置。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 配置ID |
| name | VARCHAR(100) | 否 | 是 | 配置名称 |
| default_output_mode | ENUM | 否 | 是 | 默认输出模式 |
| enable_auto_review | BOOLEAN | 否 | 是 | 启用AI评审 |
| review_timeout | INT | 否 | 是 | 评审超时(秒) |
| is_active | BOOLEAN | 否 | 是 | 是否启用 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**输出模式枚举**：
- `stream` - 实时流式输出
- `complete` - 完整输出

**建表语句**：

```sql
CREATE TABLE `generation_config` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    `name` VARCHAR(100) NOT NULL COMMENT '配置名称',
    `default_output_mode` VARCHAR(10) NOT NULL DEFAULT 'stream' COMMENT '默认输出模式',
    `enable_auto_review` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '启用AI评审',
    `review_timeout` INT NOT NULL DEFAULT 120 COMMENT '评审超时(秒)',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='生成配置表';
```

---

## 7. API 测试模块 (api_testing)

### 7.1 API项目表 (api_projects)

`api_projects` 表存储 API 测试项目信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 项目ID |
| name | VARCHAR(200) | 否 | 是 | 项目名称 |
| description | TEXT | 否 | 否 | 项目描述 |
| project_type | ENUM | 否 | 是 | 项目类型 |
| status | ENUM | 否 | 是 | 项目状态 |
| start_date | DATE | 否 | 否 | 开始日期 |
| end_date | DATE | 否 | 否 | 结束日期 |
| owner_id | BIGINT | 否 | 是 | 负责人ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**项目类型枚举**：
- `HTTP` - HTTP API
- `WEBSOCKET` - WebSocket

**状态枚举**：
- `NOT_STARTED` - 未开始
- `IN_PROGRESS` - 进行中
- `COMPLETED` - 已完成

**建表语句**：

```sql
CREATE TABLE `api_projects` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '项目ID',
    `name` VARCHAR(200) NOT NULL COMMENT '项目名称',
    `description` TEXT DEFAULT NULL COMMENT '项目描述',
    `project_type` VARCHAR(20) NOT NULL DEFAULT 'HTTP' COMMENT '项目类型',
    `status` VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED' COMMENT '项目状态',
    `start_date` DATE DEFAULT NULL COMMENT '开始日期',
    `end_date` DATE DEFAULT NULL COMMENT '结束日期',
    `owner_id` INT NOT NULL COMMENT '负责人ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `api_projects_owner_id_fkey` FOREIGN KEY (`owner_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_api_projects_owner` (`owner_id`),
    INDEX `idx_api_projects_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API项目表';
```

### 7.2 API集合表 (api_collections)

`api_collections` 表存储 API 请求集合。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 集合ID |
| name | VARCHAR(200) | 否 | 是 | 集合名称 |
| description | TEXT | 否 | 否 | 集合描述 |
| order | INT | 否 | 是 | 排序序号 |
| project_id | BIGINT | 否 | 是 | 项目ID |
| parent_id | BIGINT | 否 | 否 | 父集合ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `api_collections` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '集合ID',
    `name` VARCHAR(200) NOT NULL COMMENT '集合名称',
    `description` TEXT DEFAULT NULL COMMENT '集合描述',
    `order` INT NOT NULL DEFAULT 0 COMMENT '排序序号',
    `project_id` BIGINT NOT NULL COMMENT '项目ID',
    `parent_id` BIGINT DEFAULT NULL COMMENT '父集合ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `api_collections_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `api_projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `api_collections_parent_id_fkey` FOREIGN KEY (`parent_id`) REFERENCES `api_collections` (`id`) ON DELETE CASCADE,
    INDEX `idx_api_collections_project` (`project_id`),
    INDEX `idx_api_collections_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API集合表';
```

### 7.3 API请求表 (api_requests)

`api_requests` 表存储 API 请求的完整配置。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 请求ID |
| collection_id | BIGINT | 否 | 否 | 集合ID |
| name | VARCHAR(200) | 否 | 是 | 请求名称 |
| description | TEXT | 否 | 否 | 请求描述 |
| request_type | ENUM | 否 | 是 | 请求类型 |
| method | ENUM | 否 | 是 | HTTP方法 |
| url | TEXT | 否 | 是 | 请求URL |
| headers | JSON | 否 | 是 | 请求头 |
| params | JSON | 否 | 是 | URL参数 |
| body | JSON | 否 | 是 | 请求体 |
| auth | JSON | 否 | 是 | 认证信息 |
| pre_request_script | TEXT | 否 | 否 | 请求前脚本 |
| post_request_script | TEXT | 否 | 否 | 请求后脚本 |
| assertions | JSON | 否 | 是 | 断言规则 |
| order | INT | 否 | 是 | 排序序号 |
| created_by_id | BIGINT | 否 | 是 | 创建者ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**请求类型枚举**：
- `HTTP` - HTTP请求
- `WEBSOCKET` - WebSocket

**HTTP方法枚举**：
- `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD`, `OPTIONS`

**建表语句**：

```sql
CREATE TABLE `api_requests` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '请求ID',
    `collection_id` BIGINT DEFAULT NULL COMMENT '集合ID',
    `name` VARCHAR(200) NOT NULL COMMENT '请求名称',
    `description` TEXT DEFAULT NULL COMMENT '请求描述',
    `request_type` VARCHAR(20) NOT NULL DEFAULT 'HTTP' COMMENT '请求类型',
    `method` VARCHAR(10) NOT NULL COMMENT 'HTTP方法',
    `url` TEXT NOT NULL COMMENT '请求URL',
    `headers` JSON DEFAULT ('{}') COMMENT '请求头',
    `params` JSON DEFAULT ('{}') COMMENT 'URL参数',
    `body` JSON DEFAULT ('{}') COMMENT '请求体',
    `auth` JSON DEFAULT ('{}') COMMENT '认证信息',
    `pre_request_script` TEXT DEFAULT NULL COMMENT '请求前脚本',
    `post_request_script` TEXT DEFAULT NULL COMMENT '请求后脚本',
    `assertions` JSON DEFAULT ('[]') COMMENT '断言规则',
    `order` INT NOT NULL DEFAULT 0 COMMENT '排序序号',
    `created_by_id` INT NOT NULL COMMENT '创建者ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `api_requests_collection_id_fkey` FOREIGN KEY (`collection_id`) REFERENCES `api_collections` (`id`) ON DELETE CASCADE,
    CONSTRAINT `api_requests_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_api_requests_collection` (`collection_id`),
    INDEX `idx_api_requests_method` (`method`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API请求表';
```

### 7.4 环境配置表 (api_environments)

`api_environments` 表存储 API 测试环境配置。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 环境ID |
| name | VARCHAR(200) | 否 | 是 | 环境名称 |
| scope | ENUM | 否 | 是 | 作用域 |
| variables | JSON | 否 | 是 | 环境变量 |
| is_active | BOOLEAN | 否 | 是 | 是否激活 |
| project_id | BIGINT | 否 | 否 | 项目ID |
| created_by_id | BIGINT | 否 | 是 | 创建者ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**作用域枚举**：
- `GLOBAL` - 全局
- `LOCAL` - 本地

**建表语句**：

```sql
CREATE TABLE `api_environments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '环境ID',
    `name` VARCHAR(200) NOT NULL COMMENT '环境名称',
    `scope` VARCHAR(20) NOT NULL DEFAULT 'LOCAL' COMMENT '作用域',
    `variables` JSON DEFAULT ('{}') COMMENT '环境变量',
    `is_active` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否激活',
    `project_id` BIGINT DEFAULT NULL COMMENT '项目ID',
    `created_by_id` INT NOT NULL COMMENT '创建者ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `api_environments_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `api_projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `api_environments_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_api_environments_project` (`project_id`),
    INDEX `idx_api_environments_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='环境配置表';
```

### 7.5 请求历史表 (api_request_histories)

`api_request_histories` 表存储 API 请求的执行历史。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 历史ID |
| request_id | BIGINT | 否 | 是 | 请求ID |
| environment_id | BIGINT | 否 | 否 | 环境ID |
| request_data | JSON | 否 | 是 | 请求数据 |
| response_data | JSON | 否 | 否 | 响应数据 |
| status_code | INT | 否 | 否 | HTTP状态码 |
| response_time | FLOAT | 否 | 否 | 响应时间(ms) |
| error_message | TEXT | 否 | 否 | 错误信息 |
| assertions_results | JSON | 否 | 否 | 断言结果 |
| executed_by_id | BIGINT | 否 | 是 | 执行者ID |
| executed_at | DATETIME | 否 | 是 | 执行时间 |

**建表语句**：

```sql
CREATE TABLE `api_request_histories` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '历史ID',
    `request_id` BIGINT NOT NULL COMMENT '请求ID',
    `environment_id` BIGINT DEFAULT NULL COMMENT '环境ID',
    `request_data` JSON NOT NULL COMMENT '请求数据',
    `response_data` JSON DEFAULT NULL COMMENT '响应数据',
    `status_code` INT DEFAULT NULL COMMENT 'HTTP状态码',
    `response_time` FLOAT DEFAULT NULL COMMENT '响应时间(ms)',
    `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
    `assertions_results` JSON DEFAULT NULL COMMENT '断言结果',
    `executed_by_id` INT NOT NULL COMMENT '执行者ID',
    `executed_at` DATETIME(6) NOT NULL COMMENT '执行时间',
    CONSTRAINT `api_request_histories_request_id_fkey` FOREIGN KEY (`request_id`) REFERENCES `api_requests` (`id`) ON DELETE CASCADE,
    CONSTRAINT `api_request_histories_executed_by_id_fkey` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_api_request_histories_request` (`request_id`),
    INDEX `idx_api_request_histories_executed` (`executed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='请求历史表';
```

### 7.6 定时任务表 (api_scheduled_tasks)

`api_scheduled_tasks` 表存储 API 测试的定时任务配置。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 任务ID |
| name | VARCHAR(200) | 否 | 是 | 任务名称 |
| description | TEXT | 否 | 否 | 任务描述 |
| task_type | ENUM | 否 | 是 | 任务类型 |
| trigger_type | ENUM | 否 | 是 | 触发器类型 |
| cron_expression | VARCHAR(100) | 否 | 否 | Cron表达式 |
| interval_seconds | INT | 否 | 否 | 间隔秒数 |
| execute_at | DATETIME | 否 | 否 | 执行时间 |
| test_suite_id | BIGINT | 否 | 否 | 测试套件ID |
| api_request_id | BIGINT | 否 | 否 | API请求ID |
| environment_id | BIGINT | 否 | 否 | 环境ID |
| status | ENUM | 否 | 是 | 任务状态 |
| last_run_time | DATETIME | 否 | 否 | 最后运行时间 |
| next_run_time | DATETIME | 否 | 否 | 下次运行时间 |
| total_runs | INT | 否 | 是 | 总运行次数 |
| successful_runs | INT | 否 | 是 | 成功运行次数 |
| failed_runs | INT | 否 | 是 | 失败运行次数 |
| last_result | JSON | 否 | 是 | 最后执行结果 |
| error_message | TEXT | 否 | 否 | 错误信息 |
| notify_on_success | BOOLEAN | 否 | 是 | 成功时通知 |
| notify_on_failure | BOOLEAN | 否 | 是 | 失败时通知 |
| notify_emails | JSON | 否 | 是 | 通知邮箱列表 |
| created_by_id | BIGINT | 否 | 是 | 创建者ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**任务类型枚举**：
- `TEST_SUITE` - 测试套件
- `API_REQUEST` - API请求

**触发器类型枚举**：
- `CRON` - Cron表达式
- `INTERVAL` - 间隔执行
- `ONCE` - 单次执行

**任务状态枚举**：
- `ACTIVE` - 运行中
- `PAUSED` - 已暂停
- `COMPLETED` - 已完成
- `FAILED` - 失败

**建表语句**：

```sql
CREATE TABLE `api_scheduled_tasks` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '任务ID',
    `name` VARCHAR(200) NOT NULL COMMENT '任务名称',
    `description` TEXT DEFAULT NULL COMMENT '任务描述',
    `task_type` VARCHAR(20) NOT NULL COMMENT '任务类型',
    `trigger_type` VARCHAR(20) NOT NULL COMMENT '触发器类型',
    `cron_expression` VARCHAR(100) DEFAULT NULL COMMENT 'Cron表达式',
    `interval_seconds` INT DEFAULT NULL COMMENT '间隔秒数',
    `execute_at` DATETIME(6) DEFAULT NULL COMMENT '执行时间',
    `test_suite_id` BIGINT DEFAULT NULL COMMENT '测试套件ID',
    `api_request_id` BIGINT DEFAULT NULL COMMENT 'API请求ID',
    `environment_id` BIGINT DEFAULT NULL COMMENT '环境ID',
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '任务状态',
    `last_run_time` DATETIME(6) DEFAULT NULL COMMENT '最后运行时间',
    `next_run_time` DATETIME(6) DEFAULT NULL COMMENT '下次运行时间',
    `total_runs` INT NOT NULL DEFAULT 0 COMMENT '总运行次数',
    `successful_runs` INT NOT NULL DEFAULT 0 COMMENT '成功运行次数',
    `failed_runs` INT NOT NULL DEFAULT 0 COMMENT '失败运行次数',
    `last_result` JSON DEFAULT ('{}') COMMENT '最后执行结果',
    `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
    `notify_on_success` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '成功时通知',
    `notify_on_failure` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '失败时通知',
    `notify_emails` JSON DEFAULT ('[]') COMMENT '通知邮箱列表',
    `created_by_id` INT NOT NULL COMMENT '创建者ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `api_scheduled_tasks_test_suite_id_fkey` FOREIGN KEY (`test_suite_id`) REFERENCES `api_test_suites` (`id`) ON DELETE SET NULL,
    CONSTRAINT `api_scheduled_tasks_api_request_id_fkey` FOREIGN KEY (`api_request_id`) REFERENCES `api_requests` (`id`) ON DELETE SET NULL,
    CONSTRAINT `api_scheduled_tasks_environment_id_fkey` FOREIGN KEY (`environment_id`) REFERENCES `api_environments` (`id`) ON DELETE SET NULL,
    CONSTRAINT `api_scheduled_tasks_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_api_scheduled_tasks_status` (`status`),
    INDEX `idx_api_scheduled_tasks_next_run` (`next_run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='定时任务表';
```

---

## 8. UI 自动化测试模块 (ui_automation)

### 8.1 UI项目表 (ui_projects)

`ui_projects` 表存储 UI 自动化测试项目信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 项目ID |
| name | VARCHAR(200) | 否 | 是 | 项目名称 |
| description | TEXT | 否 | 否 | 项目描述 |
| status | ENUM | 否 | 是 | 项目状态 |
| base_url | VARCHAR(500) | 否 | 是 | 基础URL |
| start_date | DATE | 否 | 否 | 开始日期 |
| end_date | DATE | 否 | 否 | 结束日期 |
| owner_id | BIGINT | 否 | 是 | 负责人ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `ui_projects` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '项目ID',
    `name` VARCHAR(200) NOT NULL COMMENT '项目名称',
    `description` TEXT DEFAULT NULL COMMENT '项目描述',
    `status` VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED' COMMENT '项目状态',
    `base_url` VARCHAR(500) NOT NULL COMMENT '基础URL',
    `start_date` DATE DEFAULT NULL COMMENT '开始日期',
    `end_date` DATE DEFAULT NULL COMMENT '结束日期',
    `owner_id` INT NOT NULL COMMENT '负责人ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `ui_projects_owner_id_fkey` FOREIGN KEY (`owner_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_ui_projects_owner` (`owner_id`),
    INDEX `idx_ui_projects_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI项目表';
```

### 8.2 UI元素表 (ui_elements)

`ui_elements` 表存储 UI 自动化测试的元素定位信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 元素ID |
| project_id | BIGINT | 否 | 是 | 项目ID |
| group_id | BIGINT | 否 | 否 | 分组ID |
| name | VARCHAR(200) | 否 | 是 | 元素名称 |
| description | TEXT | 否 | 否 | 元素描述 |
| element_type | ENUM | 否 | 是 | 元素类型 |
| locator_strategy_id | BIGINT | 否 | 是 | 定位策略ID |
| locator_value | VARCHAR(500) | 否 | 是 | 定位表达式 |
| backup_locators | JSON | 否 | 否 | 备用定位器 |
| page | VARCHAR(200) | 否 | 否 | 所属页面 |
| component_name | VARCHAR(100) | 否 | 否 | 组件名称 |
| parent_element_id | BIGINT | 否 | 否 | 父元素ID |
| is_unique | BOOLEAN | 否 | 是 | 是否唯一 |
| wait_timeout | INT | 否 | 是 | 等待超时(秒) |
| is_visible | BOOLEAN | 否 | 是 | 是否可见 |
| is_enabled | BOOLEAN | 否 | 是 | 是否启用 |
| force_action | BOOLEAN | 否 | 是 | 强制操作 |
| usage_count | INT | 否 | 是 | 使用次数 |
| last_validated | DATETIME | 否 | 否 | 最后验证时间 |
| validation_status | ENUM | 否 | 是 | 验证状态 |
| validation_message | TEXT | 否 | 否 | 验证消息 |
| created_by_id | BIGINT | 否 | 否 | 创建人ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**元素类型枚举**：
- `INPUT` - 输入框
- `BUTTON` - 按钮
- `LINK` - 链接
- `DROPDOWN` - 下拉框
- `CHECKBOX` - 复选框
- `RADIO` - 单选框
- `TEXT` - 文本
- `IMAGE` - 图片
- `CONTAINER` - 容器
- `TABLE` - 表格
- `FORM` - 表单
- `MODAL` - 弹窗

**验证状态枚举**：
- `VALID` - 有效
- `INVALID` - 无效
- `UNKNOWN` - 未知
- `PENDING` - 待验证

**建表语句**：

```sql
CREATE TABLE `ui_elements` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '元素ID',
    `project_id` BIGINT NOT NULL COMMENT '项目ID',
    `group_id` BIGINT DEFAULT NULL COMMENT '分组ID',
    `name` VARCHAR(200) NOT NULL COMMENT '元素名称',
    `description` TEXT DEFAULT NULL COMMENT '元素描述',
    `element_type` VARCHAR(20) NOT NULL COMMENT '元素类型',
    `locator_strategy_id` INT NOT NULL COMMENT '定位策略ID',
    `locator_value` VARCHAR(500) NOT NULL COMMENT '定位表达式',
    `backup_locators` JSON DEFAULT NULL COMMENT '备用定位器',
    `page` VARCHAR(200) DEFAULT NULL COMMENT '所属页面',
    `component_name` VARCHAR(100) DEFAULT NULL COMMENT '组件名称',
    `parent_element_id` BIGINT DEFAULT NULL COMMENT '父元素ID',
    `is_unique` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否唯一',
    `wait_timeout` INT NOT NULL DEFAULT 5 COMMENT '等待超时(秒)',
    `is_visible` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否可见',
    `is_enabled` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用',
    `force_action` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '强制操作',
    `usage_count` INT NOT NULL DEFAULT 0 COMMENT '使用次数',
    `last_validated` DATETIME(6) DEFAULT NULL COMMENT '最后验证时间',
    `validation_status` VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN' COMMENT '验证状态',
    `validation_message` TEXT DEFAULT NULL COMMENT '验证消息',
    `created_by_id` INT DEFAULT NULL COMMENT '创建人ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `ui_elements_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `ui_elements_group_id_fkey` FOREIGN KEY (`group_id`) REFERENCES `ui_element_groups` (`id`) ON DELETE SET NULL,
    CONSTRAINT `ui_elements_locator_strategy_id_fkey` FOREIGN KEY (`locator_strategy_id`) REFERENCES `locator_strategies` (`id`),
    CONSTRAINT `ui_elements_parent_element_id_fkey` FOREIGN KEY (`parent_element_id`) REFERENCES `ui_elements` (`id`) ON DELETE SET NULL,
    CONSTRAINT `ui_elements_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL,
    INDEX `idx_ui_elements_project` (`project_id`),
    INDEX `idx_ui_elements_page` (`page`),
    INDEX `idx_ui_elements_type` (`element_type`),
    INDEX `idx_ui_elements_validation` (`validation_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI元素表';
```

### 8.3 测试脚本表 (ui_test_scripts)

`ui_test_scripts` 表存储 UI 自动化测试脚本。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 脚本ID |
| project_id | BIGINT | 否 | 是 | 项目ID |
| name | VARCHAR(200) | 否 | 是 | 脚本名称 |
| description | TEXT | 否 | 否 | 脚本描述 |
| script_type | ENUM | 否 | 是 | 脚本类型 |
| content | TEXT | 否 | 是 | 脚本内容 |
| language | ENUM | 否 | 否 | 脚本语言 |
| framework | ENUM | 否 | 否 | 执行框架 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**脚本类型枚举**：
- `CODE` - 代码脚本
- `LOW_CODE` - 低代码脚本
- `NO_CODE` - 无代码脚本

**脚本语言枚举**：
- `python`
- `javascript`

**执行框架枚举**：
- `playwright`
- `selenium`

**建表语句**：

```sql
CREATE TABLE `ui_test_scripts` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '脚本ID',
    `project_id` BIGINT NOT NULL COMMENT '项目ID',
    `name` VARCHAR(200) NOT NULL COMMENT '脚本名称',
    `description` TEXT DEFAULT NULL COMMENT '脚本描述',
    `script_type` VARCHAR(20) NOT NULL DEFAULT 'CODE' COMMENT '脚本类型',
    `content` TEXT NOT NULL COMMENT '脚本内容',
    `language` VARCHAR(20) DEFAULT NULL COMMENT '脚本语言',
    `framework` VARCHAR(20) DEFAULT NULL COMMENT '执行框架',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `ui_test_scripts_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE CASCADE,
    INDEX `idx_ui_test_scripts_project` (`project_id`),
    INDEX `idx_ui_test_scripts_type` (`script_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试脚本表';
```

### 8.4 脚本步骤表 (ui_script_steps)

`ui_script_steps` 表存储测试脚本的操作步骤。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 步骤ID |
| script_id | BIGINT | 否 | 是 | 脚本ID |
| step_order | INT | 否 | 是 | 步骤顺序 |
| action_type | ENUM | 否 | 是 | 操作类型 |
| target_element_id | BIGINT | 否 | 否 | 目标元素ID |
| page_object_id | BIGINT | 否 | 否 | 页面对象ID |
| action_params | JSON | 否 | 否 | 操作参数 |
| description | VARCHAR(500) | 否 | 否 | 步骤描述 |
| expected_result | VARCHAR(500) | 否 | 否 | 预期结果 |
| wait_before | INT | 否 | 是 | 执行前等待(毫秒) |
| wait_after | INT | 否 | 是 | 执行后等待(毫秒) |
| retry_count | INT | 否 | 是 | 重试次数 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**操作类型枚举**：
- `CLICK` - 点击
- `INPUT` - 输入
- `SELECT` - 选择
- `VERIFY` - 验证
- `WAIT` - 等待
- `HOVER` - 悬停
- `SCROLL` - 滚动
- `NAVIGATE` - 导航
- `SCREENSHOT` - 截图
- `SWITCH_TAB` - 切换标签
- `CUSTOM` - 自定义

**建表语句**：

```sql
CREATE TABLE `ui_script_steps` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '步骤ID',
    `script_id` BIGINT NOT NULL COMMENT '脚本ID',
    `step_order` INT NOT NULL COMMENT '步骤顺序',
    `action_type` VARCHAR(20) NOT NULL COMMENT '操作类型',
    `target_element_id` BIGINT DEFAULT NULL COMMENT '目标元素ID',
    `page_object_id` BIGINT DEFAULT NULL COMMENT '页面对象ID',
    `action_params` JSON DEFAULT NULL COMMENT '操作参数',
    `description` VARCHAR(500) DEFAULT NULL COMMENT '步骤描述',
    `expected_result` VARCHAR(500) DEFAULT NULL COMMENT '预期结果',
    `wait_before` INT NOT NULL DEFAULT 0 COMMENT '执行前等待(毫秒)',
    `wait_after` INT NOT NULL DEFAULT 0 COMMENT '执行后等待(毫秒)',
    `retry_count` INT NOT NULL DEFAULT 0 COMMENT '重试次数',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `ui_script_steps_script_id_fkey` FOREIGN KEY (`script_id`) REFERENCES `ui_test_scripts` (`id`) ON DELETE CASCADE,
    CONSTRAINT `ui_script_steps_target_element_id_fkey` FOREIGN KEY (`target_element_id`) REFERENCES `ui_elements` (`id`) ON DELETE SET NULL,
    CONSTRAINT `ui_script_steps_page_object_id_fkey` FOREIGN KEY (`page_object_id`) REFERENCES `ui_page_objects` (`id`) ON DELETE SET NULL,
    UNIQUE KEY `uk_script_step` (`script_id`, `step_order`),
    INDEX `idx_ui_script_steps_script` (`script_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='脚本步骤表';
```

### 8.5 UI测试执行表 (ui_test_executions)

`ui_test_executions` 表存储 UI 自动化测试的执行记录。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 执行ID |
| project_id | BIGINT | 否 | 是 | 项目ID |
| test_suite_id | BIGINT | 否 | 否 | 测试套件ID |
| test_script_id | BIGINT | 否 | 否 | 测试脚本ID |
| environment | VARCHAR(50) | 否 | 是 | 执行环境 |
| status | ENUM | 否 | 是 | 执行状态 |
| total_cases | INT | 否 | 是 | 总用例数 |
| passed_cases | INT | 否 | 是 | 通过用例数 |
| failed_cases | INT | 否 | 是 | 失败用例数 |
| skipped_cases | INT | 否 | 是 | 跳过用例数 |
| started_at | DATETIME | 否 | 否 | 开始时间 |
| finished_at | DATETIME | 否 | 否 | 结束时间 |
| duration | FLOAT | 否 | 是 | 执行时长(秒) |
| executed_by_id | BIGINT | 否 | 否 | 执行人员ID |
| engine | VARCHAR(50) | 否 | 是 | 测试引擎 |
| browser | VARCHAR(50) | 否 | 是 | 浏览器 |
| headless | BOOLEAN | 否 | 是 | 无头模式 |
| result_data | JSON | 否 | 否 | 执行结果数据 |
| error_message | TEXT | 否 | 否 | 错误信息 |
| report_url | VARCHAR(500) | 否 | 否 | 报告URL |
| created_at | DATETIME | 否 | 是 | 创建时间 |

**执行状态枚举**：
- `PENDING` - 待执行
- `RUNNING` - 执行中
- `SUCCESS` - 成功
- `FAILED` - 失败
- `ABORTED` - 中止

**环境枚举**：
- `CHROME`
- `FIREFOX`
- `SAFARI`
- `EDGE`
- `IE`

**建表语句**：

```sql
CREATE TABLE `ui_test_executions` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行ID',
    `project_id` BIGINT NOT NULL COMMENT '项目ID',
    `test_suite_id` BIGINT DEFAULT NULL COMMENT '测试套件ID',
    `test_script_id` BIGINT DEFAULT NULL COMMENT '测试脚本ID',
    `environment` VARCHAR(50) NOT NULL COMMENT '执行环境',
    `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '执行状态',
    `total_cases` INT NOT NULL DEFAULT 0 COMMENT '总用例数',
    `passed_cases` INT NOT NULL DEFAULT 0 COMMENT '通过用例数',
    `failed_cases` INT NOT NULL DEFAULT 0 COMMENT '失败用例数',
    `skipped_cases` INT NOT NULL DEFAULT 0 COMMENT '跳过用例数',
    `started_at` DATETIME(6) DEFAULT NULL COMMENT '开始时间',
    `finished_at` DATETIME(6) DEFAULT NULL COMMENT '结束时间',
    `duration` FLOAT NOT NULL DEFAULT 0 COMMENT '执行时长(秒)',
    `executed_by_id` INT DEFAULT NULL COMMENT '执行人员ID',
    `engine` VARCHAR(50) NOT NULL DEFAULT 'playwright' COMMENT '测试引擎',
    `browser` VARCHAR(50) NOT NULL DEFAULT 'chrome' COMMENT '浏览器',
    `headless` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '无头模式',
    `result_data` JSON DEFAULT NULL COMMENT '执行结果数据',
    `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
    `report_url` VARCHAR(500) DEFAULT NULL COMMENT '报告URL',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    CONSTRAINT `ui_test_executions_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `ui_test_executions_test_suite_id_fkey` FOREIGN KEY (`test_suite_id`) REFERENCES `ui_test_suites` (`id`) ON DELETE SET NULL,
    CONSTRAINT `ui_test_executions_test_script_id_fkey` FOREIGN KEY (`test_script_id`) REFERENCES `ui_test_scripts` (`id`) ON DELETE SET NULL,
    CONSTRAINT `ui_test_executions_executed_by_id_fkey` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL,
    INDEX `idx_ui_test_executions_project` (`project_id`),
    INDEX `idx_ui_test_executions_status` (`status`),
    INDEX `idx_ui_test_executions_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI测试执行表';
```

### 8.6 UI定时任务表 (ui_scheduled_tasks)

`ui_scheduled_tasks` 表存储 UI 自动化测试的定时任务配置。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 任务ID |
| name | VARCHAR(200) | 否 | 是 | 任务名称 |
| description | TEXT | 否 | 否 | 任务描述 |
| task_type | ENUM | 否 | 是 | 任务类型 |
| trigger_type | ENUM | 否 | 是 | 触发器类型 |
| cron_expression | VARCHAR(100) | 否 | 否 | Cron表达式 |
| interval_seconds | INT | 否 | 否 | 间隔秒数 |
| execute_at | DATETIME | 否 | 否 | 执行时间 |
| project_id | BIGINT | 否 | 是 | 项目ID |
| test_suite_id | BIGINT | 否 | 否 | 测试套件ID |
| test_cases | JSON | 否 | 是 | 测试用例列表 |
| engine | VARCHAR(50) | 否 | 是 | 执行引擎 |
| browser | VARCHAR(50) | 否 | 是 | 浏览器类型 |
| headless | BOOLEAN | 否 | 是 | 无头模式 |
| notify_on_success | BOOLEAN | 否 | 是 | 成功时通知 |
| notify_on_failure | BOOLEAN | 否 | 是 | 失败时通知 |
| notification_type | VARCHAR(20) | 否 | 否 | 通知类型 |
| notify_emails | JSON | 否 | 是 | 通知邮箱列表 |
| status | ENUM | 否 | 是 | 任务状态 |
| last_run_time | DATETIME | 否 | 否 | 最后运行时间 |
| next_run_time | DATETIME | 否 | 否 | 下次运行时间 |
| total_runs | INT | 否 | 是 | 总运行次数 |
| successful_runs | INT | 否 | 是 | 成功运行次数 |
| failed_runs | INT | 否 | 是 | 失败运行次数 |
| last_result | JSON | 否 | 是 | 最后执行结果 |
| error_message | TEXT | 否 | 否 | 错误信息 |
| created_by_id | BIGINT | 否 | 是 | 创建者ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `ui_scheduled_tasks` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '任务ID',
    `name` VARCHAR(200) NOT NULL COMMENT '任务名称',
    `description` TEXT DEFAULT NULL COMMENT '任务描述',
    `task_type` VARCHAR(20) NOT NULL COMMENT '任务类型',
    `trigger_type` VARCHAR(20) NOT NULL COMMENT '触发器类型',
    `cron_expression` VARCHAR(100) DEFAULT NULL COMMENT 'Cron表达式',
    `interval_seconds` INT DEFAULT NULL COMMENT '间隔秒数',
    `execute_at` DATETIME(6) DEFAULT NULL COMMENT '执行时间',
    `project_id` BIGINT NOT NULL COMMENT '项目ID',
    `test_suite_id` BIGINT DEFAULT NULL COMMENT '测试套件ID',
    `test_cases` JSON DEFAULT ('[]') COMMENT '测试用例列表',
    `engine` VARCHAR(50) NOT NULL DEFAULT 'playwright' COMMENT '执行引擎',
    `browser` VARCHAR(50) NOT NULL DEFAULT 'chrome' COMMENT '浏览器类型',
    `headless` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '无头模式',
    `notify_on_success` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '成功时通知',
    `notify_on_failure` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '失败时通知',
    `notification_type` VARCHAR(20) DEFAULT NULL COMMENT '通知类型',
    `notify_emails` JSON DEFAULT ('[]') COMMENT '通知邮箱列表',
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '任务状态',
    `last_run_time` DATETIME(6) DEFAULT NULL COMMENT '最后运行时间',
    `next_run_time` DATETIME(6) DEFAULT NULL COMMENT '下次运行时间',
    `total_runs` INT NOT NULL DEFAULT 0 COMMENT '总运行次数',
    `successful_runs` INT NOT NULL DEFAULT 0 COMMENT '成功运行次数',
    `failed_runs` INT NOT NULL DEFAULT 0 COMMENT '失败运行次数',
    `last_result` JSON DEFAULT ('{}') COMMENT '最后执行结果',
    `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
    `created_by_id` INT NOT NULL COMMENT '创建者ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `ui_scheduled_tasks_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `ui_scheduled_tasks_test_suite_id_fkey` FOREIGN KEY (`test_suite_id`) REFERENCES `ui_test_suites` (`id`) ON DELETE SET NULL,
    CONSTRAINT `ui_scheduled_tasks_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_ui_scheduled_tasks_project` (`project_id`),
    INDEX `idx_ui_scheduled_tasks_status` (`status`),
    INDEX `idx_ui_scheduled_tasks_next_run` (`next_run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='UI定时任务表';
```

---

## 9. APP 自动化测试模块 (app_automation)

### 9.1 APP项目表 (app_projects)

`app_projects` 表存储 APP 自动化测试项目信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 项目ID |
| name | VARCHAR(200) | 否 | 是 | 项目名称 |
| description | TEXT | 否 | 否 | 项目描述 |
| status | ENUM | 否 | 是 | 项目状态 |
| start_date | DATE | 否 | 否 | 开始日期 |
| end_date | DATE | 否 | 否 | 结束日期 |
| owner_id | BIGINT | 否 | 是 | 负责人ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `app_projects` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '项目ID',
    `name` VARCHAR(200) NOT NULL COMMENT '项目名称',
    `description` TEXT DEFAULT NULL COMMENT '项目描述',
    `status` VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED' COMMENT '项目状态',
    `start_date` DATE DEFAULT NULL COMMENT '开始日期',
    `end_date` DATE DEFAULT NULL COMMENT '结束日期',
    `owner_id` INT NOT NULL COMMENT '负责人ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `app_projects_owner_id_fkey` FOREIGN KEY (`owner_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_app_projects_owner` (`owner_id`),
    INDEX `idx_app_projects_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP项目表';
```

### 9.2 设备表 (app_devices)

`app_devices` 表存储移动设备信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 设备ID |
| device_id | VARCHAR(255) | 否 | 是 | 设备序列号 |
| name | VARCHAR(255) | 否 | 否 | 设备名称 |
| status | VARCHAR(20) | 否 | 是 | 设备状态 |
| android_version | VARCHAR(50) | 否 | 否 | Android版本 |
| connection_type | ENUM | 否 | 是 | 连接类型 |
| ip_address | VARCHAR(50) | 否 | 否 | IP地址 |
| port | INT | 否 | 是 | 端口 |
| locked_by_id | BIGINT | 否 | 否 | 锁定用户ID |
| locked_at | DATETIME | 否 | 否 | 锁定时间 |
| max_allocation_time | INT | 否 | 是 | 最大分配时间(秒) |
| device_specs | JSON | 否 | 是 | 设备规格 |
| description | TEXT | 否 | 否 | 设备描述 |
| location | VARCHAR(200) | 否 | 否 | 设备位置 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**连接类型枚举**：
- `emulator` - 模拟器
- `remote_emulator` - 远程模拟器
- `real_device` - 真机

**建表语句**：

```sql
CREATE TABLE `app_devices` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '设备ID',
    `device_id` VARCHAR(255) NOT NULL UNIQUE COMMENT '设备序列号',
    `name` VARCHAR(255) DEFAULT NULL COMMENT '设备名称',
    `status` VARCHAR(20) NOT NULL COMMENT '设备状态',
    `android_version` VARCHAR(50) DEFAULT NULL COMMENT 'Android版本',
    `connection_type` VARCHAR(50) NOT NULL DEFAULT 'emulator' COMMENT '连接类型',
    `ip_address` VARCHAR(50) DEFAULT NULL COMMENT 'IP地址',
    `port` INT NOT NULL DEFAULT 5555 COMMENT '端口',
    `locked_by_id` INT DEFAULT NULL COMMENT '锁定用户ID',
    `locked_at` DATETIME(6) DEFAULT NULL COMMENT '锁定时间',
    `max_allocation_time` INT NOT NULL DEFAULT 28800 COMMENT '最大分配时间(秒)',
    `device_specs` JSON DEFAULT ('{}') COMMENT '设备规格',
    `description` TEXT DEFAULT NULL COMMENT '设备描述',
    `location` VARCHAR(200) DEFAULT NULL COMMENT '设备位置',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `app_devices_locked_by_id_fkey` FOREIGN KEY (`locked_by_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL,
    INDEX `idx_app_devices_device_id` (`device_id`),
    INDEX `idx_app_devices_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备表';
```

### 9.3 APP元素表 (app_elements)

`app_elements` 表存储 APP 自动化测试的元素信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 元素ID |
| project_id | BIGINT | 否 | 否 | 项目ID |
| name | VARCHAR(200) | 否 | 是 | 元素名称 |
| element_type | ENUM | 否 | 是 | 元素类型 |
| tags | JSON | 否 | 是 | 标签 |
| config | JSON | 否 | 是 | 元素配置 |
| resolution_configs | JSON | 否 | 是 | 分辨率配置 |
| usage_count | INT | 否 | 是 | 使用次数 |
| last_used_at | DATETIME | 否 | 否 | 最后使用时间 |
| created_by_id | BIGINT | 否 | 否 | 创建人ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |
| is_active | BOOLEAN | 否 | 是 | 是否启用 |

**元素类型枚举**：
- `IMAGE` - 图片识别
- `POS` - 坐标点
- `REGION` - 区域

**建表语句**：

```sql
CREATE TABLE `app_elements` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '元素ID',
    `project_id` BIGINT DEFAULT NULL COMMENT '项目ID',
    `name` VARCHAR(200) NOT NULL UNIQUE COMMENT '元素名称',
    `element_type` VARCHAR(20) NOT NULL COMMENT '元素类型',
    `tags` JSON DEFAULT ('[]') COMMENT '标签',
    `config` JSON NOT NULL DEFAULT ('{}') COMMENT '元素配置',
    `resolution_configs` JSON NOT NULL DEFAULT ('{}') COMMENT '分辨率配置',
    `usage_count` INT NOT NULL DEFAULT 0 COMMENT '使用次数',
    `last_used_at` DATETIME(6) DEFAULT NULL COMMENT '最后使用时间',
    `created_by_id` INT DEFAULT NULL COMMENT '创建人ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用',
    CONSTRAINT `app_elements_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `app_projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `app_elements_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL,
    INDEX `idx_app_elements_project` (`project_id`),
    INDEX `idx_app_elements_type` (`element_type`),
    INDEX `idx_app_elements_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP元素表';
```

### 9.4 APP测试用例表 (app_test_cases)

`app_test_cases` 表存储 APP 自动化测试用例。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 用例ID |
| project_id | BIGINT | 否 | 否 | 项目ID |
| name | VARCHAR(200) | 否 | 是 | 用例名称 |
| description | TEXT | 否 | 否 | 用例描述 |
| app_package_id | BIGINT | 否 | 否 | 应用包ID |
| ui_flow | JSON | 否 | 是 | UI流程定义 |
| variables | JSON | 否 | 是 | 变量定义 |
| timeout | INT | 否 | 是 | 超时时间(秒) |
| retry_count | INT | 否 | 是 | 失败重试次数 |
| created_by_id | BIGINT | 否 | 否 | 创建人ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `app_test_cases` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用例ID',
    `project_id` BIGINT DEFAULT NULL COMMENT '项目ID',
    `name` VARCHAR(200) NOT NULL COMMENT '用例名称',
    `description` TEXT DEFAULT NULL COMMENT '用例描述',
    `app_package_id` BIGINT DEFAULT NULL COMMENT '应用包ID',
    `ui_flow` JSON NOT NULL DEFAULT ('{}') COMMENT 'UI流程定义',
    `variables` JSON NOT NULL DEFAULT ('[]') COMMENT '变量定义',
    `timeout` INT NOT NULL DEFAULT 300 COMMENT '超时时间(秒)',
    `retry_count` INT NOT NULL DEFAULT 0 COMMENT '失败重试次数',
    `created_by_id` INT DEFAULT NULL COMMENT '创建人ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `app_test_cases_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `app_projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `app_test_cases_app_package_id_fkey` FOREIGN KEY (`app_package_id`) REFERENCES `app_packages` (`id`) ON DELETE SET NULL,
    CONSTRAINT `app_test_cases_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL,
    INDEX `idx_app_test_cases_project` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP测试用例表';
```

### 9.5 APP测试执行表 (app_test_executions)

`app_test_executions` 表存储 APP 自动化测试的执行记录。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 执行ID |
| test_case_id | BIGINT | 否 | 否 | 测试用例ID |
| test_suite_id | BIGINT | 否 | 否 | 测试套件ID |
| device_id | BIGINT | 否 | 否 | 设备ID |
| user_id | BIGINT | 否 | 否 | 执行用户ID |
| status | VARCHAR(20) | 否 | 是 | 执行状态 |
| result | VARCHAR(20) | 否 | 否 | 测试结果 |
| task_id | VARCHAR(255) | 否 | 否 | Celery任务ID |
| progress | INT | 否 | 是 | 执行进度(0-100) |
| started_at | DATETIME | 否 | 否 | 开始时间 |
| finished_at | DATETIME | 否 | 否 | 结束时间 |
| duration | FLOAT | 否 | 是 | 执行时长(秒) |
| report_path | VARCHAR(500) | 否 | 否 | Allure报告路径 |
| error_message | TEXT | 否 | 否 | 错误信息 |
| total_steps | INT | 否 | 是 | 总步骤数 |
| passed_steps | INT | 否 | 是 | 通过步骤数 |
| failed_steps | INT | 否 | 是 | 失败步骤数 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `app_test_executions` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行ID',
    `test_case_id` BIGINT DEFAULT NULL COMMENT '测试用例ID',
    `test_suite_id` BIGINT DEFAULT NULL COMMENT '测试套件ID',
    `device_id` BIGINT DEFAULT NULL COMMENT '设备ID',
    `user_id` INT DEFAULT NULL COMMENT '执行用户ID',
    `status` VARCHAR(20) NOT NULL COMMENT '执行状态',
    `result` VARCHAR(20) DEFAULT NULL COMMENT '测试结果',
    `task_id` VARCHAR(255) DEFAULT NULL COMMENT 'Celery任务ID',
    `progress` INT NOT NULL DEFAULT 0 COMMENT '执行进度(0-100)',
    `started_at` DATETIME(6) DEFAULT NULL COMMENT '开始时间',
    `finished_at` DATETIME(6) DEFAULT NULL COMMENT '结束时间',
    `duration` FLOAT NOT NULL DEFAULT 0 COMMENT '执行时长(秒)',
    `report_path` VARCHAR(500) DEFAULT NULL COMMENT 'Allure报告路径',
    `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
    `total_steps` INT NOT NULL DEFAULT 0 COMMENT '总步骤数',
    `passed_steps` INT NOT NULL DEFAULT 0 COMMENT '通过步骤数',
    `failed_steps` INT NOT NULL DEFAULT 0 COMMENT '失败步骤数',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `app_test_executions_test_case_id_fkey` FOREIGN KEY (`test_case_id`) REFERENCES `app_test_cases` (`id`) ON DELETE SET NULL,
    CONSTRAINT `app_test_executions_test_suite_id_fkey` FOREIGN KEY (`test_suite_id`) REFERENCES `app_test_suites` (`id`) ON DELETE SET NULL,
    CONSTRAINT `app_test_executions_device_id_fkey` FOREIGN KEY (`device_id`) REFERENCES `app_devices` (`id`) ON DELETE SET NULL,
    CONSTRAINT `app_test_executions_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL,
    INDEX `idx_app_test_executions_status` (`status`),
    INDEX `idx_app_test_executions_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP测试执行表';
```

---

## 10. 其他核心模块

### 10.1 测试报告表 (test_reports)

`test_reports` 表存储测试报告信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 报告ID |
| project_id | BIGINT | 否 | 是 | 项目ID |
| name | VARCHAR(200) | 否 | 是 | 报告名称 |
| report_type | ENUM | 否 | 是 | 报告类型 |
| execution_id | BIGINT | 否 | 否 | 关联执行ID |
| summary | JSON | 否 | 是 | 报告摘要 |
| content | JSON | 否 | 是 | 报告内容 |
| generated_by_id | BIGINT | 否 | 是 | 生成者ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |

**报告类型枚举**：
- `execution` - 执行报告
- `summary` - 汇总报告
- `trend` - 趋势报告

**建表语句**：

```sql
CREATE TABLE `test_reports` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '报告ID',
    `project_id` BIGINT NOT NULL COMMENT '项目ID',
    `name` VARCHAR(200) NOT NULL COMMENT '报告名称',
    `report_type` VARCHAR(20) NOT NULL DEFAULT 'execution' COMMENT '报告类型',
    `execution_id` BIGINT DEFAULT NULL COMMENT '关联执行ID',
    `summary` JSON NOT NULL DEFAULT ('{}') COMMENT '报告摘要',
    `content` JSON NOT NULL DEFAULT ('{}') COMMENT '报告内容',
    `generated_by_id` INT NOT NULL COMMENT '生成者ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    CONSTRAINT `test_reports_project_id_fkey` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
    CONSTRAINT `test_reports_execution_id_fkey` FOREIGN KEY (`execution_id`) REFERENCES `test_runs` (`id`) ON DELETE CASCADE,
    CONSTRAINT `test_reports_generated_by_id_fkey` FOREIGN KEY (`generated_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_test_reports_project` (`project_id`),
    INDEX `idx_test_reports_type` (`report_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试报告表';
```

### 10.2 评审表 (testcase_reviews)

`testcase_reviews` 表存储测试用例评审信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 评审ID |
| title | VARCHAR(500) | 否 | 是 | 评审标题 |
| description | TEXT | 否 | 否 | 评审描述 |
| creator_id | BIGINT | 否 | 是 | 创建人ID |
| template_id | BIGINT | 否 | 否 | 模板ID |
| status | ENUM | 否 | 是 | 评审状态 |
| priority | ENUM | 否 | 是 | 优先级 |
| deadline | DATETIME | 否 | 否 | 截止日期 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |
| completed_at | DATETIME | 否 | 否 | 完成时间 |

**评审状态枚举**：
- `pending` - 待评审
- `in_progress` - 评审中
- `approved` - 已批准
- `rejected` - 已拒绝
- `cancelled` - 已取消

**优先级枚举**：
- `low` - 低
- `medium` - 中
- `high` - 高
- `urgent` - 紧急

**建表语句**：

```sql
CREATE TABLE `testcase_reviews` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '评审ID',
    `title` VARCHAR(500) NOT NULL COMMENT '评审标题',
    `description` TEXT DEFAULT NULL COMMENT '评审描述',
    `creator_id` INT NOT NULL COMMENT '创建人ID',
    `template_id` BIGINT DEFAULT NULL COMMENT '模板ID',
    `status` VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '评审状态',
    `priority` VARCHAR(20) NOT NULL DEFAULT 'medium' COMMENT '优先级',
    `deadline` DATETIME(6) DEFAULT NULL COMMENT '截止日期',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    `completed_at` DATETIME(6) DEFAULT NULL COMMENT '完成时间',
    CONSTRAINT `testcase_reviews_creator_id_fkey` FOREIGN KEY (`creator_id`) REFERENCES `users_user` (`id`),
    CONSTRAINT `testcase_reviews_template_id_fkey` FOREIGN KEY (`template_id`) REFERENCES `review_templates` (`id`) ON DELETE SET NULL,
    INDEX `idx_testcase_reviews_status` (`status`),
    INDEX `idx_testcase_reviews_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评审表';
```

### 10.3 版本表 (versions)

`versions` 表存储版本信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 版本ID |
| name | VARCHAR(100) | 否 | 是 | 版本名称 |
| description | TEXT | 否 | 否 | 版本描述 |
| is_baseline | BOOLEAN | 否 | 是 | 是否为基线版本 |
| created_by_id | BIGINT | 否 | 是 | 创建者ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `versions` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '版本ID',
    `name` VARCHAR(100) NOT NULL COMMENT '版本名称',
    `description` TEXT DEFAULT NULL COMMENT '版本描述',
    `is_baseline` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否为基线版本',
    `created_by_id` INT NOT NULL COMMENT '创建者ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `versions_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_versions_baseline` (`is_baseline`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='版本表';
```

### 10.4 AI助手会话表 (assistant_sessions)

`assistant_sessions` 表存储 AI 助手的会话信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 会话ID |
| user_id | BIGINT | 否 | 是 | 用户ID |
| session_id | VARCHAR(200) | 否 | 是 | 会话ID |
| conversation_id | VARCHAR(200) | 否 | 否 | Dify对话ID |
| title | VARCHAR(500) | 否 | 否 | 会话标题 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `assistant_sessions` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '会话ID',
    `user_id` INT NOT NULL COMMENT '用户ID',
    `session_id` VARCHAR(200) NOT NULL COMMENT '会话ID',
    `conversation_id` VARCHAR(200) DEFAULT NULL COMMENT 'Dify对话ID',
    `title` VARCHAR(500) DEFAULT NULL COMMENT '会话标题',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `assistant_sessions_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE,
    INDEX `idx_assistant_sessions_user` (`user_id`),
    INDEX `idx_assistant_sessions_session_id` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI助手会话表';
```

### 10.5 聊天消息表 (chat_messages)

`chat_messages` 表存储 AI 助手的聊天消息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 消息ID |
| session_id | BIGINT | 否 | 是 | 会话ID |
| role | ENUM | 否 | 是 | 角色 |
| content | TEXT | 否 | 是 | 消息内容 |
| conversation_id | VARCHAR(200) | 否 | 否 | Dify对话ID |
| message_id | VARCHAR(200) | 否 | 否 | Dify消息ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |

**角色枚举**：
- `user` - 用户
- `assistant` - 助手

**建表语句**：

```sql
CREATE TABLE `chat_messages` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '消息ID',
    `session_id` BIGINT NOT NULL COMMENT '会话ID',
    `role` VARCHAR(20) NOT NULL COMMENT '角色',
    `content` LONGTEXT NOT NULL COMMENT '消息内容',
    `conversation_id` VARCHAR(200) DEFAULT NULL COMMENT 'Dify对话ID',
    `message_id` VARCHAR(200) DEFAULT NULL COMMENT 'Dify消息ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    CONSTRAINT `chat_messages_session_id_fkey` FOREIGN KEY (`session_id`) REFERENCES `assistant_sessions` (`id`) ON DELETE CASCADE,
    INDEX `idx_chat_messages_session` (`session_id`),
    INDEX `idx_chat_messages_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='聊天消息表';
```

### 10.6 数据工厂记录表 (data_factory_record)

`data_factory_record` 表存储测试数据工厂的使用记录。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 记录ID |
| user_id | BIGINT | 否 | 是 | 用户ID |
| tool_name | VARCHAR(100) | 否 | 是 | 工具名称 |
| tool_category | ENUM | 否 | 是 | 工具分类 |
| tool_scenario | ENUM | 否 | 是 | 使用场景 |
| input_data | JSON | 否 | 否 | 输入数据 |
| output_data | JSON | 否 | 是 | 输出数据 |
| is_saved | BOOLEAN | 否 | 是 | 是否保存 |
| tags | JSON | 否 | 否 | 标签 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**工具分类枚举**：
- `test_data` - 测试数据
- `json` - JSON工具
- `string` - 字符工具
- `encoding` - 编码工具
- `random` - 随机工具
- `encryption` - 加密工具
- `crontab` - Crontab工具

**建表语句**：

```sql
CREATE TABLE `data_factory_record` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '记录ID',
    `user_id` INT NOT NULL COMMENT '用户ID',
    `tool_name` VARCHAR(100) NOT NULL COMMENT '工具名称',
    `tool_category` VARCHAR(20) NOT NULL COMMENT '工具分类',
    `tool_scenario` VARCHAR(20) NOT NULL COMMENT '使用场景',
    `input_data` JSON DEFAULT NULL COMMENT '输入数据',
    `output_data` JSON NOT NULL COMMENT '输出数据',
    `is_saved` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否保存',
    `tags` JSON DEFAULT NULL COMMENT '标签',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `data_factory_record_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE,
    INDEX `idx_data_factory_record_user_created` (`user_id`, `created_at`),
    INDEX `idx_data_factory_record_category` (`tool_category`),
    INDEX `idx_data_factory_record_scenario` (`tool_scenario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据工厂记录表';
```

### 10.7 统一通知配置表 (unified_notification_configs)

`unified_notification_configs` 表存储统一通知配置信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 配置ID |
| name | VARCHAR(100) | 否 | 是 | 配置名称 |
| config_type | ENUM | 否 | 是 | 配置类型 |
| webhook_bots | JSON | 否 | 否 | Webhook机器人配置 |
| is_default | BOOLEAN | 否 | 是 | 是否默认配置 |
| is_active | BOOLEAN | 否 | 是 | 是否启用 |
| created_by_id | BIGINT | 否 | 是 | 创建者ID |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**配置类型枚举**：
- `webhook_feishu` - 飞书机器人
- `webhook_wechat` - 企业微信机器人
- `webhook_dingtalk` - 钉钉机器人

**建表语句**：

```sql
CREATE TABLE `unified_notification_configs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    `name` VARCHAR(100) NOT NULL COMMENT '配置名称',
    `config_type` VARCHAR(20) NOT NULL DEFAULT 'webhook_feishu' COMMENT '配置类型',
    `webhook_bots` JSON DEFAULT NULL COMMENT 'Webhook机器人配置',
    `is_default` BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否默认配置',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用',
    `created_by_id` INT NOT NULL COMMENT '创建者ID',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
    CONSTRAINT `unified_notification_configs_created_by_id_fkey` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`),
    INDEX `idx_unified_notification_configs_type` (`config_type`),
    INDEX `idx_unified_notification_configs_default` (`is_default`),
    INDEX `idx_unified_notification_configs_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='统一通知配置表';
```

### 10.8 Dify配置表 (dify_configs)

`dify_configs` 表存储 Dify AI 助手配置信息。

| 字段名 | 数据类型 | 是否主键 | 是否必填 | 描述 |
|--------|----------|----------|----------|------|
| id | BIGINT | 是 | 是 | 配置ID |
| api_url | VARCHAR(500) | 否 | 是 | API URL |
| api_key | VARCHAR(500) | 否 | 是 | API Key |
| is_active | BOOLEAN | 否 | 是 | 是否启用 |
| created_at | DATETIME | 否 | 是 | 创建时间 |
| updated_at | DATETIME | 否 | 是 | 更新时间 |

**建表语句**：

```sql
CREATE TABLE `dify_configs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    `api_url` VARCHAR(500) NOT NULL COMMENT 'API URL',
    `api_key` VARCHAR(500) NOT NULL COMMENT 'API Key',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用',
    `created_at` DATETIME(6) NOT NULL COMMENT '创建时间',
    `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Dify配置表';
```

---

## 11. 附录

### 11.1 表关系总览

```
users_user (用户表)
    │
    ├── user_profiles (用户配置)
    ├── projects (项目) ←── project_members (项目成员)
    │       ├── testcases (测试用例) ←── testcase_steps (用例步骤)
    │       │                        ←── testcase_attachments (用例附件)
    │       │                        ←── testcase_comments (用例评论)
    │       ├── testsuites (测试套件)
    │       ├── versions (版本)
    │       ├── test_plans (测试计划)
    │       │       └── test_runs (测试执行)
    │       │               └── test_run_cases (执行用例)
    │       │                       └── test_run_case_history (执行历史)
    │       ├── test_reports (测试报告)
    │       ├── testcase_reviews (评审)
    │       │       ├── review_templates (评审模板)
    │       │       ├── review_assignments (评审分配)
    │       │       └── review_comments (评审评论)
    │       ├── requirement_documents (需求文档)
    │       │       └── requirement_analyses (需求分析)
    │       │               └── business_requirements (业务需求)
    │       │                       └── generated_test_cases (AI生成用例)
    │       │
    │       ├── api_projects (API项目)
    │       │       ├── api_collections (API集合)
    │       │       │       └── api_requests (API请求)
    │       │       │               └── api_request_histories (请求历史)
    │       │       ├── api_environments (环境配置)
    │       │       ├── api_test_suites (API测试套件)
    │       │       └── api_scheduled_tasks (定时任务)
    │       │
    │       ├── ui_projects (UI项目)
    │       │       ├── ui_element_groups (元素分组)
    │       │       ├── ui_elements (UI元素)
    │       │       ├── ui_test_scripts (测试脚本)
    │       │       │       └── ui_script_steps (脚本步骤)
    │       │       ├── ui_test_suites (UI测试套件)
    │       │       ├── ui_test_executions (UI测试执行)
    │       │       └── ui_scheduled_tasks (UI定时任务)
    │       │
    │       └── app_projects (APP项目)
    │               ├── app_devices (设备)
    │               ├── app_elements (APP元素)
    │               ├── app_test_cases (APP测试用例)
    │               ├── app_test_suites (APP测试套件)
    │               ├── app_test_executions (APP测试执行)
    │               └── app_scheduled_tasks (APP定时任务)
    │
    ├── assistant_sessions (AI助手会话)
    │       └── chat_messages (聊天消息)
    │
    ├── dify_configs (Dify配置)
    │
    └── data_factory_record (数据工厂记录)
```

### 11.2 索引设计规范

| 索引类型 | 命名规范 | 示例 |
|---------|---------|------|
| 主键索引 | PK | `PRIMARY KEY (id)` |
| 唯一索引 | uk_ | `UNIQUE KEY uk_analysis_req_id (...)` |
| 普通索引 | idx_ | `INDEX idx_testcases_project (project_id)` |
| 复合索引 | idx_ | `INDEX idx_user_created (user_id, created_at)` |

### 11.3 外键约束规范

| 约束类型 | 说明 |
|---------|------|
| ON DELETE CASCADE | 父表删除时级联删除子表记录 |
| ON DELETE SET NULL | 父表删除时将子表外键设为NULL |
| ON DELETE RESTRICT | 阻止删除有依赖的记录 |

### 11.4 字段命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 主键 | `id` | `BIGINT AUTO_INCREMENT PRIMARY KEY` |
| 外键 | `xxx_id` | `project_id`, `user_id` |
| 时间戳 | `xxx_at` | `created_at`, `updated_at` |
| 布尔值 | `is_xxx` | `is_active`, `is_default` |
| 计数 | `xxx_count` | `total_count`, `passed_count` |
| JSON字段 | 无特殊后缀 | `variables`, `config` |

### 11.5 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
