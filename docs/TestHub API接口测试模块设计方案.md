# TestHub API 接口测试模块设计方案

## 1. 模块概述

API 接口测试模块是 TestHub 智能测试管理平台的核心功能之一，提供完整的 API 接口管理与自动化测试能力。该模块支持 HTTP/HTTPS 协议和 WebSocket 协议，可视化配置请求参数、认证信息、断言规则，支持定时任务执行和多渠道通知。

### 1.1 设计目标

- **接口统一管理**：集中管理项目中的所有 API 接口，支持树形结构组织和搜索
- **便捷的调试能力**：实时发送请求、查看响应、自动解析 JSON/XML
- **自动化测试**：通过测试套件编排多个接口的执行顺序，支持断言验证
- **定时执行**：支持 Cron 表达式、间隔执行、单次执行等多种定时策略
- **多维度报告**：生成详细的测试报告，支持 Allure 报告集成
- **智能通知**：执行完成后通过邮件、Webhook 机器人通知相关人员
- **操作审计**：记录所有操作日志，支持追溯查询

### 1.2 功能架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        API 接口测试模块                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   仪表盘     │  │   项目管理   │  │   接口管理   │          │
│  │  Dashboard   │  │   Projects   │  │  Interfaces  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  自动化测试  │  │  请求历史    │  │  环境管理   │          │
│  │  Automation  │  │   History   │  │Environment  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  定时任务    │  │   测试报告   │  │  通知配置   │          │
│  │   Tasks     │  │   Reports   │  │Notification │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 技术选型

| 技术项 | 选型 | 说明 |
|-------|------|------|
| 后端框架 | Django 4.2 + Django REST Framework | 成熟稳定的 Python Web 框架 |
| 数据库 | MySQL 8.0+ | 支持 utf8mb4 字符集 |
| HTTP 客户端 | requests | Python 最流行的 HTTP 库 |
| WebSocket | django-channels + websockets | 支持 WebSocket 测试 |
| 定时任务 | APScheduler (内嵌) | 轻量级定时任务调度 |
| 报告生成 | Allure | 业界标准的测试报告框架 |
| 前端框架 | Vue 3 + Element Plus | 现代化组件库 |
| 状态管理 | Pinia | Vue 3 官方推荐状态管理 |

---

## 2. 数据模型设计

### 2.1 模型关系图

```
ApiProject (API项目)
    │
    ├── ApiCollection (API集合) ────< ApiCollection (子集合，树形结构)
    │         │
    │         └───< ApiRequest (API请求)
    │
    ├── Environment (环境变量) ──── SCOPE: GLOBAL/LOCAL
    │
    ├── TestSuite (测试套件)
    │         │
    │         └───< TestSuiteRequest (套件请求关联)
    │
    ├── TestExecution (测试执行记录)
    │
    └── ScheduledTask (定时任务)
              │
              ├───< TaskExecutionLog (任务执行日志)
              │
              └───< TaskNotificationSetting (通知设置)

RequestHistory (请求历史)
    │
    └───< ApiRequest (FK)

NotificationLog (通知日志)
    │
    └───< ScheduledTask (FK)

OperationLog (操作日志)

AIServiceConfig (AI服务配置)
```

### 2.2 模型详细定义

#### 2.2.1 ApiProject (API项目)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 项目ID |
| name | CharField(200) | 必填 | 项目名称 |
| description | TextField | 可选 | 项目描述 |
| project_type | CharField(20) | 必填 | 项目类型 |
| status | CharField(20) | 必填 | 项目状态 |
| start_date | DateField | 可为空 | 开始日期 |
| end_date | DateField | 可为空 | 结束日期 |
| owner | ForeignKey(User) | 必填 | 负责人 |
| members | ManyToManyField(User) | 可选 | 团队成员 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**project_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| HTTP | HTTP | HTTP/HTTPS 接口项目 |
| WEBSOCKET | WebSocket | WebSocket 接口项目 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| NOT_STARTED | 未开始 | 项目尚未开始 |
| IN_PROGRESS | 进行中 | 项目正在执行 |
| COMPLETED | 已结束 | 项目已完成 |

#### 2.2.2 ApiCollection (API集合)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 集合ID |
| name | CharField(200) | 必填 | 集合名称 |
| description | TextField | 可选 | 集合描述 |
| order | IntegerField | 默认0 | 排序序号 |
| project | ForeignKey(ApiProject) | 必填 | 所属项目 |
| parent | ForeignKey(self) | 可为空 | 父级集合（支持树形结构） |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

#### 2.2.3 ApiRequest (API请求)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 请求ID |
| collection | ForeignKey(ApiCollection) | 可为空 | 所属集合 |
| name | CharField(200) | 必填 | 请求名称 |
| description | TextField | 可选 | 请求描述 |
| request_type | CharField(20) | 默认HTTP | 请求类型 |
| method | CharField(10) | 默认GET | HTTP 方法 |
| url | TextField | 必填 | 请求 URL |
| headers | JSONField | 默认{} | 请求头 |
| params | JSONField | 默认{} | URL 参数 |
| body | JSONField | 默认{} | 请求体 |
| auth | JSONField | 默认{} | 认证信息 |
| pre_request_script | TextField | 可选 | 请求前脚本 |
| post_request_script | TextField | 可选 | 请求后脚本 |
| assertions | JSONField | 默认[] | 断言规则 |
| order | IntegerField | 默认0 | 排序序号 |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**request_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| HTTP | HTTP | HTTP/HTTPS 请求 |
| WEBSOCKET | WebSocket | WebSocket 连接 |

