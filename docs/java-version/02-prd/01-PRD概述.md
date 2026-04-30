# TestHub Java 版本产品需求文档 (PRD)

## 文档信息

| 属性 | 内容 |
|------|------|
| 产品名称 | TestHub 智能测试管理平台 |
| 版本 | Java 版 v1.0 |
| 文档状态 | 进行中 |
| 创建日期 | 2026-04-12 |
| 最后更新 | 2026-04-12 |

---

## 一、产品概述

### 1.1 背景与目标

TestHub 是一款 AI 驱动的测试管理平台，Python 版本已稳定运行。现计划使用 Java (Spring Boot) 重写后端，以获得更好的性能、企业级支持和技术生态。

**核心目标：**
- 保持与 Python 版本功能完全一致
- 提升系统性能和并发处理能力
- 提供更好的企业级特性（微服务支持、更好的可维护性）
- 前端保持 Vue 3 不变，实现前后端解耦

### 1.2 产品定位

面向 QA 团队和测试工程师的一站式测试管理平台，支持：
- 手工测试用例管理
- API 接口测试
- UI 自动化测试
- APP 自动化测试
- AI 驱动的需求分析和测试用例生成

### 1.3 技术架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           前端 (Vue 3)                                 │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  Element Plus │ Pinia │ Vue Router │ Axios │ ECharts           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────┤
│                           REST API (Java Spring Boot)                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  Spring Boot 3.2 │ MyBatis-Plus │ Spring Security │ JWT         │   │
│  └─────────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────┤
│                           数据层                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │   MySQL 8    │  │   Redis 7   │  │  XXL-JOB     │  │ MinIO/S3  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 二、功能模块总览

### 2.1 模块列表

| #    | 模块名称                           | 文档数据 | Java 实际业务表 | 差异 | 明细                                                         |
| :--- | :--------------------------------- | :------- | :-------------- | :--- | :----------------------------------------------------------- |
| 1 | 用户认证 (users) | 2 | 2 | ✅ | users_user, user_profiles |
| 2    | 项目管理 (projects)                | 3        | 3               | ✅    | projects, project_members, project_environments              |
| 3    | 手工测试用例 (testcases)           | 4        | 4               | ✅    | testcases, testcase_steps, testcase_attachments, testcase_comments |
| 4    | 测试套件 (testsuites)              | 2        | 2               | ✅    | testsuites, testsuite_cases                                  |
| 5    | 测试计划执行 (executions)          | 5        | 4               | ✅    | test_plans, test_runs, test_run_cases, test_run_case_history |
| 6    | API 测试 (api-testing)             | 17       | 17              | ✅    | api_projects, api_collections, api_requests, api_environments, api_request_histories, api_test_suites, api_test_suite_requests, api_test_executions, api_scheduled_tasks, api_task_execution_logs, api_notification_logs, api_task_notification_settings, api_task_notification_settings_custom_recipients, api_operation_logs, api_projects_members, api_ai_service_configs |
| 7    | UI 自动化 (ui-automation)          | 24       | 24              | ✅    | ui_projects, ui_projects_members, locator_strategies, ui_element_groups, ui_elements, ui_test_scripts, ui_script_steps, ui_script_element_usages, ui_page_objects, ui_page_object_elements, ui_test_suites, ui_test_suite_scripts, ui_test_suite_test_cases, ui_test_executions, ui_test_environments, ui_screenshots, ui_test_cases, ui_test_case_steps, ui_test_case_executions, ui_operation_record, ui_scheduled_tasks, ui_notification_logs, ui_task_notification_settings, ui_task_notification_settings_custom_recipients, ui_ai_cases, ui_ai_execution_records |
| 8    | APP 自动化 (app-automation)        | 14       | 14              | ✅    | app_projects, app_projects_members, app_test_config, app_devices, app_elements, app_components, app_custom_components, app_component_packages, app_packages, app_test_suites, app_test_suite_cases, app_test_cases, app_test_executions, app_scheduled_tasks, app_notification_logs |
| 9    | AI 需求分析 (requirement-analysis) | 9        | 9               | ✅    | requirement_documents, requirement_analyses, business_requirements, generated_test_cases, analysis_tasks, ai_model_config, prompt_config, generation_config, testcase_generation_task |
| 10   | 测试用例评审 (reviews)             | 4        | 4               | ✅    | testcase_reviews, review_assignments, review_comments, review_templates |
| 11   | 统一通知 (core)                    | 1        | 1               | ✅    | unified_notification_configs                                 |
| 12   | AI 助手 (assistant)                | 4        | 4               | ✅    | dify_configs, assistant_sessions, chat_messages              |
| 13   | 测试报告 (reports)                 | 2        | 2               | ✅    | test_reports, report_templates                               |
| 14   | 版本管理 (versions)                | 1        | 1               | ✅    | versions                                                     |
| 15   | 测试数据工厂 (data-factory)        | 1        | 1               | ✅    | data_factory_record                                          |
| 合计 | 15 个模块                          | 92       | 88              |      |                                                              |

---

## 三、用户角色与权限

### 3.1 用户角色

| 角色 | 描述 | 权限范围 |
|------|------|----------|
| **超级管理员** | 系统管理员 | 所有系统配置、用户管理 |
| **项目负责人 (Owner)** | 项目所有者 | 项目全部权限、人员管理 |
| **管理员 (Admin)** | 项目管理员 | 项目配置、测试管理 |
| **开发者 (Developer)** | 开发人员 | 用例编写、执行 |
| **测试者 (Tester)** | 测试人员 | 用例执行、查看 |
| **观察者 (Viewer)** | 只读用户 | 仅查看权限 |

### 3.2 项目级权限矩阵

| 功能 | Owner | Admin | Developer | Tester | Viewer |
|------|:-----:|:-----:|:---------:|:------:|:------:|
| 项目设置 | ✓ | ✓ | - | - | - |
| 成员管理 | ✓ | ✓ | - | - | - |
| 创建用例 | ✓ | ✓ | ✓ | ✓ | - |
| 编辑用例 | ✓ | ✓ | ✓ | ✓ | - |
| 删除用例 | ✓ | ✓ | - | - | - |
| 执行用例 | ✓ | ✓ | ✓ | ✓ | - |
| 查看报告 | ✓ | ✓ | ✓ | ✓ | ✓ |

---

## 四、功能需求详细说明

### 4.1 用户认证模块 (users)

#### 4.1.1 功能列表

| 功能点     | 优先级 | 描述                                            |
| :--------- | :----: | :---------------------------------------------- |
| 用户注册   |   P0   | 用户名/邮箱注册，支持密码确认                   |
| 用户登录   |   P0   | 用户名密码登录，返回 JWT Access + Refresh Token |
| Token 刷新 |   P0   | Refresh Token 换取新 Access Token               |
| 退出登录   |   P0   | 清除 Session，Refresh Token 加入黑名单          |
| 个人信息   |   P0   | 查看/编辑个人资料（用户名、邮箱、部门、职位等） |
| 用户列表   |   P0   | 分页查看所有用户（需认证）                      |
| 用户详情   |   P0   | 查看指定用户信息                                |
| 更新用户   |   P1   | 更新指定用户信息                                |
| 头像上传   |   P1   | 上传/更新用户头像                               |
| 密码修改   |   P1   | 修改登录密码（需验证原密码）                    |
| 密码重置   |   P2   | 邮箱验证码重置密码（预留）                      |
| 主题配置   |   P2   | 浅色/深色主题切换                               |
| 语言设置   |   P2   | 中英文切换                                      |
| 时区设置   |   P2   | 时区配置，默认 Asia/Shanghai                    |

#### 4.1.2 数据模型

User (用户表)

| 字段名       | 类型         | 约束               | 说明                         |
| :----------- | :----------- | :----------------- | :--------------------------- |
| id           | BIGINT       | PK, AUTO_INCREMENT | 用户ID                       |
| username     | VARCHAR(150) | UNIQUE, NOT NULL   | 用户名                       |
| password     | VARCHAR(128) | NOT NULL           | 加密密码                     |
| email        | VARCHAR(254) | UNIQUE             | 邮箱                         |
| first_name   | VARCHAR(150) | -                  | 名                           |
| last_name    | VARCHAR(150) | -                  | 姓                           |
| phone        | VARCHAR(11)  | -                  | 手机号                       |
| avatar       | VARCHAR(100) | -                  | 头像URL（存储路径）          |
| department   | VARCHAR(100) | -                  | 部门                         |
| position     | VARCHAR(100) | -                  | 职位                         |
| is_superuser | BOOLEAN      | DEFAULT FALSE      | 超级管理员标识               |
| is_staff     | BOOLEAN      | DEFAULT FALSE      | 后台管理权限                 |
| is_active    | BOOLEAN      | DEFAULT TRUE       | 是否激活                     |
| last_login   | DATETIME     | -                  | 最后登录时间                 |
| date_joined  | DATETIME     | NOT NULL           | 注册时间（AbstractUser继承） |
| created_at   | DATETIME     | NOT NULL           | 创建时间                     |
| updated_at   | DATETIME     | NOT NULL           | 更新时间                     |

> 注：`date_joined` 继承自 Django AbstractUser，`created_at` / `updated_at` 为自定义时间戳字段。

UserProfile (用户配置表)

| 字段名        | 类型        | 约束                    | 说明                 |
| :------------ | :---------- | :---------------------- | :------------------- |
| id            | BIGINT      | PK, AUTO_INCREMENT      | 主键                 |
| user_id       | BIGINT      | FK, UNIQUE              | 关联用户ID（一对一） |
| theme         | VARCHAR(20) | DEFAULT 'light'         | 主题（light/dark）   |
| language      | VARCHAR(10) | DEFAULT 'zh-cn'         | 语言                 |
| timezone      | VARCHAR(50) | DEFAULT 'Asia/Shanghai' | 时区                 |
| notifications | JSON        | -                       | 通知设置             |

#### 4.1.3 API 接口

| 方法      | 端点                     | 说明                                  |
| :-------- | :----------------------- | :------------------------------------ |
| POST      | /api/auth/register/      | 用户注册                              |
| POST      | /api/auth/login/         | 用户登录，返回 access + refresh Token |
| POST      | /api/auth/logout/        | 退出登录，Refresh Token 加入黑名单    |
| POST      | /api/auth/token/refresh/ | 刷新 Access Token                     |
| GET       | /api/users/me/           | 获取当前登录用户信息                  |
| GET       | /api/users/users/        | 用户列表（分页）                      |
| GET       | /api/users/users/{id}/   | 用户详情                              |
| PUT/PATCH | /api/users/users/{id}/   | 更新用户信息                          |
| GET       | /api/auth/profile/       | 获取当前用户资料（与 /me 等效）       |

#### 4.1.4 用户流程

```
┌─────────────────────────────────────────────────────────────────────────┐

│                           用户认证流程                                    │

└─────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐

​    │   打开登录页  │

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐     ┌─────────────┐

​    │  已登录?     │────►│  Token有效?  │────►┌─────────────┐

​    └─────────────┘     └──────┬──────┘     │   进入首页   │

​           │                   │            └─────────────┘

​           │ 否                │ 否

​           ▼                   ▼

​    ┌─────────────┐     ┌─────────────┐

​    │   登录表单   │     │  调用刷新API │

​    └──────┬──────┘     └──────┬──────┘

​           │                   │

​           ▼                   ▼

​    ┌─────────────┐     ┌─────────────┐

​    │  输入用户名  │     │  刷新成功?   │

​    │  密码登录   │     └──────┬──────┘

​    └──────┬──────┘           │ 是

​           │                  ▼

​           ▼            ┌─────────────┐

​    ┌─────────────┐     │   进入首页   │

​    │  调用登录API │     └─────────────┘

​    └──────┬──────┘           │

​           │                  │ 否

​           ▼                  ▼

​    ┌─────────────┐     ┌─────────────┐

​    │  登录成功?   │────►│   重新登录  │

​    └──────┬──────┘     └─────────────┘

​           │ 是

​           ▼

​    ┌─────────────┐

​    │ 存储双Token │

​    │ Access+Refresh │

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐

​    │   进入首页   │

​    └─────────────┘
```

#### 4.1.5 注册与登录响应格式

登录响应

```
{

  "user": {

​    "id": 1,

​    "username": "admin",

​    "email": "admin@example.com",

​    "first_name": "",

​    "last_name": "",

​    "avatar": "/media/avatars/default.png",

​    "phone": "13800138000",

​    "department": "测试部",

​    "position": "测试工程师",

​    "is_active": true,

​    "date_joined": "2024-01-01T00:00:00Z",

​    "created_at": "2024-01-01T00:00:00Z",

​    "updated_at": "2024-01-01T00:00:00Z"

  },

  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",

  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",

  "message": "登录成功"

}
```

注册请求/响应