**method 枚举**：

| 值 | 说明 |
|----|------|
| GET | GET 请求 |
| POST | POST 请求 |
| PUT | PUT 请求 |
| DELETE | DELETE 请求 |
| PATCH | PATCH 请求 |
| HEAD | HEAD 请求 |
| OPTIONS | OPTIONS 请求 |

#### 2.2.4 Environment (环境变量)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 环境ID |
| name | CharField(200) | 必填 | 环境名称 |
| scope | CharField(10) | 必填 | 作用域 |
| variables | JSONField | 默认{} | 环境变量 |
| is_active | BooleanField | 默认False | 是否激活 |
| project | ForeignKey(ApiProject) | 可为空 | 关联项目（LOCAL 必填） |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**scope 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| GLOBAL | 全局环境变量 | 所有项目可用 |
| LOCAL | 局部环境变量 | 仅指定项目可用 |

**variables JSON 结构示例**：

```json
{
  "base_url": {
    "initialValue": "https://api.example.com",
    "currentValue": "https://api.example.com"
  },
  "token": {
    "initialValue": "",
    "currentValue": "abc123xyz"
  }
}
```

#### 2.2.5 RequestHistory (请求历史)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 历史ID |
| request | ForeignKey(ApiRequest) | 必填 | 关联请求 |
| environment | ForeignKey(Environment) | 可为空 | 使用环境 |
| request_data | JSONField | 必填 | 请求数据快照 |
| response_data | JSONField | 可为空 | 响应数据快照 |
| status_code | IntegerField | 可为空 | HTTP 状态码 |
| response_time | FloatField | 可为空 | 响应时间（毫秒） |
| error_message | TextField | 可选 | 错误信息 |
| assertions_results | JSONField | 可为空 | 断言结果 |
| executed_by | ForeignKey(User) | 必填 | 执行者 |
| executed_at | DateTimeField | 自动 | 执行时间 |

#### 2.2.6 TestSuite (测试套件)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 套件ID |
| project | ForeignKey(ApiProject) | 必填 | 所属项目 |
| name | CharField(200) | 必填 | 套件名称 |
| description | TextField | 可选 | 套件描述 |
| environment | ForeignKey(Environment) | 可为空 | 执行环境 |
| requests | ManyToManyField(ApiRequest) | - | 包含请求（through） |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

#### 2.2.7 TestSuiteRequest (套件请求关联)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 关联ID |
| test_suite | ForeignKey(TestSuite) | 必填 | 测试套件 |
| request | ForeignKey(ApiRequest) | 必填 | API请求 |
| order | IntegerField | 默认0 | 执行顺序 |
| assertions | JSONField | 默认[] | 断言规则（覆盖请求级断言） |
| enabled | BooleanField | 默认True | 是否启用 |

**唯一约束**：`[test_suite, request]`

#### 2.2.8 TestExecution (测试执行记录)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 执行ID |
| test_suite | ForeignKey(TestSuite) | 必填 | 测试套件 |
| status | CharField(20) | 必填 | 执行状态 |
| start_time | DateTimeField | 必填 | 开始时间 |
| end_time | DateTimeField | 可为空 | 结束时间 |
| total_requests | IntegerField | 默认0 | 总请求数 |
| passed_requests | IntegerField | 默认0 | 通过请求数 |
| failed_requests | IntegerField | 默认0 | 失败请求数 |
| results | JSONField | 可为空 | 详细结果 |
| executed_by | ForeignKey(User) | 必填 | 执行者 |
| created_at | DateTimeField | 自动 | 创建时间 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| PENDING | 待执行 | 等待执行 |
| RUNNING | 执行中 | 正在执行 |
| COMPLETED | 已完成 | 全部通过 |
| FAILED | 失败 | 有用例失败 |

#### 2.2.9 ScheduledTask (定时任务)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 任务ID |
| name | CharField(200) | 必填 | 任务名称 |
| description | TextField | 可选 | 任务描述 |
| task_type | CharField(20) | 必填 | 任务类型 |
| trigger_type | CharField(20) | 必填 | 触发器类型 |
| cron_expression | CharField(100) | 可为空 | Cron 表达式 |
| interval_seconds | IntegerField | 可为空 | 间隔秒数 |
| execute_at | DateTimeField | 可为空 | 单次执行时间 |
| test_suite | ForeignKey(TestSuite) | 可为空 | 关联测试套件 |
| api_request | ForeignKey(ApiRequest) | 可为空 | 关联API请求 |
| environment | ForeignKey(Environment) | 可为空 | 执行环境 |
| status | CharField(20) | 默认PAUSED | 任务状态 |
| last_run_time | DateTimeField | 可为空 | 上次执行时间 |
| next_run_time | DateTimeField | 可为空 | 下次执行时间 |
| total_runs | IntegerField | 默认0 | 总执行次数 |
| successful_runs | IntegerField | 默认0 | 成功次数 |
| failed_runs | IntegerField | 默认0 | 失败次数 |
| last_result | JSONField | 可为空 | 最近执行结果 |
| error_message | TextField | 可选 | 错误信息 |
| notify_on_success | BooleanField | 默认False | 成功时通知 |
| notify_on_failure | BooleanField | 默认False | 失败时通知 |
| notify_emails | TextField | 可选 | 通知邮箱列表 |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**task_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| TEST_SUITE | 测试套件 | 执行测试套件 |
| API_REQUEST | API请求 | 执行单个API请求 |

**trigger_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| CRON | Cron表达式 | 按 Cron 表达式定时执行 |
| INTERVAL | 间隔执行 | 按固定间隔执行 |
| ONCE | 单次执行 | 在指定时间执行一次 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| PAUSED | 已暂停 | 任务暂停执行 |
| ACTIVE | 运行中 | 任务正在执行 |
| COMPLETED | 已完成 | 单次任务执行完毕 |

#### 2.2.10 TaskExecutionLog (任务执行日志)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 日志ID |
| task | ForeignKey(ScheduledTask) | 必填 | 关联任务 |
| status | CharField(20) | 必填 | 执行状态 |
| start_time | DateTimeField | 必填 | 开始时间 |
| end_time | DateTimeField | 可为空 | 结束时间 |
| duration | FloatField | 可为空 | 执行时长（秒） |
| total_requests | IntegerField | 默认0 | 总请求数 |
| passed_requests | IntegerField | 默认0 | 通过数 |
| failed_requests | IntegerField | 默认0 | 失败数 |
| result | JSONField | 可为空 | 执行结果详情 |
| error_message | TextField | 可选 | 错误信息 |
| executed_by | ForeignKey(User) | 可为空 | 执行者 |
| created_at | DateTimeField | 自动 | 创建时间 |

#### 2.2.11 NotificationLog (通知日志)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 日志ID |
| task | ForeignKey(ScheduledTask) | 可为空 | 关联任务 |
| task_name | CharField(200) | 必填 | 任务名称快照 |
| task_type | CharField(20) | 可为空 | 任务类型快照 |
| notification_type | CharField(50) | 必填 | 通知类型 |
| sender_name | CharField(100) | 必填 | 发件人姓名 |
| sender_email | EmailField | 必填 | 发件人邮箱 |
| recipient_info | JSONField | 必填 | 收件人信息 |
| webhook_bot_info | JSONField | 可为空 | Webhook机器人信息 |
| notification_content | TextField | 必填 | 通知内容 |
| status | CharField(20) | 默认pending | 发送状态 |
| error_message | TextField | 可选 | 错误信息 |
| response_info | JSONField | 可为空 | 响应信息 |
| created_at | DateTimeField | 自动 | 创建时间 |
| sent_at | DateTimeField | 可为空 | 发送时间 |
| retry_count | IntegerField | 默认0 | 重试次数 |
| is_retried | BooleanField | 默认False | 是否已重试 |

**notification_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| email | 邮箱通知 | 通过邮件发送 |
| webhook | Webhook机器人 | 通过 Webhook 发送 |
| both | 两者都发送 | 同时使用邮件和 Webhook |
| system_alert | 系统警告 | 系统自动发送的警告 |
| manual | 手动通知 | 用户手动触发的通知 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| pending | 待发送 | 等待发送 |
| sending | 发送中 | 正在发送 |
| success | 发送成功 | 发送成功 |
| failed | 发送失败 | 发送失败 |
| cancelled | 已取消 | 已取消发送 |

#### 2.2.12 TaskNotificationSetting (任务通知设置)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 设置ID |
| task | ForeignKey(ScheduledTask) | 必填 | 关联任务 |
| notification_type | CharField(20) | 默认both | 通知类型 |
| notification_config | ForeignKey | 可为空 | 通知配置 |
| is_enabled | BooleanField | 默认False | 是否启用通知 |
| notify_on_success | BooleanField | 默认True | 成功时通知 |
| notify_on_failure | BooleanField | 默认True | 失败时通知 |
| notify_on_timeout | BooleanField | 默认False | 超时时通知 |
| notify_on_error | BooleanField | 默认True | 错误时通知 |
| custom_webhook_bots | JSONField | 可为空 | 自定义Webhook机器人 |
| custom_recipients | ManyToManyField(User) | 可选 | 自定义收件人 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**唯一约束**：`[task]`

#### 2.2.13 OperationLog (操作日志)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 日志ID |
| operation_type | CharField(20) | 必填 | 操作类型 |
| resource_type | CharField(20) | 必填 | 资源类型 |
| resource_id | IntegerField | 必填 | 资源ID |
| resource_name | CharField(200) | 必填 | 资源名称 |
| description | TextField | 可选 | 操作描述 |
| user | ForeignKey(User) | 可为空 | 操作用户 |
| created_at | DateTimeField | 自动 | 创建时间 |

**operation_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| create | 新增 | 创建资源 |
| edit | 编辑 | 修改资源 |
| delete | 删除 | 删除资源 |
| execute | 执行 | 执行接口 |
| run | 运行 | 运行测试 |
| save | 保存 | 保存配置 |

**resource_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| project | 项目 | API项目 |
| collection | 集合 | API集合 |
| request | 请求 | API请求 |
| suite | 测试套件 | 测试套件 |
| environment | 环境 | 环境变量 |
| task | 定时任务 | 定时任务 |
| execution | 执行记录 | 测试执行记录 |