```
*// POST /api/auth/register/*

*// Request*

{

  "username": "testuser",

  "email": "test@example.com",

  "password": "123456",

  "password_confirm": "123456",

  "first_name": "张",

  "last_name": "三",

  "phone": "13800138000",

  "department": "研发部",

  "position": "开发工程师"

}

*// Response 201*

{

  "user": { ... },

  "token": "drf-auth-token-key..."

}
```

### 4.2 项目管理模块 (projects)

#### 4.2.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 项目列表 | P0 | 分页查看项目，支持搜索 |
| 创建项目 | P0 | 创建新项目，设置基本信息 |
| 项目详情 | P0 | 查看项目详情和成员 |
| 编辑项目 | P0 | 修改项目信息 |
| 删除项目 | P0 | 删除项目（级联删除） |
| 项目成员 | P0 | 添加/移除成员，设置角色 |
| 角色权限 | P0 | Owner/Admin/Developer/Tester/Viewer |
| 环境配置 | P0 | 项目环境变量管理 |
| 项目状态 | P0 | 进行中/暂停/已完成/已归档 |

#### 4.2.2 数据模型

**Project (项目表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 项目ID |
| name | VARCHAR(200) | NOT NULL | 项目名称 |
| description | TEXT | - | 项目描述 |
| status | VARCHAR(20) | NOT NULL | 状态 |
| owner_id | BIGINT | FK | 负责人ID |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**ProjectMember (项目成员表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 主键 |
| project_id | BIGINT | FK | 项目ID |
| user_id | BIGINT | FK | 用户ID |
| role | ENUM | DEFAULT 'tester' | 角色 |
| joined_at | DATETIME | NOT NULL | 加入时间 |

**ProjectEnvironment (项目环境表)**

| 字段名      | 类型         | 约束          | 说明                       |
| :---------- | :----------- | :------------ | :------------------------- |
| id          | BIGINT       | PK            | 主键                       |
| project_id  | BIGINT       | FK            | 项目ID                     |
| name        | VARCHAR(100) | NOT NULL      | 环境名称                   |
| base_url    | VARCHAR(200) | NOT NULL      | 基础URL（Django URLField） |
| description | TEXT         | -             | 环境描述                   |
| variables   | JSON         | -             | 环境变量                   |
| is_default  | BOOLEAN      | DEFAULT FALSE | 是否默认                   |

#### 4.2.3 API 接口

| 方法      | 端点                                   | 说明                     |
| :-------- | :------------------------------------- | :----------------------- |
| GET       | /api/projects                          | 项目列表（分页、搜索）   |
| POST      | /api/projects                          | 创建项目                 |
| GET       | /api/projects/all                      | 所有项目（用于下拉选择） |
| GET       | /api/projects/list                     | 当前用户参与的项目列表   |
| GET       | /api/projects/{id}                     | 项目详情                 |
| PUT/PATCH | /api/projects/{id}                     | 更新项目                 |
| DELETE    | /api/projects/{id}                     | 删除项目                 |
| GET       | /api/projects/{id}/members             | 成员列表（包含 Owner）   |
| POST      | /api/projects/{id}/members/add/        | 添加成员                 |
| DELETE    | /api/projects/{id}/members/{memberId}/ | 移除成员                 |
| GET       | /api/projects/{id}/environments        | 环境列表                 |
| POST      | /api/projects/{id}/environments        | 创建环境                 |

---

### 4.3 手工测试用例模块 (testcases)

#### 4.3.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 用例列表 | P0 | 分页查看，支持搜索/筛选/排序 |
| 创建用例 | P0 | 创建测试用例，设置步骤 |
| 用例详情 | P0 | 查看用例完整信息 |
| 编辑用例 | P0 | 修改用例内容 |
| 删除用例 | P0 | 删除用例（级联） |
| 步骤管理 | P0 | 添加/编辑/删除/排序步骤 |
| 附件上传 | P1 | 上传截图、文档等 |
| 附件下载 | P1 | 下载用例附件 |
| 评论功能 | P1 | 用例评论讨论 |
| 标签管理 | P1 | 用例标签管理 |
| 批量操作 | P2 | 批量删除、批量更新状态 |
| 导入导出 | P2 | Excel 导入导出 |

#### 4.3.2 数据模型

**TestCase (测试用例表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 用例ID |
| project_id | BIGINT | FK | 项目ID |
| title | VARCHAR(500) | NOT NULL | 用例标题 |
| description | TEXT | - | 用例描述 |
| preconditions | TEXT | - | 前置条件 |
| steps | TEXT | - | 操作步骤（旧字段） |
| expected_result | TEXT | NOT NULL | 预期结果 |
| priority | ENUM | DEFAULT 'medium' | 优先级 |
| status | ENUM | DEFAULT 'draft' | 状态 |
| test_type | ENUM | DEFAULT 'functional' | 测试类型 |
| tags | JSON | - | 标签列表 |
| author_id | BIGINT | FK | 作者ID |
| assignee_id | BIGINT | FK | 指派人ID |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |
| versions | BIGINT[] | FK (ManyToMany) | 关联版本列表 |

**TestCaseStep (用例步骤表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 主键 |
| testcase_id | BIGINT | FK | 用例ID |
| step_number | INT | NOT NULL | 步骤序号 |
| action | TEXT | NOT NULL | 操作描述 |
| expected | TEXT | NOT NULL | 预期结果 |

**TestCaseAttachment (用例附件表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 主键 |
| testcase_id | BIGINT | FK | 用例ID |
| name | VARCHAR(255) | NOT NULL | 附件名称 |
| file | VARCHAR(100) | NOT NULL | 文件路径 |
| uploaded_by_id | BIGINT | FK | 上传人ID |
| uploaded_at | DATETIME | NOT NULL | 上传时间 |

**TestCaseComment (用例评论表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 主键 |
| testcase_id | BIGINT | FK | 用例ID |
| author_id | BIGINT | FK | 评论人ID |
| content | TEXT | NOT NULL | 评论内容 |
| created_at | DATETIME | NOT NULL | 评论时间 |

#### 4.3.3 枚举值

**优先级 (priority)**
- `low` - 低
- `medium` - 中
- `high` - 高
- `critical` - 紧急

**状态 (status)**
- `draft` - 草稿
- `active` - 激活
- `deprecated` - 废弃

**测试类型 (test_type)**
- `functional` - 功能测试
- `integration` - 集成测试
- `api` - API测试
- `ui` - UI测试
- `performance` - 性能测试
- `security` - 安全测试

#### 4.3.4 API 接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | /api/testcases | 用例列表 |
| POST | /api/testcases | 创建用例 |
| GET | /api/testcases/{id} | 用例详情 |
| PUT | /api/testcases/{id} | 更新用例 |
| DELETE | /api/testcases/{id} | 删除用例 |
| GET | /api/testcases/{id}/steps | 用例步骤 |
| POST | /api/testcases/{id}/steps | 添加步骤 |
| PUT | /api/testcases/{id}/steps/{stepId} | 更新步骤 |
| DELETE | /api/testcases/{id}/steps/{stepId} | 删除步骤 |
| POST | /api/testcases/{id}/attachments | 上传附件 |
| GET | /api/testcases/{id}/attachments | 附件列表 |
| DELETE | /api/testcases/{id}/attachments/{attId} | 删除附件 |
| GET | /api/testcases/{id}/comments | 评论列表 |
| POST | /api/testcases/{id}/comments | 添加评论 |
| DELETE | /api/testcases/{id}/comments/{commentId} | 删除评论 |

#### 4.3.5 用户流程

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        测试用例管理流程                                   │
└─────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │  进入用例列表 │
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │  筛选/搜索   │◄────────────────┐
    └──────┬──────┘                 │
           │                        │
           ▼                        │
    ┌─────────────┐                 │
    │  查看用例列表 │                │
    └──────┬──────┘                 │
           │                        │
           ▼                        │
    ┌─────────────┐     ┌───────────┴─────────┐
    │  点击用例    │────►│       操作选择       │
    └─────────────┘     └───────────┬─────────┘
                                     │
           ┌─────────────┬────────────┼────────────┐
           │            │            │            │
           ▼            ▼            ▼            ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │   查看详情   │ │   编辑用例   │ │   删除用例   │ │   执行用例   │
    └──────┬──────┘ └──────┬──────┘ └─────────────┘ └─────────────┘
           │            │
           │            ▼
           │     ┌─────────────┐
           │     │  修改表单   │
           │     └──────┬──────┘
           │            │
           │            ▼
           │     ┌─────────────┐
           │     │  保存用例   │
           │     └──────┬──────┘
           │            │
           │            ▼
           │     ┌─────────────┐
           └────►│  返回列表   │
                 └─────────────┘
```

---

### 4.4 测试计划执行模块 (executions)

#### 4.4.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 测试计划 | P0 | 创建/编辑/删除测试计划 |
| 用例执行 | P0 | 执行测试计划中的用例 |
| 执行结果 | P0 | 记录通过/失败/阻塞状态 |
| 批量执行 | P1 | 批量执行多个用例 |
| 执行历史 | P0 | 查看历史执行记录 |
| 统计报表 | P1 | 执行结果统计 |
| 缺陷关联 | P2 | 关联缺陷编号 |

#### 4.4.2 数据模型

**TestPlan (测试计划表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 计划ID |
| name | VARCHAR(200) | NOT NULL | 计划名称 |
| description | TEXT | - | 计划描述 |
| version_id | BIGINT | FK, NULL | 关联版本ID |
| creator_id | BIGINT | FK | 创建人ID |
| is_active | BOOLEAN | DEFAULT TRUE | 是否激活 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

> 注：projects 和 assignees 通过中间表关联 (`test_plans_projects`, `test_plans_assignees`)

**TestRun (测试执行表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 执行ID |
| name | VARCHAR(200) | NOT NULL | 执行名称 |
| description | TEXT | - | 执行描述 |
| test_plan_id | BIGINT | FK | 测试计划ID |
| project_id | BIGINT | FK | 项目ID |
| version_id | BIGINT | FK | 版本ID |
| assignee_id | BIGINT | FK | 执行人ID |
| creator_id | BIGINT | FK | 创建者ID |
| status       | VARCHAR(20)  | DEFAULT 'untested' | 状态：`untested` / `in_progress` / `completed` / `blocked` |
| started_at | DATETIME | - | 开始时间 |
| completed_at | DATETIME | - | 完成时间 |
| due_date | DATETIME | - | 截止日期 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**TestRunCase (执行用例关联表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 主键 |
| test_run_id | BIGINT | FK | 执行ID |
| testcase_id | BIGINT | FK | 用例ID |
| status | ENUM | DEFAULT 'untested' | 执行状态 |
| priority | ENUM | DEFAULT 'medium' | 优先级 |
| actual_result | TEXT | - | 实际结果 |
| comments | TEXT | - | 备注 |
| defects | JSON | - | 关联缺陷 |
| elapsed_time | bigint | NULL | 执行耗时 |
| executed_by_id | BIGINT | FK | 执行者ID |
| executed_at | DATETIME | - | 执行时间 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**TestRunCaseHistory (执行历史表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 历史ID |
| run_case_id | BIGINT | FK | 执行用例ID |
| status | ENUM | NOT NULL | 执行状态 |
| actual_result | TEXT | - | 实际结果 |
| comments | TEXT | - | 备注 |
| executed_by_id | BIGINT | FK | 执行者ID |
| executed_at | DATETIME | NOT NULL | 执行时间 |

#### 4.4.3 执行状态

TestRun.status（执行整体状态）

| 值          | 说明   |
| :---------- | :----- |
| untested    | 未测试 |
| in_progress | 进行中 |
| completed   | 已完成 |
| blocked     | 阻塞   |

TestRunCase.status（单个用例执行结果）

| 值       | 说明   |
| :------- | :----- |
| untested | 未测试 |
| passed   | 通过   |
| failed   | 失败   |
| blocked  | 阻塞   |
| retest   | 重测   |

#### 4.4.4  API 接口

| 方法                                                         | 端点                                                         | 说明                                       |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------- |
| GET                                                          | /api/executions/plans                                        | 测试计划列表                               |
| POST                                                         | /api/executions/plans                                        | 创建测试计划（自动按项目创建 TestRun）     |
| GET                                                          | /api/executions/plans/{id}                                   | 测试计划详情（含关联项目、用例）           |
| PUT/PATCH                                                    | /api/executions/plans/{id}                                   | 更新测试计划                               |
| DELETE                                                       | /api/executions/plans/{id}                                   | 删除测试计划                               |
| GET                                                          | /api/executions/plans/testcases_by_projects?project_ids=1&project_ids=2 | 根据项目获取可选测试用例                   |
| GET                                                          | /api/executions/runs                                         | 测试执行列表                               |
| POST                                                         | /api/executions/runs                                         | 创建测试执行                               |
| GET                                                          | /api/executions/runs/{id}                                    | 测试执行详情（含 progress_stats 进度统计） |
| PUT/PATCH                                                    | /api/executions/runs/{id}                                    | 更新测试执行                               |
| DELETE                                                       | /api/executions/runs/{id}                                    | 删除测试执行                               |
| GET                                                          | /api/executions/run_cases                                    | 执行用例列表                               |
| POST                                                         | /api/executions/run_cases                                    | 添加执行用例                               |
| GET                                                          | /api/executions/run_cases/{id}                               | 执行用例详情                               |
| PUT/PATCH                                                    | /api/executions/run_cases/{id}                               | 更新执行用例                               |
| DELETE                                                       | /api/executions/run_cases/{id}                               | 删除执行用例                               |
| PATCH                                                        | /api/executions/run_cases/{id}/update_status                 | 更新执行状态（自动创建历史记录）           |
| GET                                                          | /api/executions/run_cases/{id}/history                       | 用例执行历史                               |
| GET                                                          | /api/executions/history                                      | 执行历史记录（只读）                       |
| The user just received my analysis. Let me wait for their next instruction. |                                                              |                                            |

### 4.5 手工测试套件模块 (testsuites)

#### 4.5.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 套件管理 | P0 | 创建/编辑/删除测试套件 |
| 用例编排 | P0 | 将手工用例添加到套件 |
| 套件详情 | P0 | 查看套件详情和包含的用例 |

#### 4.5.2 数据模型

**TestSuite (测试套件)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 套件ID |
| project_id | BIGINT | FK | 项目ID |
| name | VARCHAR(200) | NOT NULL | 套件名称 |
| description | TEXT | - | 套件描述 |
| author_id | BIGINT | FK | 创建者 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**TestSuiteCase (套件用例关联)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 主键 |
| testsuite_id | BIGINT | FK | 测试套件ID |
| testcase_id | BIGINT | FK | 测试用例ID |
| order | INT | DEFAULT 0 | 执行顺序 |

#### 4.5.3 API 接口

| 方法      | 端点                                | 说明                   | 代码状态 |
| :-------- | :---------------------------------- | :--------------------- | :------: |
| GET       | /api/testsuites                     | 套件列表               | ❌ 待实现 |
| POST      | /api/testsuites                     | 创建套件               | ❌ 待实现 |
| GET       | /api/testsuites/{id}                | 套件详情（含关联用例） | ❌ 待实现 |
| PUT/PATCH | /api/testsuites/{id}                | 更新套件               | ❌ 待实现 |
| DELETE    | /api/testsuites/{id}                | 删除套件               | ❌ 待实现 |
| GET       | /api/testsuites/{id}/cases          | 套件用例列表           | ❌ 待实现 |
| POST      | /api/testsuites/{id}/cases          | 添加用例到套件         | ❌ 待实现 |
| DELETE    | /api/testsuites/{id}/cases/{caseId} | 从套件移除用例         | ❌ 待实现 |

---

### 4.6 API 测试模块 (api-testing)

#### 4.6.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 项目管理 | P0 | API 项目 CRUD |
| 集合管理 | P0 | 树形目录结构 |
| 请求管理 | P0 | HTTP/WebSocket 请求 |
| 环境变量 | P0 | 全局/局部环境变量 |
| 请求执行 | P0 | 发送请求，记录响应 |
| 请求历史 | P0 | 历史记录查看 |
| 断言规则 | P0 | 响应断言验证 |
| 前后置脚本 | P1 | 请求前后执行脚本 |
| 测试套件 | P0 | 用例编排 |
| 定时任务 | P0 | CRON 定时执行 |
| 测试报告 | P0 | Allure 报告生成 |
| 通知推送 | P1 | 邮件/飞书/企微/钉钉 |
| AI 辅助 | P2 | AI 参数命名、描述补全 |

#### 4.6.2 数据模型

**ApiProject (API 项目)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 项目ID |
| name | VARCHAR(200) | NOT NULL | 项目名称 |
| description | TEXT | - | 项目描述 |
| project_type | ENUM | NOT NULL | 类型 (HTTP/WebSocket) |
| status | ENUM | DEFAULT 'IN_PROGRESS' | 状态 |
| start_date | DATE | - | 开始日期 |
| end_date | DATE | - | 结束日期 |
| owner_id | BIGINT | FK | 负责人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**ApiCollection (API 集合)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 集合ID |
| name | VARCHAR(200) | NOT NULL | 集合名称 |
| project_id | BIGINT | FK | 项目ID |
| parent_id | BIGINT | FK (self) | 父集合 |
| order_index | INT | DEFAULT 0 | 排序 |

**ApiRequest (API 请求)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 请求ID |
| name | VARCHAR(200) | NOT NULL | 请求名称 |
| description | TEXT | - | 请求描述 |
| collection_id | BIGINT | FK | 集合ID |
| request_type | ENUM | DEFAULT 'HTTP' | 请求类型 (HTTP/WebSocket) |
| method | ENUM | NOT NULL | HTTP方法 |
| url | TEXT | NOT NULL | 请求URL |
| headers | JSON | - | 请求头 |
| params | JSON | - | URL参数 |
| body | JSON | - | 请求体 |
| auth | JSON | - | 认证信息 |
| pre_request_script | TEXT | - | 前置脚本 |
| post_request_script | TEXT | - | 后置脚本 |
| assertions | JSON | - | 断言规则 |
| order | INT | DEFAULT 0 | 排序 |
| created_by_id | BIGINT | FK | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**ApiEnvironment (环境配置)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 环境ID |
| name | VARCHAR(200) | NOT NULL | 环境名称 |
| scope | ENUM | NOT NULL | 作用域 (GLOBAL/LOCAL) |
| variables | JSON | - | 环境变量 |
| is_active | BOOLEAN | DEFAULT FALSE | 是否激活 |
| project_id | BIGINT | FK | 关联项目（局部环境需要） |
| created_by_id | BIGINT | FK | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**ApiRequestHistory (请求历史)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 历史ID |
| request_id | BIGINT | FK | 请求ID |
| environment_id | BIGINT | FK | 使用环境 |
| request_data | JSON | - | 请求数据 |
| response_data | JSON | - | 响应数据 |
| status_code | INT | - | 状态码 |
| response_time | FLOAT | - | 响应时间(ms) |
| error_message | TEXT | - | 错误信息 |
| assertions_results | JSON | - | 断言结果 |
| executed_by_id | BIGINT | FK | 执行人 |
| executed_at | DATETIME | NOT NULL | 执行时间 |

**ApiTestSuite (测试套件)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 套件ID |
| project_id | BIGINT | FK | 项目ID |
| name | VARCHAR(200) | NOT NULL | 套件名称 |
| description | TEXT | - | 套件描述 |
| environment_id | BIGINT | FK | 执行环境 |
| created_by_id | BIGINT | FK | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**TestSuiteRequest (套件请求关联)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 主键 |
| test_suite_id | BIGINT | FK | 测试套件ID |
| request_id | BIGINT | FK | API请求ID |
| order | INT | DEFAULT 0 | 执行顺序 |
| assertions | JSON | - | 断言规则 |
| enabled | BOOLEAN | DEFAULT TRUE | 是否启用 |

**ApiTestExecution (测试执行)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 执行ID |
| test_suite_id | BIGINT | FK | 测试套件ID |
| status | ENUM | DEFAULT 'PENDING' | 执行状态 |
| start_time | DATETIME | - | 开始时间 |
| end_time | DATETIME | - | 结束时间 |
| total_requests | INT | DEFAULT 0 | 总请求数 |
| passed_requests | INT | DEFAULT 0 | 通过请求数 |
| failed_requests | INT | DEFAULT 0 | 失败请求数 |
| results | JSON | - | 执行结果 |
| executed_by_id | BIGINT | FK | 执行人 |
| created_at | DATETIME | NOT NULL | 创建时间 |

**ApiScheduledTask (定时任务)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 任务ID |
| name | VARCHAR(200) | NOT NULL | 任务名称 |
| description | TEXT | - | 任务描述 |
| task_type | ENUM | NOT NULL | 任务类型 (TEST_SUITE/API_REQUEST) |
| trigger_type | ENUM | NOT NULL | 触发器类型 (CRON/INTERVAL/ONCE) |
| cron_expression | VARCHAR(100) | - | CRON表达式 |
| interval_seconds | INT | - | 间隔秒数 |
| execute_at | DATETIME | - | 单次执行时间 |
| test_suite_id | BIGINT | FK | 测试套件 |
| api_request_id | BIGINT | FK | API请求 |
| environment_id | BIGINT | FK | 执行环境 |
| status | ENUM | DEFAULT 'ACTIVE' | 任务状态 |
| last_run_time | DATETIME | - | 最后运行时间 |
| next_run_time | DATETIME | - | 下次运行时间 |
| total_runs | INT | DEFAULT 0 | 总运行次数 |
| successful_runs | INT | DEFAULT 0 | 成功运行次数 |
| failed_runs | INT | DEFAULT 0 | 失败运行次数 |
| last_result | JSON | - | 最后执行结果 |
| error_message | TEXT | - | 错误信息 |
| notify_on_success | BOOLEAN | DEFAULT FALSE | 成功时通知 |
| notify_on_failure | BOOLEAN | DEFAULT TRUE | 失败时通知 |
| notify_emails | JSON | - | 通知邮箱列表 |
| created_by_id | BIGINT | FK | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**TaskExecutionLog (任务执行日志)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 日志ID |
| task_id | BIGINT | FK | 定时任务ID |
| status | ENUM | DEFAULT 'PENDING' | 执行状态 |
| start_time | DATETIME | - | 开始时间 |
| end_time | DATETIME | - | 结束时间 |
| duration | FLOAT | - | 执行时长(秒) |
| result | JSON | - | 执行结果 |
| error_message | TEXT | - | 错误信息 |
| executed_by_id | BIGINT | FK | 执行人 |
| created_at | DATETIME | NOT NULL | 创建时间 |

**NotificationLog (通知日志)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 日志ID |
| task_id | BIGINT | FK | 关联任务 |
| task_name | VARCHAR(200) | - | 任务名称快照 |
| task_type | VARCHAR(20) | - | 任务类型快照 |
| notification_type | ENUM | NOT NULL | 通知类型 |
| sender_name | VARCHAR(100) | - | 发件人姓名 |
| sender_email | VARCHAR(254) | - | 发件人邮箱 |
| recipient_info | JSON | - | 收件人信息 |
| webhook_bot_info | JSON | - | Webhook机器人信息 |
| notification_content | TEXT | - | 通知内容 |
| status | ENUM | DEFAULT 'pending' | 发送状态 |
| error_message | TEXT | - | 错误信息 |
| response_info | JSON | - | 响应信息 |
| retry_count | INT | DEFAULT 0 | 重试次数 |
| is_retried | BOOLEAN | DEFAULT FALSE | 是否已重试 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| sent_at | DATETIME | - | 发送时间 |

**TaskNotificationSetting (任务通知设置)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 设置ID |
| task_id | BIGINT | FK, UNIQUE | 定时任务ID |
| notification_type | ENUM | DEFAULT 'both' | 通知类型 (email/webhook/both) |
| notification_config_id | BIGINT | FK | 通知配置 |
| is_enabled | BOOLEAN | DEFAULT FALSE | 是否启用通知 |
| notify_on_success | BOOLEAN | DEFAULT TRUE | 成功时通知 |
| notify_on_failure | BOOLEAN | DEFAULT TRUE | 失败时通知 |
| notify_on_timeout | BOOLEAN | DEFAULT FALSE | 超时时通知 |
| notify_on_error | BOOLEAN | DEFAULT TRUE | 错误时通知 |
| custom_webhook_bots | JSON | - | 自定义Webhook机器人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**OperationLog (操作日志)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 日志ID |
| operation_type | ENUM | NOT NULL | 操作类型 (create/edit/delete/execute/run/save) |
| resource_type | ENUM | NOT NULL | 资源类型 (project/collection/request/suite/environment/task/execution) |
| resource_id | BIGINT | NOT NULL | 资源ID |
| resource_name | VARCHAR(200) | - | 资源名称 |
| description | TEXT | - | 操作描述 |
| user_id | BIGINT | FK | 操作用户 |
| created_at | DATETIME | NOT NULL | 创建时间 |

**AIServiceConfig (AI服务配置)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 配置ID |
| name | VARCHAR(200) | NOT NULL | 配置名称 |
| service_type | ENUM | NOT NULL | 服务类型 (deepseek/qwen/siliconflow/other) |
| role | ENUM | NOT NULL | 角色类型 (doc_extractor/naming/mock_data/description) |
| api_key | VARCHAR(500) | - | API密钥 |
| base_url | VARCHAR(500) | NOT NULL | API地址 |
| model_name | VARCHAR(200) | NOT NULL | 模型名称 |
| max_tokens | INT | DEFAULT 4096 | 最大Token数 |
| temperature | FLOAT | DEFAULT 0.7 | 温度参数 |
| is_active | BOOLEAN | DEFAULT TRUE | 是否启用 |
| created_by_id | BIGINT | FK | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

#### 4.6.3 HTTP 方法枚举

- `GET` - GET 请求
- `POST` - POST 请求
- `PUT` - PUT 请求
- `PATCH` - PATCH 请求
- `DELETE` - DELETE 请求
- `HEAD` - HEAD 请求
- `OPTIONS` - OPTIONS 请求

#### 4.6.4 API 接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | /api/api-testing/projects/ | 项目列表 |
| POST | /api/api-testing/projects/ | 创建项目 |
| GET | /api/api-testing/projects/{id}/ | 项目详情 |
| PUT | /api/api-testing/projects/{id}/ | 更新项目 |
| DELETE | /api/api-testing/projects/{id}/ | 删除项目 |
| GET | /api/api-testing/collections/ | 集合列表 |
| POST | /api/api-testing/collections/ | 创建集合 |
| PUT | /api/api-testing/collections/{id}/ | 更新集合 |
| DELETE | /api/api-testing/collections/{id}/ | 删除集合 |
| GET | /api/api-testing/requests/ | 请求列表 |
| POST | /api/api-testing/requests/ | 创建请求 |
| GET | /api/api-testing/requests/{id}/ | 请求详情 |
| PUT | /api/api-testing/requests/{id}/ | 更新请求 |
| DELETE | /api/api-testing/requests/{id}/ | 删除请求 |
| POST | /api/api-testing/requests/{id}/execute/ | 执行请求 |
| GET | /api/api-testing/requests/{id}/history/ | 请求历史 |
| GET | /api/api-testing/environments/ | 环境列表 |
| POST | /api/api-testing/environments/ | 创建环境 |
| PUT | /api/api-testing/environments/{id}/ | 更新环境 |
| DELETE | /api/api-testing/environments/{id}/ | 删除环境 |
| GET | /api/api-testing/test-suites/ | 测试套件列表 |
| POST | /api/api-testing/test-suites/ | 创建测试套件 |
| POST | /api/api-testing/test-suites/{id}/execute/ | 执行套件 |
| GET | /api/api-testing/scheduled-tasks/ | 定时任务列表 |
| POST | /api/api-testing/scheduled-tasks/ | 创建定时任务 |
| PUT | /api/api-testing/scheduled-tasks/{id}/ | 更新定时任务 |
| DELETE | /api/api-testing/scheduled-tasks/{id}/ | 删除定时任务 |
| POST | /api/api-testing/scheduled-tasks/{id}/trigger/ | 手动触发 |

---

### 4.7 UI 自动化测试模块 (ui-automation)

#### 4.7.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 项目管理 | P0 | UI 自动化项目 |
| 元素管理 | P0 | 可视化元素定位、多种策略 |
| 元素分组 | P0 | 树形结构分组管理 |
| 备用定位器 | P0 | 多策略容错 |
| 页面对象 | P0 | Page Object 模式 |
| 测试脚本 | P0 | 代码/低代码脚本 |
| 用例编排 | P0 | 测试用例步骤编排 |
| 测试套件 | P0 | 脚本/用例编排 |
| 执行引擎 | P0 | Playwright/Selenium |
| 执行记录 | P0 | 执行结果、截图 |
| 定时任务 | P0 | CRON 定时执行 |
| 报告生成 | P0 | Allure 报告 |
| 通知推送 | P1 | 多渠道通知 |
| AI 智能模式 | P1 | 自然语言驱动浏览器 |

#### 4.7.2 数据模型

**UiProject (UI 项目)**

| 字段名      | 类型         | 约束                  | 说明     |
| :---------- | :----------- | :-------------------- | :------- |
| id          | BIGINT       | PK                    | 项目ID   |
| name        | VARCHAR(200) | NOT NULL              | 项目名称 |
| description | TEXT         | -                     | 项目描述 |
| base_url    | VARCHAR(200) | NOT NULL              | 基础URL  |
| status      | ENUM         | DEFAULT 'IN_PROGRESS' | 状态     |
| start_date  | DATE         | -                     | 开始日期 |
| end_date    | DATE         | -                     | 结束日期 |
| owner_id    | BIGINT       | FK                    | 负责人   |
| created_at  | DATETIME(6)  | NOT NULL              | 创建时间 |
| updated_at  | DATETIME(6)  | NOT NULL              | 更新时间 |

**LocatorStrategy (定位策略)**

| 字段名      | 类型        | 约束     | 说明     |
| :---------- | :---------- | :------- | :------- |
| id          | BIGINT      | PK       | 策略ID   |
| name        | VARCHAR(50) | NOT NULL | 策略名称 |
| description | TEXT        | -        | 策略描述 |

**ElementGroup (元素分组)**

| 字段名          | 类型         | 约束      | 说明     |
| :-------------- | :----------- | :-------- | :------- |
| id              | BIGINT       | PK        | 分组ID   |
| name            | VARCHAR(200) | NOT NULL  | 分组名称 |
| description     | TEXT         | NOT NULL  | 分组描述 |
| project_id      | BIGINT       | FK        | 项目ID   |
| parent_group_id | BIGINT       | FK (self) | 父分组   |
| order           | INT          | NOT NULL  | 排序     |
| created_at      | DATETIME(6)  | NOT NULL  | 创建时间 |
| updated_at      | DATETIME(6)  | NOT NULL  | 更新时间 |

**UiElement (UI 元素)**

| 字段名              | 类型         | 约束              | 说明         |
| :------------------ | :----------- | :---------------- | :----------- |
| id                  | BIGINT       | PK                | 元素ID       |
| name                | VARCHAR(200) | NOT NULL          | 元素名称     |
| description         | TEXT         | NOT NULL          | 元素描述     |
| project_id          | BIGINT       | FK                | 项目ID       |
| group_id            | BIGINT       | FK                | 分组ID       |
| element_type        | ENUM         | DEFAULT 'BUTTON'  | 元素类型     |
| locator_strategy_id | BIGINT       | FK                | 定位策略     |
| locator_value       | VARCHAR(500) | NOT NULL          | 定位表达式   |
| backup_locators     | JSON         | -                 | 备用定位器   |
| page                | VARCHAR(200) | NOT NULL          | 所属页面     |
| component_name      | VARCHAR(100) | NOT NULL          | 组件名称     |
| parent_element_id   | BIGINT       | FK (self)         | 父元素       |
| is_unique           | BOOLEAN      | DEFAULT FALSE     | 是否唯一     |
| wait_timeout        | INT          | DEFAULT 5         | 等待超时(秒) |
| is_visible          | BOOLEAN      | DEFAULT TRUE      | 是否可见     |
| is_enabled          | BOOLEAN      | DEFAULT TRUE      | 是否启用     |
| force_action        | BOOLEAN      | DEFAULT FALSE     | 强制操作     |
| usage_count         | INT          | DEFAULT 0         | 使用次数     |
| last_validated      | DATETIME(6)  | -                 | 最后验证时间 |
| validation_status   | ENUM         | DEFAULT 'UNKNOWN' | 验证状态     |
| validation_message  | TEXT         | NOT NULL          | 验证消息     |
| created_by_id       | BIGINT       | FK                | 创建人       |
| created_at          | DATETIME(6)  | NOT NULL          | 创建时间     |
| updated_at          | DATETIME(6)  | NOT NULL          | 更新时间     |

**PageObject (页面对象)**

| 字段名        | 类型         | 约束     | 说明         |
| :------------ | :----------- | :------- | :----------- |
| id            | BIGINT       | PK       | 页面对象ID   |
| name          | VARCHAR(200) | NOT NULL | 页面对象名称 |
| class_name    | VARCHAR(200) | NOT NULL | 类名         |
| url_pattern   | VARCHAR(500) | NOT NULL | URL模式      |
| project_id    | BIGINT       | FK       | 项目ID       |
| description   | TEXT         | NOT NULL | 描述         |
| template_code | TEXT         | NOT NULL | 模板代码     |
| created_by_id | BIGINT       | FK       | 创建人       |
| created_at    | DATETIME(6)  | NOT NULL | 创建时间     |
| updated_at    | DATETIME(6)  | NOT NULL | 更新时间     |

**PageObjectElement (页面对象元素关联)**

| 字段名         | 类型         | 约束         | 说明       |
| :------------- | :----------- | :----------- | :--------- |
| id             | BIGINT       | PK           | 主键       |
| page_object_id | BIGINT       | FK           | 页面对象ID |
| element_id     | BIGINT       | FK           | 元素ID     |
| method_name    | VARCHAR(100) | NOT NULL     | 方法名称   |
| is_property    | BOOLEAN      | DEFAULT TRUE | 是否为属性 |
| order          | INT          | DEFAULT 0    | 排序       |
| created_at     | DATETIME(6)  | NOT NULL     | 创建时间   |

**TestScript (测试脚本)**

| 字段名      | 类型         | 约束               | 说明     |
| :---------- | :----------- | :----------------- | :------- |
| id          | BIGINT       | PK                 | 脚本ID   |
| project_id  | BIGINT       | FK                 | 项目ID   |
| name        | VARCHAR(200) | NOT NULL           | 脚本名称 |
| description | TEXT         | NOT NULL           | 脚本描述 |
| script_type | ENUM         | DEFAULT 'LOW_CODE' | 脚本类型 |
| content     | TEXT         | NOT NULL           | 脚本内容 |
| language    | VARCHAR(20)  | NOT NULL           | 脚本语言 |
| framework   | VARCHAR(20)  | NOT NULL           | 执行框架 |
| created_at  | DATETIME(6)  | NOT NULL           | 创建时间 |
| updated_at  | DATETIME(6)  | NOT NULL           | 更新时间 |

**ScriptStep (脚本步骤)**

| 字段名            | 类型         | 约束      | 说明           |
| :---------------- | :----------- | :-------- | :------------- |
| id                | BIGINT       | PK        | 步骤ID         |
| script_id         | BIGINT       | FK        | 脚本ID         |
| step_order        | INT          | NOT NULL  | 步骤顺序       |
| action_type       | ENUM         | NOT NULL  | 操作类型       |
| target_element_id | BIGINT       | FK        | 目标元素       |
| page_object_id    | BIGINT       | FK        | 页面对象       |
| action_params     | JSON         | -         | 操作参数       |
| description       | VARCHAR(500) | NOT NULL  | 步骤描述       |
| expected_result   | VARCHAR(500) | NOT NULL  | 预期结果       |
| wait_before       | INT          | DEFAULT 0 | 执行前等待(ms) |
| wait_after        | INT          | DEFAULT 0 | 执行后等待(ms) |
| retry_count       | INT          | DEFAULT 0 | 重试次数       |
| created_at        | DATETIME(6)  | NOT NULL  | 创建时间       |
| updated_at        | DATETIME(6)  | NOT NULL  | 更新时间       |

**ScriptElementUsage (脚本元素使用记录)**

| 字段名      | 类型        | 约束      | 说明       |
| :---------- | :---------- | :-------- | :--------- |
| id          | BIGINT      | PK        | 主键       |
| script_id   | BIGINT      | FK        | 脚本ID     |
| element_id  | BIGINT      | FK        | 元素ID     |
| usage_type  | VARCHAR(50) | NOT NULL  | 使用类型   |
| line_number | INT         | NOT NULL  | 行号       |
| context     | TEXT        | NOT NULL  | 上下文代码 |
| frequency   | INT         | DEFAULT 1 | 使用频次   |
| created_at  | DATETIME(6) | NOT NULL  | 创建时间   |
| updated_at  | DATETIME(6) | NOT NULL  | 更新时间   |

**UiTestCase (UI 测试用例)**

| 字段名        | 类型         | 约束             | 说明     |
| :------------ | :----------- | :--------------- | :------- |
| id            | BIGINT       | PK               | 用例ID   |
| name          | VARCHAR(200) | NOT NULL         | 用例名称 |
| description   | TEXT         | NOT NULL         | 用例描述 |
| project_id    | BIGINT       | FK               | 项目ID   |
| status        | ENUM         | DEFAULT 'draft'  | 状态     |
| priority      | ENUM         | DEFAULT 'medium' | 优先级   |
| created_by_id | BIGINT       | FK               | 创建人   |
| created_at    | DATETIME(6)  | NOT NULL         | 创建时间 |
| updated_at    | DATETIME(6)  | NOT NULL         | 更新时间 |

**UiTestCaseStep (UI 测试用例步骤)**

| 字段名       | 类型        | 约束         | 说明         |
| :----------- | :---------- | :----------- | :----------- |
| id           | BIGINT      | PK           | 步骤ID       |
| test_case_id | BIGINT      | FK           | 测试用例ID   |
| step_number  | INT         | NOT NULL     | 步骤序号     |
| action_type  | VARCHAR(20) | NOT NULL     | 操作类型     |
| element_id   | BIGINT      | FK           | 目标元素     |
| input_value  | TEXT        | NOT NULL     | 输入值       |
| wait_time    | INT         | DEFAULT 1000 | 等待时间(ms) |
| assert_type  | VARCHAR(20) | NOT NULL     | 断言类型     |
| assert_value | TEXT        | NOT NULL     | 断言期望值   |
| description  | TEXT        | NOT NULL     | 步骤描述     |
| created_at   | DATETIME(6) | NOT NULL     | 创建时间     |

**TestSuite (测试套件)**

| 字段名           | 类型         | 约束              | 说明     |
| :--------------- | :----------- | :---------------- | :------- |
| id               | BIGINT       | PK                | 套件ID   |
| name             | VARCHAR(200) | NOT NULL          | 套件名称 |
| description      | TEXT         | NOT NULL          | 套件描述 |
| project_id       | BIGINT       | FK                | 项目ID   |
| execution_status | ENUM         | DEFAULT 'not_run' | 执行状态 |
| passed_count     | INT          | DEFAULT 0         | 通过数   |
| failed_count     | INT          | DEFAULT 0         | 失败数   |
| created_at       | DATETIME(6)  | NOT NULL          | 创建时间 |
| updated_at       | DATETIME(6)  | NOT NULL          | 更新时间 |

**TestSuiteScript (测试套件脚本关联)**

| 字段名         | 类型   | 约束      | 说明       |
| :------------- | :----- | :-------- | :--------- |
| id             | BIGINT | PK        | 主键       |
| test_suite_id  | BIGINT | FK        | 测试套件ID |
| test_script_id | BIGINT | FK        | 测试脚本ID |
| order          | INT    | DEFAULT 0 | 执行顺序   |

**TestSuiteTestCase (测试套件用例关联)**

| 字段名        | 类型   | 约束      | 说明       |
| :------------ | :----- | :-------- | :--------- |
| id            | BIGINT | PK        | 主键       |
| test_suite_id | BIGINT | FK        | 测试套件ID |
| test_case_id  | BIGINT | FK        | 测试用例ID |
| order         | INT    | DEFAULT 0 | 执行顺序   |

**TestEnvironment (测试环境配置)**

| 字段名          | 类型         | 约束     | 说明           |
| :-------------- | :----------- | :------- | :------------- |
| id              | BIGINT       | PK       | 环境ID         |
| name            | VARCHAR(100) | NOT NULL | 环境名称       |
| description     | TEXT         | NOT NULL | 环境描述       |
| browser_type    | VARCHAR(50)  | NOT NULL | 浏览器类型     |
| browser_version | VARCHAR(50)  | NOT NULL | 浏览器版本     |
| resolution      | VARCHAR(50)  | NOT NULL | 屏幕分辨率     |
| os_type         | VARCHAR(50)  | NOT NULL | 操作系统       |
| os_version      | VARCHAR(50)  | NOT NULL | 操作系统版本   |
| capabilities    | JSON         | -        | 浏览器能力配置 |
| created_at      | DATETIME(6)  | NOT NULL | 创建时间       |
| updated_at      | DATETIME(6)  | NOT NULL | 更新时间       |

**TestExecution (测试执行记录)**

| 字段名         | 类型         | 约束              | 说明         |
| :------------- | :----------- | :---------------- | :----------- |
| id             | BIGINT       | PK                | 执行ID       |
| project_id     | BIGINT       | FK                | 项目ID       |
| test_suite_id  | BIGINT       | FK                | 测试套件     |
| test_script_id | BIGINT       | FK                | 测试脚本     |
| environment    | VARCHAR(20)  | NOT NULL          | 执行环境     |
| status         | ENUM         | DEFAULT 'PENDING' | 执行状态     |
| total_cases    | INT          | DEFAULT 0         | 总用例数     |
| passed_cases   | INT          | DEFAULT 0         | 通过用例数   |
| failed_cases   | INT          | DEFAULT 0         | 失败用例数   |
| skipped_cases  | INT          | DEFAULT 0         | 跳过用例数   |
| started_at     | DATETIME(6)  | -                 | 开始时间     |
| finished_at    | DATETIME(6)  | -                 | 结束时间     |
| duration       | FLOAT        | DEFAULT 0         | 执行时长(秒) |
| executed_by_id | BIGINT       | FK                | 执行人员     |
| engine         | VARCHAR(20)  | NOT NULL          | 测试引擎     |
| browser        | VARCHAR(20)  | NOT NULL          | 浏览器       |
| headless       | BOOLEAN      | DEFAULT FALSE     | 无头模式     |
| result_data    | JSON         | -                 | 执行结果数据 |
| error_message  | TEXT         | NOT NULL          | 错误信息     |
| report_url     | VARCHAR(500) | NOT NULL          | 报告URL      |
| created_at     | DATETIME(6)  | NOT NULL          | 创建时间     |

**TestCaseExecution (测试用例执行记录)**

| 字段名           | 类型        | 约束              | 说明         |
| :--------------- | :---------- | :---------------- | :----------- |
| id               | BIGINT      | PK                | 执行ID       |
| test_case_id     | BIGINT      | FK                | 测试用例     |
| project_id       | BIGINT      | FK                | 项目         |
| test_suite_id    | BIGINT      | FK                | 所属测试套件 |
| execution_source | VARCHAR(20) | NOT NULL          | 执行来源     |
| status           | ENUM        | DEFAULT 'pending' | 执行状态     |
| engine           | VARCHAR(20) | NOT NULL          | 测试引擎     |
| browser          | VARCHAR(50) | NOT NULL          | 浏览器       |
| headless         | BOOLEAN     | DEFAULT FALSE     | 无头模式     |
| execution_logs   | TEXT        | NOT NULL          | 执行日志     |
| error_message    | TEXT        | -                 | 错误信息     |
| screenshots      | JSON        | NOT NULL          | 截图列表     |
| execution_time   | FLOAT       | -                 | 执行时长(秒) |
| started_at       | DATETIME(6) | -                 | 开始时间     |
| finished_at      | DATETIME(6) | -                 | 完成时间     |
| created_by_id    | BIGINT      | FK                | 执行人       |
| created_at       | DATETIME(6) | NOT NULL          | 创建时间     |

**Screenshot (截图)**

| 字段名       | 类型         | 约束     | 说明         |
| :----------- | :----------- | :------- | :----------- |
| id           | BIGINT       | PK       | 截图ID       |
| execution_id | BIGINT       | FK       | 测试执行     |
| name         | VARCHAR(200) | NOT NULL | 截图名称     |
| image        | VARCHAR(100) | NOT NULL | 截图文件路径 |
| description  | TEXT         | NOT NULL | 截图描述     |
| captured_at  | DATETIME(6)  | NOT NULL | 捕获时间     |

**OperationRecord (操作记录)**

| 字段名         | 类型         | 约束     | 说明     |
| :------------- | :----------- | :------- | :------- |
| id             | BIGINT       | PK       | 记录ID   |
| operation_type | ENUM         | NOT NULL | 操作类型 |
| resource_type  | ENUM         | NOT NULL | 资源类型 |
| resource_id    | INT          | NOT NULL | 资源ID   |
| resource_name  | VARCHAR(200) | NOT NULL | 资源名称 |
| description    | TEXT         | NOT NULL | 操作描述 |
| user_id        | BIGINT       | FK       | 操作用户 |
| created_at     | DATETIME(6)  | NOT NULL | 创建时间 |

**UiScheduledTask (定时任务)**

| 字段名            | 类型         | 约束             | 说明         |
| :---------------- | :----------- | :--------------- | :----------- |
| id                | BIGINT       | PK               | 任务ID       |
| name              | VARCHAR(200) | NOT NULL         | 任务名称     |
| description       | TEXT         | NOT NULL         | 任务描述     |
| task_type         | ENUM         | NOT NULL         | 任务类型     |
| trigger_type      | ENUM         | NOT NULL         | 触发器类型   |
| cron_expression   | VARCHAR(100) | NOT NULL         | CRON表达式   |
| interval_seconds  | INT          | -                | 间隔秒数     |
| execute_at        | DATETIME(6)  | -                | 执行时间     |
| project_id        | BIGINT       | FK               | 关联项目     |
| test_suite_id     | BIGINT       | FK               | 测试套件     |
| test_cases        | JSON         | NOT NULL         | 测试用例列表 |
| engine            | VARCHAR(20)  | NOT NULL         | 执行引擎     |
| browser           | VARCHAR(20)  | NOT NULL         | 浏览器类型   |
| headless          | BOOLEAN      | DEFAULT FALSE    | 无头模式     |
| status            | ENUM         | DEFAULT 'ACTIVE' | 任务状态     |
| last_run_time     | DATETIME(6)  | -                | 最后运行时间 |
| next_run_time     | DATETIME(6)  | -                | 下次运行时间 |
| total_runs        | INT          | DEFAULT 0        | 总运行次数   |
| successful_runs   | INT          | DEFAULT 0        | 成功运行次数 |
| failed_runs       | INT          | DEFAULT 0        | 失败运行次数 |
| last_result       | JSON         | NOT NULL         | 最后执行结果 |
| error_message     | TEXT         | NOT NULL         | 错误信息     |
| notify_on_success | BOOLEAN      | DEFAULT FALSE    | 成功时通知   |
| notify_on_failure | BOOLEAN      | DEFAULT FALSE    | 失败时通知   |
| notification_type | VARCHAR(20)  | NOT NULL         | 通知类型     |
| notify_emails     | JSON         | NOT NULL         | 通知邮箱列表 |
| created_by_id     | BIGINT       | FK               | 创建人       |
| created_at        | DATETIME(6)  | NOT NULL         | 创建时间     |
| updated_at        | DATETIME(6)  | NOT NULL         | 更新时间     |

**UiNotificationLog (UI通知日志)**

| 字段名               | 类型         | 约束              | 说明              |
| :------------------- | :----------- | :---------------- | :---------------- |
| id                   | BIGINT       | PK                | 日志ID            |
| task_id              | BIGINT       | FK                | 关联任务          |
| task_name            | VARCHAR(200) | NOT NULL          | 任务名称快照      |
| task_type            | VARCHAR(20)  | -                 | 任务类型快照      |
| notification_type    | ENUM         | NOT NULL          | 通知类型          |
| sender_name          | VARCHAR(100) | NOT NULL          | 发件人姓名        |
| sender_email         | VARCHAR(254) | NOT NULL          | 发件人邮箱        |
| recipient_info       | JSON         | NOT NULL          | 收件人信息        |
| webhook_bot_info     | JSON         | -                 | Webhook机器人信息 |
| notification_content | TEXT         | NOT NULL          | 通知内容          |
| status               | ENUM         | DEFAULT 'pending' | 发送状态          |
| error_message        | TEXT         | -                 | 错误信息          |
| response_info        | JSON         | -                 | 响应信息          |
| retry_count          | INT          | DEFAULT 0         | 重试次数          |
| is_retried           | BOOLEAN      | DEFAULT FALSE     | 是否已重试        |
| created_at           | DATETIME(6)  | NOT NULL          | 创建时间          |
| sent_at              | DATETIME(6)  | -                 | 发送时间          |

**UiTaskNotificationSetting (UI任务通知设置)**

| 字段名                 | 类型        | 约束          | 说明                |
| :--------------------- | :---------- | :------------ | :------------------ |
| id                     | BIGINT      | PK            | 设置ID              |
| task_id                | BIGINT      | FK, UNIQUE    | 定时任务ID          |
| notification_type      | VARCHAR(20) | NOT NULL      | 通知类型            |
| notification_config_id | BIGINT      | FK            | 通知配置            |
| is_enabled             | BOOLEAN     | DEFAULT FALSE | 是否启用通知        |
| notify_on_success      | BOOLEAN     | DEFAULT TRUE  | 成功时通知          |
| notify_on_failure      | BOOLEAN     | DEFAULT TRUE  | 失败时通知          |
| notify_on_timeout      | BOOLEAN     | DEFAULT FALSE | 超时时通知          |
| notify_on_error        | BOOLEAN     | DEFAULT TRUE  | 错误时通知          |
| custom_webhook_bots    | JSON        | -             | 自定义Webhook机器人 |
| created_at             | DATETIME(6) | NOT NULL      | 创建时间            |
| updated_at             | DATETIME(6) | NOT NULL      | 更新时间            |

**AICase (AI 测试用例)**

| 字段名           | 类型         | 约束     | 说明     |
| :--------------- | :----------- | :------- | :------- |
| id               | BIGINT       | PK       | 用例ID   |
| project_id       | BIGINT       | FK       | 所属项目 |
| name             | VARCHAR(200) | NOT NULL | 用例名称 |
| description      | TEXT         | -        | 描述     |
| task_description | TEXT         | NOT NULL | 任务描述 |
| created_by_id    | BIGINT       | FK       | 创建人   |
| created_at       | DATETIME(6)  | NOT NULL | 创建时间 |
| updated_at       | DATETIME(6)  | NOT NULL | 更新时间 |

**AIExecutionRecord (AI 执行记录)**

| 字段名               | 类型         | 约束     | 说明         |
| :------------------- | :----------- | :------- | :----------- |
| id                   | BIGINT       | PK       | 记录ID       |
| case_name            | VARCHAR(200) | NOT NULL | 用例名称快照 |
| project_id           | BIGINT       | FK       | 所属项目     |
| ai_case_id           | BIGINT       | FK       | AI用例ID     |
| task_description     | TEXT         | NOT NULL | 任务描述     |
| execution_mode       | VARCHAR(20)  | NOT NULL | 执行模式     |
| status               | ENUM         | NOT NULL | 执行状态     |
| logs                 | TEXT         | NOT NULL | 执行日志     |
| steps_completed      | JSON         | NOT NULL | 已完成步骤   |
| planned_tasks        | JSON         | NOT NULL | 规划任务     |
| screenshots_sequence | JSON         | NOT NULL | 截图序列     |
| gif_path             | VARCHAR(500) | -        | GIF录制路径  |
| start_time           | DATETIME(6)  | NOT NULL | 开始时间     |
| end_time             | DATETIME(6)  | -        | 结束时间     |
| duration             | FLOAT        | -        | 执行时长(秒) |
| executed_by_id       | BIGINT       | FK       | 执行人       |

#### 4.7.3 内置定位策略

| 策略 | 说明 |
|------|------|
| ID | 元素 ID 属性 |
| CSS | CSS Selector |
| XPATH | XPath 表达式 |
| NAME | 元素 name 属性 |
| CLASS_NAME | 元素 class 属性 |
| TAG_NAME | HTML 标签名 |
| LINK_TEXT | 链接文本 |
| PARTIAL_LINK_TEXT | 部分链接文本 |

#### 4.7.4 元素类型

| 类型 | 描述 |
|------|------|
| INPUT | 输入框 |
| BUTTON | 按钮 |
| LINK | 链接 |
| DROPDOWN | 下拉框 |
| CHECKBOX | 复选框 |
| RADIO | 单选框 |
| TEXT | 文本元素 |
| IMAGE | 图片 |
| CONTAINER | 容器 |
| TABLE | 表格 |
| FORM | 表单 |
| MODAL | 弹窗 |

#### 4.7.5 API 接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | /api/ui-automation/projects/ | 项目列表 |
| POST | /api/ui-automation/projects/ | 创建项目 |
| GET | /api/ui-automation/projects/{id}/ | 项目详情 |
| PUT | /api/ui-automation/projects/{id}/ | 更新项目 |
| DELETE | /api/ui-automation/projects/{id}/ | 删除项目 |
| GET | /api/ui-automation/elements/ | 元素列表 |
| POST | /api/ui-automation/elements/ | 创建元素 |
| GET | /api/ui-automation/elements/{id}/ | 元素详情 |
| PUT | /api/ui-automation/elements/{id}/ | 更新元素 |
| DELETE | /api/ui-automation/elements/{id}/ | 删除元素 |
| POST | /api/ui-automation/elements/{id}/validate/ | 验证元素 |
| GET | /api/ui-automation/element-groups/ | 元素分组 |
| POST | /api/ui-automation/element-groups/ | 创建分组 |
| GET | /api/ui-automation/test-scripts/ | 脚本列表 |
| POST | /api/ui-automation/test-scripts/ | 创建脚本 |
| PUT | /api/ui-automation/test-scripts/{id}/ | 更新脚本 |
| DELETE | /api/ui-automation/test-scripts/{id}/ | 删除脚本 |
| GET | /api/ui-automation/test-cases/ | 用例列表 |
| POST | /api/ui-automation/test-cases/ | 创建用例 |
| GET | /api/ui-automation/test-suites/ | 测试套件 |
| POST | /api/ui-automation/test-suites/ | 创建套件 |
| POST | /api/ui-automation/test-suites/{id}/execute/ | 执行套件 |
| GET | /api/ui-automation/test-executions/ | 执行记录 |
| GET | /api/ui-automation/test-executions/{id}/ | 执行详情 |
| GET | /api/ui-automation/scheduled-tasks/ | 定时任务 |
| POST | /api/ui-automation/scheduled-tasks/ | 创建任务 |
| POST | /api/ui-automation/ai-cases/ | AI 用例 |
| POST | /api/ui-automation/ai-cases/{id}/execute/ | AI 执行 |

---

### 4.8 APP 自动化测试模块 (app-automation)

#### 4.8.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 项目管理 | P0 | APP 自动化项目 |
| 设备管理 | P0 | Android 设备连接/状态 |
| 设备锁定 | P0 | 设备占用与释放 |
| 元素管理 | P0 | 图片/坐标/区域定位 |
| 组件管理 | P0 | UI 组件库 |
| 应用管理 | P0 | 包名管理 |
| 用例编排 | P0 | UI Flow 可视化编排 |
| 测试套件 | P0 | 用例组合 |
| 执行记录 | P0 | 执行结果、截图 |
| 定时任务 | P0 | 定时执行 |
| 报告生成 | P0 | Allure 报告 |

#### 4.8.2 数据模型

**AppProject (APP 项目)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 项目ID |
| name | VARCHAR(200) | NOT NULL | 项目名称 |
| description | TEXT | NOT NULL | 项目描述 |
| status | ENUM | DEFAULT 'IN_PROGRESS' | 状态 |
| start_date | DATE | - | 开始日期 |
| end_date | DATE | - | 结束日期 |
| owner_id | BIGINT | FK | 负责人 |
| created_at | DATETIME(6) | NOT NULL | 创建时间 |
| updated_at | DATETIME(6) | NOT NULL | 更新时间 |

**AppTestConfig (APP 测试配置)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 配置ID |
| adb_path | VARCHAR(500) | DEFAULT 'adb' | ADB路径 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**AppDevice (设备表)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 设备ID |
| device_id | VARCHAR(255) | UNIQUE | 设备序列号 |
| name | VARCHAR(255) | NOT NULL | 设备名称 |
| status | ENUM | DEFAULT 'OFFLINE' | 状态 |
| android_version | VARCHAR(50) | NOT NULL | Android版本 |
| connection_type | ENUM | NOT NULL | 连接类型 |
| ip_address | VARCHAR(50) | NOT NULL | IP地址 |
| port | INT | NOT NULL | 端口 |
| locked_by_id | BIGINT | NULL | 锁定用户 |
| locked_at | DATETIME | - | 锁定时间 |
| max_allocation_time | INT | NOT NULL | 最大分配时间(秒) |
| device_specs | JSON | NOT NULL | 设备规格 |
| description | TEXT | NOT NULL | 设备描述 |
| location | VARCHAR(200) | NOT NULL | 设备位置 |
| created_at | DATETIME (6) | NOT NULL | 创建时间 |
| updated_at | DATETIME (6) | NOT NULL | 更新时间 |

**AppElement (APP 元素)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 元素ID |
| name | VARCHAR(200) | NOT NULL (UNIQUE) | 元素名称 |
| element_type | ENUM | NOT NULL | 元素类型 (IMAGE/POS/REGION) |
| config | JSON | NOT NULL | 元素配置 |
| resolution_configs | JSON | NOT NULL | 多分辨率配置 |
| tags | JSON | NOT NULL | 标签列表 |
| usage_count | INT | NOT NULL | 使用次数 |
| last_used_at | DATETIME | - | 最后使用时间 |
| project_id | BIGINT | FK | 项目ID |
| created_by_id | BIGINT | FK | 创建人 |
| created_at | DATETIME (6) | NOT NULL | 创建时间 |
| updated_at | DATETIME (6) | NOT NULL | 更新时间 |
| is_active | BOOLEAN | NOT NULL | 是否启用 |

**AppComponent (基础组件定义)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 组件ID |
| name | VARCHAR(100) | NOT NULL | 组件名称 |
| type | VARCHAR(50) | NOT NULL | 组件类型 |
| category | VARCHAR(50) | - | 类别 |
| description | TEXT | NOT NULL | 描述 |
| schema | JSON | NOT NULL | 配置Schema |
| default_config | JSON | NOT NULL | 默认配置 |
| enabled | BOOLEAN | NOT NULL | 是否启用 |
| sort_order | INT | NOT NULL | 排序 |
| created_at | DATETIME(6) | NOT NULL | 创建时间 |
| updated_at | DATETIME(6) | NOT NULL | 更新时间 |

**AppCustomComponent (自定义组件)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 组件ID |
| name | VARCHAR(100) | NOT NULL | 组件名称 |
| type | VARCHAR(50) | NOT NULL | 组件类型 |
| description | TEXT | NOT NULL | 描述 |
| schema | JSON | NOT NULL | 参数Schema |
| default_config | JSON | NOT NULL | 默认参数 |
| steps | JSON | NOT NULL | 组合步骤 |
| enabled | BOOLEAN | NOT NULL | 是否启用 |
| sort_order | INT | NOT NULL | 排序 |
| created_at | DATETIME(6) | NOT NULL | 创建时间 |
| updated_at | DATETIME(6) | NOT NULL | 更新时间 |

**AppComponentPackage (组件包)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 包ID |
| name | VARCHAR(100) | NOT NULL | 包名称 |
| version | VARCHAR(50) | NOT NULL | 版本 |
| description | TEXT | - | 描述 |
| author | VARCHAR(100) | - | 作者 |
| source | ENUM | NOT NULL | 来源 |
| manifest | JSON | NOT NULL | 包清单 |
| created_by_id | BIGINT | NULL | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**AppPackage (应用包名)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 包ID |
| name | VARCHAR(100) | NOT NULL | 应用名称 |
| package_name | VARCHAR(255) | NOT NULL | 包名 |
| created_by_id | BIGINT | NULL | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**AppTestSuite (测试套件)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 套件ID |
| name | VARCHAR(200) | NOT NULL | 套件名称 |
| description | TEXT | NOT NULL | 套件描述 |
| project_id | BIGINT | FK | 项目ID |
| execution_status | ENUM | NOT NULL | 执行状态 |
| execution_result | ENUM | - | 测试结果 |
| passed_count | INT | NOT NULL | 通过用例数 |
| failed_count | INT | NOT NULL | 失败用例数 |
| last_run_at | DATETIME | - | 最后执行时间 |
| created_by_id | BIGINT | NOT NULL | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**AppTestSuiteCase (套件用例关联)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 主键 |
| test_suite_id | BIGINT | FK | 测试套件ID |
| test_case_id | BIGINT | FK | 测试用例ID |
| order | INT | DEFAULT 0 | 执行顺序 |

**AppTestCase (APP 测试用例)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 用例ID |
| name | VARCHAR(200) | NOT NULL | 用例名称 |
| description | TEXT | - | 用例描述 |
| project_id | BIGINT | FK | 项目ID |
| app_package_id | BIGINT | FK | 应用包名 |
| ui_flow | JSON | - | UI流程定义 |
| variables | JSON | - | 变量定义 |
| timeout | INT | DEFAULT 300 | 超时时间(秒) |
| retry_count | INT | DEFAULT 0 | 失败重试次数 |
| created_by_id | BIGINT | FK | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**AppTestExecution (执行记录)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 执行ID |
| test_case_id | BIGINT | FK | 测试用例 |
| test_suite_id | BIGINT | FK | 所属套件 |
| device_id | BIGINT | FK | 设备ID |
| user_id | BIGINT | FK | 执行用户 |
| status | ENUM | DEFAULT 'PENDING' | 执行状态 |
| result | ENUM | - | 测试结果 |
| task_id | VARCHAR(255) | - | Celery任务ID |
| progress | INT | DEFAULT 0 | 执行进度(0-100) |
| started_at | DATETIME | - | 开始时间 |
| finished_at | DATETIME | - | 结束时间 |
| duration | FLOAT | DEFAULT 0 | 执行时长(秒) |
| report_path | VARCHAR(500) | - | Allure报告路径 |
| error_message | TEXT | - | 错误信息 |
| total_steps | INT | DEFAULT 0 | 总步骤数 |
| passed_steps | INT | DEFAULT 0 | 通过步骤数 |
| failed_steps | INT | DEFAULT 0 | 失败步骤数 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**AppScheduledTask (定时任务)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 任务ID |
| name | VARCHAR(200) | NOT NULL | 任务名称 |
| description | TEXT | - | 任务描述 |
| task_type | ENUM | NOT NULL | 任务类型 |
| trigger_type | ENUM | NOT NULL | 触发器类型 |
| cron_expression | VARCHAR(100) | - | CRON表达式 |
| interval_seconds | INT | - | 间隔秒数 |
| execute_at | DATETIME | - | 执行时间 |
| project_id | BIGINT | FK | 项目ID |
| device_id | BIGINT | FK | 执行设备 |
| app_package_id | BIGINT | FK | 应用包名 |
| test_suite_id | BIGINT | FK | 测试套件 |
| test_case_id | BIGINT | FK | 测试用例 |
| status | ENUM | DEFAULT 'ACTIVE' | 任务状态 |
| last_run_time | DATETIME | - | 最后运行时间 |
| next_run_time | DATETIME | - | 下次运行时间 |
| total_runs | INT | DEFAULT 0 | 总运行次数 |
| successful_runs | INT | DEFAULT 0 | 成功次数 |
| failed_runs | INT | DEFAULT 0 | 失败次数 |
| last_result | JSON | - | 最后执行结果 |
| error_message | TEXT | - | 错误信息 |
| notify_on_success | BOOLEAN | DEFAULT FALSE | 成功时通知 |
| notify_on_failure | BOOLEAN | DEFAULT FALSE | 失败时通知 |
| notification_type | ENUM | - | 通知类型 |
| notify_emails | JSON | - | 通知邮箱列表 |
| created_by_id | BIGINT | FK | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**AppNotificationLog (APP通知日志)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 日志ID |
| task_id | BIGINT | FK | 关联任务 |
| task_name | VARCHAR(200) | - | 任务名称快照 |
| task_type | VARCHAR(20) | - | 任务类型快照 |
| notification_type | ENUM | NOT NULL | 通知类型 |
| sender_name | VARCHAR(100) | - | 发件人姓名 |
| sender_email | VARCHAR(254) | - | 发件人邮箱 |
| recipient_info | JSON | - | 收件人信息 |
| webhook_bot_info | JSON | - | Webhook机器人信息 |
| notification_content | TEXT | - | 通知内容 |
| status | ENUM | DEFAULT 'pending' | 发送状态 |
| error_message | TEXT | - | 错误信息 |
| response_info | JSON | - | 响应信息 |
| retry_count | INT | DEFAULT 0 | 重试次数 |
| is_retried | BOOLEAN | DEFAULT FALSE | 是否已重试 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| sent_at | DATETIME | - | 发送时间 |

#### 4.8.3 API 接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | /api/app-automation/projects/ | 项目列表 |
| POST | /api/app-automation/projects/ | 创建项目 |
| GET | /api/app-automation/projects/{id}/ | 项目详情 |
| PUT | /api/app-automation/projects/{id}/ | 更新项目 |
| DELETE | /api/app-automation/projects/{id}/ | 删除项目 |
| GET | /api/app-automation/devices/ | 设备列表 |
| POST | /api/app-automation/devices/ | 添加设备 |
| GET | /api/app-automation/devices/{id}/ | 设备详情 |
| PUT | /api/app-automation/devices/{id}/ | 更新设备 |
| DELETE | /api/app-automation/devices/{id}/ | 删除设备 |
| GET | /api/app-automation/elements/ | 元素列表 |
| POST | /api/app-automation/elements/ | 创建元素 |
| GET | /api/app-automation/elements/{id}/ | 元素详情 |
| PUT | /api/app-automation/elements/{id}/ | 更新元素 |
| DELETE | /api/app-automation/elements/{id}/ | 删除元素 |
| GET | /api/app-automation/test-cases/ | 测试用例列表 |
| POST | /api/app-automation/test-cases/ | 创建用例 |
| GET | /api/app-automation/test-cases/{id}/ | 用例详情 |
| PUT | /api/app-automation/test-cases/{id}/ | 更新用例 |
| DELETE | /api/app-automation/test-cases/{id}/ | 删除用例 |
| GET | /api/app-automation/test-suites/ | 测试套件列表 |
| POST | /api/app-automation/test-suites/ | 创建套件 |
| POST | /api/app-automation/test-suites/{id}/execute/ | 执行套件 |
| GET | /api/app-automation/executions/ | 执行记录 |
| GET | /api/app-automation/executions/{id}/ | 执行详情 |
| GET | /api/app-automation/scheduled-tasks/ | 定时任务 |
| POST | /api/app-automation/scheduled-tasks/ | 创建任务 |

---

### 4.9 AI 需求分析模块 (requirement-analysis)

#### 4.9.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 文档上传 | P0 | PDF/Word/TXT/Markdown |
| 文档解析 | P0 | 提取文本内容 |
| 需求分析 | P0 | AI 自动分析需求 |
| 用例生成 | P0 | 流式输出生成用例 |
| AI 评审 | P1 | 用例质量评审 |
| AI 改进 | P1 | 根据评审意见改进 |
| 生成配置 | P0 | 模型选择、参数调整 |
| 提示词配置 | P1 | 自定义提示词模板 |
| 导出功能 | P1 | 导出到用例库 |

#### 4.9.2 数据模型

**RequirementDocument (需求文档)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 文档ID |
| title | VARCHAR(200) | NOT NULL | 文档标题 |
| file | VARCHAR(100) | NOT NULL | 文件路径 |
| document_type | ENUM | NOT NULL | 文档类型 |
| status | ENUM | DEFAULT 'uploaded' | 状态 |
| file_size | BIGINT | - | 文件大小(bytes) |
| extracted_text | TEXT | - | 提取的文本内容 |
| uploaded_by_id | BIGINT | FK | 上传者 |
| project_id | BIGINT | FK | 关联项目 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**RequirementAnalysis (分析结果)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 分析ID |
| document_id | BIGINT | FK, UNIQUE | 文档ID |
| analysis_report | TEXT | - | 分析报告 |
| requirements_count | INT | DEFAULT 0 | 需求数量 |
| analysis_time | FLOAT | - | 分析耗时(秒) |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**BusinessRequirement (业务需求)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 需求ID |
| analysis_id | BIGINT | FK | 分析ID |
| requirement_id | VARCHAR(50) | NOT NULL | 需求编号 |
| requirement_name | VARCHAR(200) | NOT NULL | 需求名称 |
| requirement_type | ENUM | - | 需求类型 |
| parent_requirement_id | BIGINT | FK | 父级需求 |
| module | VARCHAR(100) | - | 所属模块 |
| requirement_level | ENUM | - | 需求级别 |
| reviewer | VARCHAR(50) | - | 评审人 |
| estimated_hours | INT | DEFAULT 8 | 预计工时 |
| description | TEXT | - | 需求描述 |
| acceptance_criteria | TEXT | - | 验收标准 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**GeneratedTestCase (生成的测试用例)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 用例ID |
| requirement_id | BIGINT | FK | 关联需求 |
| case_id | VARCHAR(50) | NOT NULL | 用例编号 |
| title | VARCHAR(300) | NOT NULL | 用例标题 |
| priority | ENUM | - | 优先级 |
| precondition | TEXT | - | 前置条件 |
| test_steps | TEXT | - | 测试步骤 |
| expected_result | TEXT | - | 预期结果 |
| status | ENUM | DEFAULT 'generated' | 状态 |
| generated_by_ai | VARCHAR(50) | - | 生成AI模型 |
| reviewed_by_ai | VARCHAR(50) | - | 评审AI模型 |
| review_comments | TEXT | - | 评审意见 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**AnalysisTask (分析任务)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 任务ID |
| task_id | VARCHAR(100) | UNIQUE | 任务ID |
| task_type | ENUM | NOT NULL | 任务类型 |
| document_id | BIGINT | FK | 文档ID |
| status | ENUM | DEFAULT 'pending' | 状态 |
| progress | INT | DEFAULT 0 | 进度百分比 |
| result | JSON | - | 任务结果 |
| error_message | TEXT | - | 错误信息 |
| started_at | DATETIME | - | 开始时间 |
| completed_at | DATETIME | - | 完成时间 |
| created_at | DATETIME | NOT NULL | 创建时间 |

**GenerationConfig (生成行为配置)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 配置ID |
| name | VARCHAR(100) | NOT NULL | 配置名称 |
| default_output_mode | ENUM | DEFAULT 'stream' | 默认输出模式 |
| enable_auto_review | BOOLEAN | DEFAULT TRUE | 启用AI评审和改进 |
| review_timeout | INT | DEFAULT 120 | 评审超时时间(秒) |
| is_active | BOOLEAN | DEFAULT TRUE | 是否启用 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**TestCaseGenerationTask (测试用例生成任务)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 任务ID |
| task_id | VARCHAR(50) | UNIQUE | 任务ID |
| title | VARCHAR(200) | NOT NULL | 任务标题 |
| requirement_text | TEXT | - | 需求描述 |
| status | ENUM | DEFAULT 'pending' | 状态 |
| progress | INT | DEFAULT 0 | 进度百分比 |
| output_mode | ENUM | DEFAULT 'stream' | 输出模式 |
| stream_buffer | TEXT | - | 流式输出缓冲区 |
| stream_position | INT | DEFAULT 0 | 流式输出位置 |
| last_stream_update | DATETIME | - | 最后流式更新时间 |
| project_id | BIGINT | FK | 关联项目 |
| writer_model_config_id | BIGINT | FK | 编写模型配置 |
| reviewer_model_config_id | BIGINT | FK | 评审模型配置 |
| writer_prompt_config_id | BIGINT | FK | 编写提示词配置 |
| reviewer_prompt_config_id | BIGINT | FK | 评审提示词配置 |
| generated_test_cases | TEXT | - | 生成的测试用例 |
| review_feedback | TEXT | - | 评审反馈 |
| final_test_cases | TEXT | - | 最终测试用例 |
| generation_log | TEXT | - | 生成日志 |
| error_message | TEXT | - | 错误信息 |
| created_by_id | BIGINT | FK | 创建者 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |
| completed_at | DATETIME | - | 完成时间 |
| is_saved_to_records | BOOLEAN | DEFAULT FALSE | 是否已保存到记录 |
| saved_at | DATETIME | - | 保存到记录时间 |

**AIModelConfig (AI 模型配置)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 配置ID |
| name | VARCHAR(100) | NOT NULL | 配置名称 |
| model_type | ENUM | NOT NULL | 模型类型 |
| role | ENUM | NOT NULL | 角色 |
| api_key | VARCHAR(200) | - | API密钥 |
| base_url | VARCHAR(200) | NOT NULL | API地址 |
| model_name | VARCHAR(100) | NOT NULL | 模型名称 |
| max_tokens | INT | DEFAULT 4096 | 最大Token数 |
| temperature | FLOAT | DEFAULT 0.7 | 温度参数 |
| top_p | FLOAT | DEFAULT 0.9 | Top P参数 |
| is_active | BOOLEAN | DEFAULT TRUE | 是否启用 |
| created_by_id | BIGINT | FK | 创建者 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**PromptConfig (提示词配置)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 配置ID |
| name | VARCHAR(100) | NOT NULL | 配置名称 |
| prompt_type | ENUM | NOT NULL | 提示词类型 |
| content | TEXT | NOT NULL | 提示词内容 |
| is_active | BOOLEAN | DEFAULT TRUE | 是否启用 |
| created_by_id | BIGINT | FK | 创建者 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

#### 4.9.3 模型类型

| 类型 | 描述 |
|------|------|
| deepseek | DeepSeek |
| qwen | 通义千问 |
| siliconflow | 硅基流动 |
| zhipu | 智谱AI |
| other | 其他兼容API |

#### 4.9.4 API 接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | /api/requirement-analysis/documents/ | 文档列表 |
| POST | /api/requirement-analysis/documents/ | 上传文档 |
| GET | /api/requirement-analysis/documents/{id}/ | 文档详情 |
| DELETE | /api/requirement-analysis/documents/{id}/ | 删除文档 |
| POST | /api/requirement-analysis/documents/{id}/analyze/ | 分析文档 |
| GET | /api/requirement-analysis/analyses/ | 分析结果列表 |
| GET | /api/requirement-analysis/analyses/{id}/ | 分析结果详情 |
| GET | /api/requirement-analysis/requirements/ | 业务需求列表 |
| POST | /api/requirement-analysis/testcase-generation/ | 生成测试用例 |
| GET | /api/requirement-analysis/testcase-generation/{task_id}/stream_progress/ | 流式获取生成进度 |
| GET | /api/requirement-analysis/test-cases/ | 生成的用例列表 |
| PUT | /api/requirement-analysis/test-cases/{id}/import | 导入用例库 |
| GET | /api/requirement-analysis/ai-models/ | AI 模型配置列表 |
| POST | /api/requirement-analysis/ai-models/ | 创建配置 |
| POST | /api/requirement-analysis/ai-models/{id}/test_connection/ | 测试连接 |
| GET | /api/requirement-analysis/prompts/ | 提示词列表 |
| POST | /api/requirement-analysis/prompts/ | 创建提示词 |
| GET | /api/requirement-analysis/generation-config/ | 生成配置 |
| GET | /api/requirement-analysis/config/check/ | 配置状态检查 |

---

### 4.10 测试用例评审模块 (reviews)

#### 4.10.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 评审创建 | P1 | 创建评审计划 |
| 评审分配 | P1 | 指派评审人 |
| 用例评审 | P1 | 逐条评审用例 |
| 评审意见 | P1 | 添加评审意见 |
| 评审模板 | P2 | 评审模板管理 |
| 评审统计 | P2 | 评审进度统计 |

#### 4.10.2 数据模型

**TestCaseReview (评审)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 评审ID |
| title | VARCHAR(500) | NOT NULL | 评审标题 |
| description | TEXT | - | 评审描述 |
| status | ENUM | DEFAULT 'pending' | 评审状态 |
| priority | ENUM | DEFAULT 'medium' | 优先级 |
| deadline | DATETIME | - | 截止日期 |
| template_id | BIGINT | FK | 使用的模板 |
| creator_id | BIGINT | FK | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |
| completed_at | DATETIME | - | 完成时间 |
| projects | M2M | - | 关联项目 |
| testcases | M2M | - | 评审用例 |
| reviewers | M2M | through ReviewAssignment | 评审人员 |

**ReviewAssignment (评审分配)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 分配ID |
| review_id | BIGINT | FK | 评审ID |
| reviewer_id | BIGINT | FK | 评审人ID |
| status | ENUM | DEFAULT 'pending' | 评审状态 |
| comment | TEXT | - | 评审意见 |
| checklist_results | JSON | - | 检查清单结果 |
| reviewed_at | DATETIME | - | 评审时间 |
| assigned_at | DATETIME | NOT NULL | 分配时间 |

**TestCaseReviewComment (评审意见)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 意见ID |
| review_id | BIGINT | FK | 评审ID |
| testcase_id | BIGINT | FK | 相关用例 |
| author_id | BIGINT | FK | 评论者 |
| comment_type | ENUM | DEFAULT 'general' | 意见类型 |
| content | TEXT | NOT NULL | 意见内容 |
| step_number | INT | - | 步骤序号 |
| is_resolved | BOOLEAN | DEFAULT FALSE | 是否已解决 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**ReviewTemplate (评审模板)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 模板ID |
| name | VARCHAR(200) | NOT NULL | 模板名称 |
| description | TEXT | - | 模板描述 |
| checklist | JSON | - | 检查清单 |
| default_reviewers | M2M | through review_templates_default_reviewers | 默认评审人 |
| is_active | BOOLEAN | DEFAULT TRUE | 是否启用 |
| creator_id | BIGINT | FK | 创建人 |
| projects | M2M | through review_templates_project | 关联项目 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

---

#### 4.10.3 API 接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | /api/reviews/reviews/ | 评审列表 |
| POST | /api/reviews/reviews/ | 创建评审 |
| GET | /api/reviews/reviews/{id}/ | 评审详情 |
| PUT | /api/reviews/reviews/{id}/ | 更新评审 |
| DELETE | /api/reviews/reviews/{id}/ | 删除评审 |
| GET | /api/reviews/review-comments/ | 评审意见列表 |
| POST | /api/reviews/review-comments/ | 添加评审意见 |
| GET | /api/reviews/review-templates/ | 评审模板列表 |
| POST | /api/reviews/review-templates/ | 创建评审模板 |
| GET | /api/reviews/review-templates/{id}/ | 评审模板详情 |
| PUT | /api/reviews/review-templates/{id}/ | 更新评审模板 |
| DELETE | /api/reviews/review-templates/{id}/ | 删除评审模板 |

---

### 4.11 统一通知模块 (core)

#### 4.11.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| Webhook配置 | P1 | 飞书/企微/钉钉机器人配置 |
| 多渠道通知 | P1 | 支持多种通知渠道 |
| 默认配置 | P1 | 设置默认通知配置 |
| 配置测试 | P1 | Webhook连接测试 |

#### 4.11.2 数据模型

**UnifiedNotificationConfig (统一通知配置)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 配置ID |
| name | VARCHAR(100) | NOT NULL | 配置名称 |
| config_type | ENUM | DEFAULT 'webhook_feishu' | 配置类型 |
| webhook_bots | JSON | - | Webhook机器人配置 |
| is_default | BOOLEAN | DEFAULT FALSE | 是否默认配置 |
| is_active | BOOLEAN | DEFAULT TRUE | 是否启用 |
| created_by_id | BIGINT | FK | 创建人 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

---

### 4.12 AI 助手模块 (assistant)

#### 4.12.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| Dify配置 | P2 | Dify API配置管理 |
| 会话管理 | P2 | 创建/查看/删除对话会话 |
| 聊天功能 | P2 | 与AI助手对话 |

#### 4.12.2 数据模型

**DifyConfig (Dify配置)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 配置ID |
| api_url | VARCHAR(500) | NOT NULL | API URL |
| api_key | VARCHAR(500) | NOT NULL | API密钥 |
| is_active | BOOLEAN | DEFAULT TRUE | 是否启用 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**AssistantSession (智能助手会话)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 会话ID |
| user_id | BIGINT | FK | 用户ID |
| session_id | VARCHAR(200) | NOT NULL | 会话ID |
| conversation_id | VARCHAR(200) | - | Dify对话ID |
| title | VARCHAR(500) | - | 会话标题 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**ChatMessage (聊天消息)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 消息ID |
| session_id | BIGINT | FK | 会话ID |
| role | ENUM | NOT NULL | 角色 (user/assistant) |
| content | TEXT | NOT NULL | 消息内容 |
| conversation_id | VARCHAR(200) | - | Dify对话ID |
| message_id | VARCHAR(200) | - | Dify消息ID |
| created_at | DATETIME | NOT NULL | 创建时间 |

**AssistantMessage (智能助手消息)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 消息ID |
| session_id | BIGINT | FK | 会话ID |
| message_type | ENUM | NOT NULL | 消息类型 |
| content | TEXT | NOT NULL | 消息内容 |
| created_at | DATETIME | NOT NULL | 创建时间 |

---

### 4.13 测试报告模块 (reports)

#### 4.13.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 报告生成 | P2 | 测试报告生成 |
| 报告查看 | P2 | 查看历史报告 |
| 报告导出 | P2 | 导出PDF/HTML格式 |
| 报告模板 | P2 | 自定义报告模板 |

#### 4.13.2 数据模型

**TestReport (测试报告)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 报告ID |
| project_id | BIGINT | FK | 项目ID |
| name | VARCHAR(200) | NOT NULL | 报告名称 |
| report_type | ENUM | DEFAULT 'execution' | 报告类型 |
| execution_id | BIGINT | FK | 关联执行 |
| summary | JSON | - | 报告摘要 |
| content | JSON | - | 报告内容 |
| generated_by_id | BIGINT | FK | 生成者 |
| created_at | DATETIME | NOT NULL | 创建时间 |

**ReportTemplate (报告模板)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 模板ID |
| name | VARCHAR(200) | NOT NULL | 模板名称 |
| description | TEXT | - | 模板描述 |
| template_config | JSON | - | 模板配置 |
| is_default | BOOLEAN | DEFAULT FALSE | 是否默认 |
| created_by_id | BIGINT | FK | 创建者 |
| created_at | DATETIME | NOT NULL | 创建时间 |

---

### 4.14 版本管理模块 (versions)

#### 4.14.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 版本创建 | P2 | 创建新版本/Release |
| 版本列表 | P2 | 查看版本列表 |
| 版本详情 | P2 | 查看版本详情 |
| 基线版本 | P2 | 标记基线版本 |

#### 4.14.2 数据模型

**Version (版本)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 版本ID |
| name | VARCHAR(100) | NOT NULL | 版本名称 |
| description | TEXT | - | 版本描述 |
| is_baseline | BOOLEAN | DEFAULT FALSE | 是否为基线版本 |
| created_by_id | BIGINT | FK | 创建者 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

---

### 4.15 测试数据工厂模块 (data-factory)

#### 4.15.1 功能列表

| 功能点 | 优先级 | 描述 |
|--------|:------:|------|
| 数据生成 | P2 | 生成测试数据 |
| JSON工具 | P2 | JSON格式化/验证 |
| 字符工具 | P2 | 字符串处理 |
| 编码工具 | P2 | 编码/解码工具 |
| 随机工具 | P2 | 随机数据生成 |
| 加密工具 | P2 | 加密解密工具 |

#### 4.15.2 数据模型

**DataFactoryRecord (数据工厂记录)**

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 记录ID |
| user_id | BIGINT | FK | 用户ID |
| tool_name | VARCHAR(100) | NOT NULL | 工具名称 |
| tool_category | ENUM | NOT NULL | 工具分类 |
| tool_scenario | ENUM | NOT NULL | 使用场景 |
| input_data | JSON | - | 输入数据 |
| output_data | JSON | - | 输出数据 |
| is_saved | BOOLEAN | DEFAULT TRUE | 是否保存 |
| tags | JSON | - | 标签 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

---

## 五、非功能需求

### 5.1 性能需求

| 指标 | 要求 |
|------|------|
| API 响应时间 | P95 < 200ms |
| 并发用户数 | 支持 500+ 并发 |
| 数据库查询 | 单表查询 < 50ms |
| 文件上传 | 支持最大 100MB |
| 支持数据量 | 单项目 10,000+ 用例 |

### 5.2 安全需求

| 需求 | 说明 |
|------|------|
| 认证方式 | JWT 双 Token (Access + Refresh) |
| 密码加密 | BCrypt 加密 |
| API 安全 | HTTPS + Token 验证 |
| SQL 注入防护 | MyBatis-Plus 参数绑定 |
| XSS 防护 | 输入校验 + 输出转义 |
| 敏感数据 | API Key 等加密存储 |

### 5.3 可用性需求

| 指标 | 要求 |
|------|------|
| 系统可用性 | 99.9% |
| 备份策略 | 每日增量 + 每周全量 |
| 恢复时间 | < 1小时 |

### 5.4 兼容性需求

| 项目 | 要求 |
|------|------|
| 浏览器支持 | Chrome/Firefox/Safari/Edge 最新版 |
| 操作系统 | Windows/Linux/macOS |
| 移动端 | 响应式设计 |

---

## 六、技术实现要求

### 6.1 后端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Java | 17+ | 编程语言 |
| Spring Boot | 3.2+ | Web 框架 |
| MyBatis-Plus | 3.5+ | ORM 框架 |
| Spring Security | 6+ | 安全框架 |
| JJWT | 0.12+ | JWT 库 |
| Redis | 7+ | 缓存/会话 |
| XXL-JOB | 2.4+ | 任务调度 |
| SpringDoc | 2.4+ | API 文档 |
| MySQL | 8.0+ | 数据库 |

### 6.2 项目结构

```
testhub-java/
├── src/main/java/com/testhub/
│   ├── TestHubApplication.java
│   ├── config/                 # 配置类
│   ├── common/                 # 公共模块
│   │   ├── result/            # 统一响应
│   │   ├── exception/         # 异常处理
│   │   ├── security/         # 安全工具
│   │   └── utils/             # 工具类
│   └── module/                 # 业务模块
│       ├── users/
│       ├── projects/
│       ├── testcases/
│       ├── executions/
│       ├── api-testing/
│       ├── ui-automation/
│       ├── app-automation/
│       ├── requirement-analysis/
│       ├── reviews/
│       └── configuration/
└── src/main/resources/
    ├── application.yml
    └── mapper/
```

### 6.3 数据库规范

- 表名：`模块_实体`（如 `users_user`）
- 字段名：`snake_case`（如 `created_at`）
- 索引命名：`idx_字段名`
- 外键命名：`fk_表名_字段名`
- 主键：`BIGINT AUTO_INCREMENT`

---

## 七、接口规范

### 7.1 统一响应格式

```json
{
    "code": 200,
    "message": "操作成功",
    "data": { ... },
    "timestamp": 1712918400000
}
```

### 7.2 分页响应格式

```json
{
    "code": 200,
    "message": "操作成功",
    "data": {
        "total": 100,
        "current": 1,
        "size": 10,
        "records": [ ... ]
    },
    "timestamp": 1712918400000
}
```

### 7.3 错误码规范

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

---

## 八、版本规划

| 版本 | 阶段 | 功能范围 | 目标时间 |
|------|------|----------|----------|
| v1.0 | 核心功能 | 用户、项目、用例、套件、执行、API测试、UI自动化、通知 | T+12周 |
| v1.1 | 增强功能 | AI需求分析、评审、APP自动化、版本管理 | T+16周 |
| v1.2 | 高级功能 | AI助手、数据工厂、高级报表 | T+20周 |

---

## 九、附录

### 9.1 术语表

| 术语 | 说明 |
|------|------|
| TestHub | 智能测试管理平台 |
| Page Object | 页面对象模式 |
| CRON | 定时任务表达式 |
| JWT | JSON Web Token |
| Allure | 测试报告框架 |

### 9.2 参考文档

- Spring Boot 官方文档
- MyBatis-Plus 官方文档
- Spring Security 参考指南
- JWT 标准规范 (RFC 7519)