#### 2.2.14 AIServiceConfig (AI服务配置)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| name | CharField(100) | 必填 | 配置名称 |
| service_type | CharField(20) | 必填 | 服务类型 |
| role | CharField(50) | 必填 | 角色标识 |
| api_key | CharField(500) | 必填 | API密钥 |
| base_url | URLField | 可为空 | API Base URL |
| model_name | CharField(100) | 必填 | 模型名称 |
| is_active | BooleanField | 默认True | 是否启用 |
| is_default | BooleanField | 默认False | 是否默认 |
| temperature | FloatField | 默认0.7 | 温度参数 |
| max_tokens | IntegerField | 默认2000 | 最大Token数 |
| timeout | IntegerField | 默认60 | 超时秒数 |
| extra_config | JSONField | 可为空 | 额外配置 |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**service_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| openai | OpenAI | OpenAI 官方 API |
| azure | Azure OpenAI | Azure OpenAI Service |
| deepseek | DeepSeek | DeepSeek AI |
| qwen | 通义千问 | 阿里云通义千问 |
| siliconflow | 硅基流动 | SiliconFlow API |
| custom | 自定义 | 自定义 API 服务 |

**role 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| testcase_writer | 用例编写 | AI 辅助编写测试用例 |
| browser_use_text | 浏览器文本 | 浏览器自动化文本交互 |
| browser_use_vision | 浏览器视觉 | 浏览器自动化视觉识别 |
| api_testing | API测试 | API 测试辅助 |

---

## 3. API 接口设计

### 3.1 路由总览

所有 API 接口前缀：`/api/api-testing/`

| 路由前缀 | ViewSet | 说明 |
|---------|---------|------|
| `dashboard/` | ApiDashboardViewSet | 仪表盘 |
| `projects/` | ApiProjectViewSet | 项目管理 |
| `collections/` | ApiCollectionViewSet | 集合管理 |
| `requests/` | ApiRequestViewSet | 接口管理 |
| `environments/` | EnvironmentViewSet | 环境管理 |
| `histories/` | RequestHistoryViewSet | 请求历史 |
| `test-suites/` | TestSuiteViewSet | 测试套件 |
| `test-suite-requests/` | TestSuiteRequestViewSet | 套件请求 |
| `test-executions/` | TestExecutionViewSet | 执行记录 |
| `users/` | UserViewSet | 用户管理 |
| `scheduled-tasks/` | ScheduledTaskViewSet | 定时任务 |
| `task-execution-logs/` | TaskExecutionLogViewSet | 执行日志 |
| `notification-logs/` | NotificationLogViewSet | 通知日志 |
| `task-notification-settings/` | TaskNotificationSettingViewSet | 通知设置 |
| `operation-logs/` | OperationLogViewSet | 操作日志 |
| `ai-service-configs/` | AIServiceConfigViewSet | AI配置 |

### 3.2 项目管理 API (ApiProjectViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/api-testing/projects/` | 获取项目列表 | `project_type`, `status`, `owner`, 搜索, 分页 |
| POST | `/api/api-testing/projects/` | 创建项目 | `member_ids` |
| GET | `/api/api-testing/projects/{id}/` | 获取项目详情 | - |
| PUT | `/api/api-testing/projects/{id}/` | 更新项目 | - |
| DELETE | `/api/api-testing/projects/{id}/` | 删除项目 | - |
| POST | `/api/api-testing/projects/create-sample/` | 创建示例项目 | - |

**创建项目请求参数**：

```json
{
    "name": "电商API项目",
    "description": "电商系统的API接口测试项目",
    "project_type": "HTTP",
    "status": "IN_PROGRESS",
    "start_date": "2026-04-01",
    "end_date": "2026-06-30",
    "member_ids": [2, 3, 4]
}
```

### 3.3 集合管理 API (ApiCollectionViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/api-testing/collections/` | 获取集合列表 | `project`, `parent` |
| POST | `/api/api-testing/collections/` | 创建集合 | - |
| GET | `/api/api-testing/collections/{id}/` | 获取集合详情 | - |
| PUT | `/api/api-testing/collections/{id}/` | 更新集合 | - |
| DELETE | `/api/api-testing/collections/{id}/` | 删除集合 | - |

### 3.4 接口管理 API (ApiRequestViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/api-testing/requests/` | 获取接口列表 | `collection`, `method`, `request_type`, `project`, 搜索 |
| POST | `/api/api-testing/requests/` | 创建接口 | - |
| GET | `/api/api-testing/requests/{id}/` | 获取接口详情 | - |
| PUT | `/api/api-testing/requests/{id}/` | 更新接口 | - |
| DELETE | `/api/api-testing/requests/{id}/` | 删除接口 | - |
| POST | `/api/api-testing/requests/{id}/execute/` | 执行接口 | 环境变量覆盖等 |

**执行接口请求参数 (POST /api/api-testing/requests/{id}/execute/)**：

```json
{
    "environment_id": 1,
    "params": {"page": "2", "limit": "20"},
    "headers": {"Authorization": "Bearer newtoken"},
    "body": {"data": {"username": "test"}},
    "method": "POST",
    "url": "https://new-url.com/api",
    "assertions": [
        {"type": "status_code", "expected": 200},
        {"type": "contains", "expected": "success"},
        {"type": "json_path", "json_path": "$.data.token", "expected": "abc123"}
    ]
}
```

**执行接口响应**：

```json
{
    "id": 1,
    "request": {...},
    "environment": {...},
    "request_data": {...},
    "response_data": {
        "headers": {...},
        "body": "...",
        "json": {...}
    },
    "status_code": 200,
    "response_time": 156.32,
    "executed_by": {...},
    "executed_at": "2026-04-10T10:30:00Z",
    "assertions_results": [
        {"name": "状态码验证", "type": "status_code", "passed": true, "expected": 200, "actual": 200},
        {"name": "包含验证", "type": "contains", "passed": true, "expected": "success", "actual": "..."}
    ]
}
```

### 3.5 环境管理 API (EnvironmentViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/api-testing/environments/` | 获取环境列表 | `scope`, `project` |
| POST | `/api/api-testing/environments/` | 创建环境 | - |
| GET | `/api/api-testing/environments/{id}/` | 获取环境详情 | - |
| PUT | `/api/api-testing/environments/{id}/` | 更新环境 | - |
| DELETE | `/api/api-testing/environments/{id}/` | 删除环境 | - |
| POST | `/api/api-testing/environments/{id}/activate/` | 激活环境 | - |

**创建环境请求参数**：

```json
{
    "name": "测试环境",
    "scope": "LOCAL",
    "project": 1,
    "variables": {
        "base_url": {"initialValue": "https://test.api.com", "currentValue": "https://test.api.com"},
        "token": {"initialValue": "", "currentValue": "test_token_123"}
    },
    "is_active": true
}
```

### 3.6 请求历史 API (RequestHistoryViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/api-testing/histories/` | 获取历史列表 | `request`, 分页 |
| GET | `/api/api-testing/histories/{id}/` | 获取历史详情 | - |
| DELETE | `/api/api-testing/histories/{id}/` | 删除历史 | - |
| POST | `/api/api-testing/histories/batch-delete/` | 批量删除 | `ids` |

### 3.7 测试套件 API (TestSuiteViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/api-testing/test-suites/` | 获取套件列表 | `project` |
| POST | `/api/api-testing/test-suites/` | 创建套件 | - |
| GET | `/api/api-testing/test-suites/{id}/` | 获取套件详情 | - |
| PUT | `/api/api-testing/test-suites/{id}/` | 更新套件 | - |
| DELETE | `/api/api-testing/test-suites/{id}/` | 删除套件 | - |
| POST | `/api/api-testing/test-suites/{id}/execute/` | 执行套件 | `environment_id` |
| POST | `/api/api-testing/test-suites/{id}/add-requests/` | 添加请求 | `request_ids` |

### 3.8 定时任务 API (ScheduledTaskViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/api-testing/scheduled-tasks/` | 获取任务列表 | `task_type`, `trigger_type`, `status` |
| POST | `/api/api-testing/scheduled-tasks/` | 创建任务 | - |
| GET | `/api/api-testing/scheduled-tasks/{id}/` | 获取任务详情 | - |
| PUT | `/api/api-testing/scheduled-tasks/{id}/` | 更新任务 | - |
| DELETE | `/api/api-testing/scheduled-tasks/{id}/` | 删除任务 | - |
| POST | `/api/api-testing/scheduled-tasks/{id}/run_now/` | 立即执行 | - |
| POST | `/api/api-testing/scheduled-tasks/{id}/activate/` | 激活任务 | - |
| POST | `/api/api-testing/scheduled-tasks/{id}/pause/` | 暂停任务 | - |
| GET | `/api/api-testing/scheduled-tasks/{id}/execution_logs/` | 执行日志 | - |

**创建定时任务请求参数**：

```json
{
    "name": "每日回归测试",
    "description": "每天凌晨2点执行核心接口回归测试",
    "task_type": "TEST_SUITE",
    "trigger_type": "CRON",
    "cron_expression": "0 2 * * *",
    "test_suite": 1,
    "environment": 1,
    "notify_on_success": true,
    "notify_on_failure": true,
    "notify_emails": "team@example.com,qa@example.com"
}
```

### 3.9 仪表盘 API (ApiDashboardViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/api-testing/dashboard/stats/` | 获取统计数据 | - |
| GET | `/api/api-testing/dashboard/operation-logs/` | 操作日志 | 分页 |

**统计数据响应**：

```json
{
    "project_count": 5,
    "interface_count": 120,
    "test_suite_count": 15,
    "history_count": 3500
}
```

### 3.10 AI 服务配置 API (AIServiceConfigViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/api-testing/ai-service-configs/` | 获取配置列表 | `service_type`, `is_active` |
| POST | `/api/api-testing/ai-service-configs/` | 创建配置 | - |
| GET | `/api/api-testing/ai-service-configs/{id}/` | 获取配置详情 | - |
| PUT | `/api/api-testing/ai-service-configs/{id}/` | 更新配置 | - |
| DELETE | `/api/api-testing/ai-service-configs/{id}/` | 删除配置 | - |
| POST | `/api/api-testing/ai-service-configs/{id}/test_connection/` | 测试连接 | - |

---

## 4. 断言系统设计

### 4.1 支持的断言类型

| 类型 | 字段 | 说明 | 示例 |
|------|------|------|------|
| `status_code` | `expected` | HTTP 状态码 | `{"type": "status_code", "expected": 200}` |
| `response_time` | `expected` | 响应时间（毫秒） | `{"type": "response_time", "expected": 1000}` |
| `contains` | `expected` | 响应包含文本 | `{"type": "contains", "expected": "success"}` |
| `json_path` | `json_path`, `expected` | JSON 路径值验证 | `{"type": "json_path", "json_path": "$.data.token", "expected": "abc"}` |
| `header` | `header_name`, `expected_value` | 响应头验证 | `{"type": "header", "header_name": "Content-Type", "expected_value": "application/json"}` |
| `equals` | `expected` | 完全匹配 | `{"type": "equals", "expected": "exact response"}` |

### 4.2 断言结果数据结构

```json
{
    "name": "验证登录成功",
    "type": "json_path",
    "passed": true,
    "expected": "success",
    "actual": "success",
    "error": null
}
```

---

## 5. 变量系统设计

### 5.1 变量引用格式

```
{{variable_name}}
{{function_name(arg1, arg2)}}
```

### 5.2 支持的动态函数

| 函数 | 说明 | 示例 |
|------|------|------|
| `{{timestamp}}` | 当前时间戳（秒） | `{{timestamp}}` |
| `{{timestamp_ms}}` | 当前时间戳（毫秒） | `{{timestamp_ms}}` |
| `{{randomInt(min, max)}}` | 随机整数 | `{{randomInt(1, 100)}}` |
| `{{randomString(length)}}` | 随机字符串 | `{{randomString(16)}}` |
| `{{uuid}}` | UUID | `{{uuid}}` |
| `{{date(format)}}` | 日期格式化 | `{{date(yyyy-MM-dd)}}` |

### 5.3 变量替换流程

```
1. 前端发送请求数据（含 {{variable}} 占位符）
2. 后端获取环境变量
3. 执行环境变量替换：{{variable}} → actual_value
4. 执行动态函数替换：{{timestamp}} → 1712720000
5. 发送实际 HTTP 请求
```

---

## 6. 通知系统设计

### 6.1 通知渠道

| 渠道 | 配置项 | 说明 |
|------|-------|------|
| 邮箱 | `notify_emails` | SMTP 邮件发送 |
| Webhook | `notification_config` | HTTP POST 回调 |

### 6.2 Webhook 支持的平台

- 企业微信机器人
- 飞书机器人
- 钉钉机器人
- 自定义 Webhook URL

### 6.3 通知触发条件

| 条件 | 配置字段 | 说明 |
|------|---------|------|
| 执行成功 | `notify_on_success` | 所有用例通过时通知 |
| 执行失败 | `notify_on_failure` | 有用例失败时通知 |
| 执行超时 | `notify_on_timeout` | 执行超时时通知 |
| 执行错误 | `notify_on_error` | 执行异常时通知 |

---

## 7. 前端页面设计

### 7.1 页面路由

| 路由路径 | 页面组件 | 说明 |
|---------|---------|------|
| `/api-testing/dashboard` | Dashboard.vue | 仪表盘 |
| `/api-testing/projects` | ProjectManagement.vue | 项目管理 |
| `/api-testing/interfaces` | InterfaceManagement.vue | 接口管理 |
| `/api-testing/automation` | AutomationTesting.vue | 自动化测试 |
| `/api-testing/history` | RequestHistory.vue | 请求历史 |
| `/api-testing/environments` | EnvironmentManagement.vue | 环境管理 |
| `/api-testing/reports` | ReportView.vue | 测试报告 |
| `/api-testing/scheduled-tasks` | ScheduledTasks.vue | 定时任务 |
| `/api-testing/ai-service-config` | AIServiceConfig.vue | AI服务配置 |
| `/api-testing/notification-logs` | NotificationLogs.vue | 通知日志 |

### 7.2 接口管理页面布局 (InterfaceManagement.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [左侧栏: 240px]                    [右侧主内容区]                           │
│ ┌───────────────────────┐  ┌─────────────────────────────────────────────┐ │
│ │ [项目下拉选择器]       │  │ [GET ▼] [https://api.example.com/users]  │ │
│ ├───────────────────────┤  │                                     [Send] │ │
│ │ [搜索框] [+文件夹][+接口]│  ├─────────────────────────────────────────────┤ │
│ ├───────────────────────┤  │ [Params] [Headers] [Body] [Auth] [Scripts]│ │
│ │ 📁 用户管理           │  │ [Assertions]                               │ │
│ │   📄 用户注册         │  │                                             │ │
│ │   📄 用户登录         │  │ ┌─────────────────────────────────────┐   │ │
│ │ 📁 宠物管理           │  │ │ Key-Value 编辑器                      │   │ │
│ │   📄 获取宠物列表     │  │ │ ┌─────┬───────┬────┬──────────┐     │   │ │
│ │   📄 创建宠物         │  │ │ │  ☑  │  key  │ =  │  value   │     │   │ │
│ │   📁 订单管理         │  │ │ ├─────┼───────┼────┼──────────┤     │   │ │
│ │     📄 创建订单       │  │ │ │  ☑  │ page  │ =  │    1     │     │   │ │
│ │     📄 查询订单       │  │ │ │  ☑  │ limit │ =  │   20     │     │   │ │
│ └───────────────────────┘  │ └─────────────────────────────────────┘   │ │
│                            ├─────────────────────────────────────────────┤ │
│                            │                    [Send 按钮]               │
│                            ├─────────────────────────────────────────────┤ │
│                            │ 响应区域                                    │ │
│                            │ ┌─────────────────────────────────────┐   │ │
│                            │ │ Status: 200 OK    Time: 156ms      │   │ │
│                            │ │ 响应格式: JSON ▼                     │   │ │
│                            │ │                                     │   │ │
│                            │ │ {                                   │   │ │
│                            │ │   "code": 0,                       │   │ │
│                            │ │   "message": "success",             │   │ │
│                            │ │   "data": [...]                     │   │ │
│                            │ │ }                                   │   │ │
│                            │ │                                     │   │ │
│                            │ │ [断言结果 ✓ 3/3 通过]               │   │ │
│                            │ └─────────────────────────────────────┘   │ │
│                            └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.3 自动化测试页面布局 (AutomationTesting.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [自动化测试]                                              [创建测试套件]     │
├─────────────────────────────────────────────────────────────────────────────┤
│ 测试套件列表                        │ 套件详情                                │
│ ┌─────────────────────────────┐   │ ┌─────────────────────────────────────┐ │
│ │ ○ 核心接口回归测试          │   │ │ 套件名称: 核心接口回归测试           │ │
│ │   项目: 电商API项目         │   │ │ 执行环境: 测试环境 ▼                 │ │
│ │   接口数: 15  最后执行: ... │   │ │                                     │ │
│ │   [执行] [编辑] [删除]      │   │ │ 包含接口:                           │ │
│ ├─────────────────────────────┤   │ │ ┌───┬────────────────┬────────┐     │ │
│ │ ● 用户模块测试              │   │ │ ☑ │ GET 用户列表   │  ...   │     │ │
│ │   项目: 电商API项目         │   │ │ ☑ │ POST 用户注册   │  ...   │     │ │
│ │   接口数: 8   最后执行: ... │   │ │ ☑ │ POST 用户登录   │  ...   │     │ │
│ │   [执行] [编辑] [删除]      │   │ │ ☐ │ DELETE 用户    │  ...   │     │ │
│ └─────────────────────────────┘   │ └─────────────────────────────────────┘ │
│                                    │                                     │ │
│ 执行历史                          │                     [保存] [执行]  │ │
│ ┌─────────────────────────────┐   │ └─────────────────────────────────────┘ │
│ │ 2026-04-10 10:30  成功 12/15│   │                                         │
│ │ 2026-04-10 08:00  失败 2/15 │   │                                         │
│ │ 2026-04-09 22:00  成功 15/15│   │                                         │
│ └─────────────────────────────┘   │                                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.4 定时任务页面布局 (ScheduledTasks.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [定时任务]                              [创建定时任务]                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ 任务类型: [全部▼]  触发器: [全部▼]  状态: [全部▼]                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ 任务名称          │ 任务类型 │ 触发器      │ 状态   │ 下次执行      │ 操作  │
├─────────────────────────────────────────────────────────────────────────────┤
│ 每日回归测试      │ 测试套件 │ CRON 0 2 * │ [运行中]│ 2026-04-11 02:00│ ... │
│ 接口健康检查      │ API请求  │ INTERVAL 5m│ [已暂停]│      -         │ ... │
│ 每周全面测试      │ 测试套件 │ CRON 0 0 * │ [运行中]│ 2026-04-13 00:00│ ... │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ 创建定时任务对话框                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ 任务名称: [每日回归测试________________]                                   │
│ 任务类型: (●) 测试套件  ( ) API请求                                        │
│ 触发器:   (●) CRON表达式  ( ) 间隔执行  ( ) 单次执行                        │
│           [0 2 * * *____________________] 帮助                            │
│ 测试套件: [核心接口回归测试 ▼________________________]                       │
│ 执行环境: [测试环境 ▼________________]                                     │
│                                                                          │
│ 通知设置:                                                                  │
│ ☑ 成功时通知    ☑ 失败时通知                                              │
│ 通知邮箱: [team@example.com, qa@example.com_______]                        │
│                                                                          │
│                          [取消]  [创建]                                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. 权限控制设计

### 8.1 权限矩阵

| 资源 | 查看 | 创建 | 编辑 | 删除 | 执行 |
|------|------|------|------|------|------|
| 项目 | 项目成员 | 登录用户 | 项目负责人/成员 | 项目负责人 | - |
| 集合 | 项目成员 | 项目成员 | 项目成员 | 项目负责人 | - |
| 接口 | 项目成员 | 项目成员 | 项目成员 | 项目成员 | 项目成员 |
| 环境(GLOBAL) | 登录用户 | 登录用户 | 创建者 | 创建者 | - |
| 环境(LOCAL) | 项目成员 | 项目成员 | 项目成员 | 项目成员 | - |
| 测试套件 | 项目成员 | 项目成员 | 项目成员 | 项目负责人 | 项目成员 |
| 定时任务 | 创建者 | 登录用户 | 创建者 | 创建者 | 创建者 |

### 8.2 数据访问范围

所有列表查询自动过滤为当前用户有权限访问的资源：

```python
def get_queryset(self):
    user = self.request.user
    return ApiProject.objects.filter(
        models.Q(owner=user) | models.Q(members=user)
    ).distinct()
```

---

## 9. 数据库表结构

### 9.1 数据库表清单

| 表名 | 对应模型 | 说明 |
|------|---------|------|
| api_projects | ApiProject | API项目表 |
| api_collections | ApiCollection | API集合表 |
| api_requests | ApiRequest | API请求表 |
| api_environments | Environment | 环境变量表 |
| api_request_histories | RequestHistory | 请求历史表 |
| api_test_suites | TestSuite | 测试套件表 |
| api_test_suite_requests | TestSuiteRequest | 套件请求关联表 |
| api_test_executions | TestExecution | 测试执行记录表 |
| api_scheduled_tasks | ScheduledTask | 定时任务表 |
| api_task_execution_logs | TaskExecutionLog | 任务执行日志表 |
| api_notification_logs | NotificationLog | 通知日志表 |
| api_task_notification_settings | TaskNotificationSetting | 任务通知设置表 |
| api_operation_logs | OperationLog | 操作日志表 |
| api_ai_service_configs | AIServiceConfig | AI服务配置表 |

### 9.2 索引设计

| 表名 | 索引字段 | 类型 |
|------|---------|------|
| api_projects | owner, status, project_type, created_at | 复合/单字段 |
| api_requests | collection, method, request_type | 复合 |
| api_request_histories | request, executed_by, executed_at | 复合 |
| api_notification_logs | status, notification_type, created_at | 复合/单字段 |
| api_operation_logs | created_at, resource_type+resource_id, user+created_at | 复合 |
| api_scheduled_tasks | status, trigger_type, task_type | 单字段 |

---

## 10. 依赖关系

### 10.1 系统依赖

**Python 包**：
- Django 4.2+
- djangorestframework
- django-filter
- requests
- apscheduler (可选，用于本地定时任务)
- jsonpath-ng (用于 JSONPath 断言)

**Node.js 包**：
- vue 3.x
- element-plus
- pinia
- vue-router
- axios
- dayjs

### 10.2 模块间依赖

| 被依赖模块 | 依赖关系 | 说明 |
|-----------|---------|------|
| users | 外键 | User 模型用于 owner, members, created_by |
| core | ForeignKey | UnifiedNotificationConfig 通知配置 |

---

## 11. 已实现代码清单

### 11.1 后端代码

| 文件路径 | 说明 |
|---------|------|
| `apps/api_testing/__init__.py` | 应用初始化 |
| `apps/api_testing/apps.py` | Django 应用配置 |
| `apps/api_testing/models.py` | 数据模型定义（约640行） |
| `apps/api_testing/serializers.py` | 序列化器（约850行） |
| `apps/api_testing/views.py` | 视图集（约2800行） |
| `apps/api_testing/urls.py` | 路由配置 |
| `apps/api_testing/utils.py` | 工具函数（断言执行、测试套件执行等） |
| `apps/api_testing/variable_resolver.py` | 变量解析器 |
| `apps/api_testing/operation_logger.py` | 操作日志记录器 |
| `apps/api_testing/custom_email_backend.py` | 自定义邮件后端 |
| `apps/api_testing/admin.py` | Admin 配置 |

### 11.2 前端代码

| 文件路径 | 说明 |
|---------|------|
| `frontend/src/views/api-testing/index.vue` | 主布局组件 |
| `frontend/src/views/api-testing/Dashboard.vue` | 仪表盘（约1100行） |
| `frontend/src/views/api-testing/ProjectManagement.vue` | 项目管理 |
| `frontend/src/views/api-testing/InterfaceManagement.vue` | 接口管理（约4200行） |
| `frontend/src/views/api-testing/AutomationTesting.vue` | 自动化测试（约1100行） |
| `frontend/src/views/api-testing/RequestHistory.vue` | 请求历史 |
| `frontend/src/views/api-testing/EnvironmentManagement.vue` | 环境管理 |
| `frontend/src/views/api-testing/ReportView.vue` | 报告查看 |
| `frontend/src/views/api-testing/ScheduledTasks.vue` | 定时任务（约700行） |
| `frontend/src/views/api-testing/AIServiceConfig.vue` | AI服务配置 |
| `frontend/src/views/api-testing/NotificationLogs.vue` | 通知日志 |
| `frontend/src/views/api-testing/components/HistoryTable.vue` | 历史记录表格组件 |
| `frontend/src/views/api-testing/components/EnvironmentTable.vue` | 环境变量表格组件 |
| `frontend/src/views/api-testing/components/KeyValueEditor.vue` | Key-Value编辑器组件 |
| `frontend/src/locales/lang/zh-cn/api-testing.js` | 中文国际化（约900行） |
| `frontend/src/locales/lang/en/api-testing.js` | 英文国际化（约890行） |

---

## 12. 后续优化建议

### 12.1 功能增强

1. **接口导入导出**：支持 Swagger/OpenAPI、Postman 格式导入导出
2. **接口Mock服务**：基于现有接口定义自动生成 Mock 服务器
3. **性能测试**：支持压力测试、负载测试
4. **协作功能**：接口版本管理、变更历史、评论讨论
5. **安全测试**：集成安全扫描功能

### 12.2 性能优化

1. **请求历史清理**：自动清理过期的历史记录
2. **数据库优化**：添加适当索引，优化查询性能
3. **缓存机制**：缓存常用环境变量和配置

### 12.3 集成扩展

1. **CI/CD 集成**：支持 Jenkins、GitLab CI 等触发执行
2. **监控集成**：与 Prometheus、Grafana 等监控平台集成
3. **消息队列**：使用 RabbitMQ/Kafka 处理异步任务

---

## 13. 附录

### 13.1 术语表

| 术语 | 说明 |
|------|------|
| Collection | API 集合，用于组织管理相关接口 |
| Environment | 环境变量，用于不同环境的配置切换 |
| Assertion | 断言，用于验证接口响应是否符合预期 |
| Variable | 变量，用于接口间的数据传递 |
| Test Suite | 测试套件，包含多个接口的测试集合 |
| Scheduled Task | 定时任务，按计划自动执行的测试任务 |
| Allure Report | Allure 报告，标准化的测试报告格式 |

### 13.2 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
