# TestHub APP 自动化测试模块设计方案

## 1. 模块概述

APP 自动化测试模块是 TestHub 智能测试管理平台的核心功能之一，提供完整的 Android APP 自动化测试能力。该模块基于 Airtest 框架，支持多设备管理、元素识别（图片/坐标/区域）、测试用例编排、定时执行和多渠道通知。

### 1.1 设计目标

- **多设备支持**：支持模拟器、远程设备、USB 连接设备
- **元素智能管理**：支持图片、坐标、区域三种元素类型
- **场景化用例**：通过可视化编排构建测试场景
- **分布式执行**：支持多设备并行执行测试用例
- **定时任务**：灵活配置定时执行计划
- **全面通知**：邮件、企业微信、飞书、钉钉等多渠道通知

### 1.2 功能架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         APP 自动化测试模块                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │
│  │   仪表盘   │  │   项目管理  │  │   设备管理  │  │  元素管理  │      │
│  │ Dashboard  │  │  Projects  │  │  Devices  │  │  Elements  │      │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │
│  │  应用包名  │  │  测试用例  │  │   测试套件  │  │  执行记录  │      │
│  │  Packages  │  │ Test Cases │  │  Suites   │  │Executions │      │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐                      │
│  │  定时任务  │  │   测试报告  │  │  通知日志  │                      │
│  │   Tasks    │  │   Reports  │  │Notifications│                      │
│  └────────────┘  └────────────┘  └────────────┘                      │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     Airtest 测试引擎                               │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │   │
│  │  │ Airtest    │  │   ADB     │  │   Allure  │            │   │
│  │  │ Framework  │  │  Control  │  │   Reports  │            │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 技术选型

| 技术项 | 选型 | 说明 |
|-------|------|------|
| 后端框架 | Django 4.2 + Django REST Framework | 成熟稳定的 Python Web 框架 |
| 测试框架 | Airtest + Poco | 跨平台 APP 自动化测试框架 |
| 设备控制 | ADB (Android Debug Bridge) | Android 设备通信协议 |
| 异步任务 | Celery | 分布式任务队列 |
| 前端框架 | Vue 3 + Element Plus | 现代化组件库 |
| 状态管理 | Pinia | Vue 3 官方推荐 |
| 数据库 | MySQL 8.0+ | 支持 utf8mb4 字符集 |

---

## 2. 数据模型设计

### 2.1 模型关系图

```
AppProject (APP自动化项目)
    │
    ├── AppElement (UI元素)
    │
    ├── AppTestCase (测试用例)
    │
    ├── AppTestSuite (测试套件)
    │         │
    │         └───< AppTestSuiteCase (套件用例关联)
    │
    └── AppDevice (设备)
            │
            └───< AppTestExecution (执行记录)

AppPackage (应用包名)

AppComponent (组件定义)
AppCustomComponent (自定义组件)
AppComponentPackage (组件包)

AppTestConfig (全局配置)

AppScheduledTask (定时任务)
    │
    └───< AppNotificationLog (通知日志)
```

### 2.2 模型详细定义

#### 2.2.1 AppProject (APP自动化项目)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 项目ID |
| name | CharField(200) | 必填 | 项目名称 |
| description | TextField | 可选 | 项目描述 |
| status | CharField(20) | 默认IN_PROGRESS | 项目状态 |
| start_date | DateField | 可为空 | 开始日期 |
| end_date | DateField | 可为空 | 结束日期 |
| owner | ForeignKey(User) | 必填 | 负责人 |
| members | ManyToManyField(User) | 可选 | 团队成员 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| NOT_STARTED | 未开始 | 项目尚未开始 |
| IN_PROGRESS | 进行中 | 项目正在执行 |
| COMPLETED | 已结束 | 项目已完成 |

#### 2.2.2 AppTestConfig (全局配置)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| adb_path | CharField(500) | 默认adb | ADB 路径 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

#### 2.2.3 AppDevice (Android设备)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 设备ID |
| device_id | CharField(255) | 唯一 | 设备序列号 |
| name | CharField(255) | 可为空 | 设备名称 |
| status | CharField(20) | 默认OFFLINE | 状态 |
| android_version | CharField(50) | 可为空 | Android 版本 |
| connection_type | CharField(20) | 默认emulator | 连接类型 |
| ip_address | CharField(50) | 可为空 | IP 地址 |
| port | IntegerField | 默认5555 | 端口 |
| locked_by | ForeignKey(User) | 可为空 | 锁定用户 |
| locked_at | DateTimeField | 可为空 | 锁定时间 |
| max_allocation_time | IntegerField | 默认28800秒 | 最大分配时间 |
| device_specs | JSONField | 可为空 | 设备规格信息 |
| description | TextField | 可选 | 设备描述 |
| location | CharField(200) | 可为空 | 设备位置 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| AVAILABLE | 可用 | 设备空闲可用 |
| LOCKED | 已锁定 | 正在被使用 |
| ONLINE | 在线 | 设备在线 |
| OFFLINE | 离线 | 设备离线 |

**connection_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| emulator | 本地模拟器 | 本地模拟器设备 |
| remote_emulator | 远程模拟器 | 远程模拟器设备 |
| real_device | 真实设备 | USB 连接的物理设备 |

**设备方法**：

| 方法 | 说明 |
|------|------|
| `lock(user)` | 锁定设备 |
| `unlock()` | 释放设备 |
| `is_lock_expired()` | 检查锁定是否过期 |

#### 2.2.4 AppElement (UI元素)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 元素ID |
| project | ForeignKey(AppProject) | 可为空 | 所属项目 |
| name | CharField(200) | 唯一 | 元素名称 |
| element_type | CharField(10) | 必填 | 元素类型 |
| tags | JSONField | 默认[] | 标签列表 |
| config | JSONField | 默认{} | 元素配置 |
| resolution_configs | JSONField | 可为空 | 分辨率配置 |
| usage_count | IntegerField | 默认0 | 使用次数 |
| last_used_at | DateTimeField | 可为空 | 最后使用时间 |
| created_by | ForeignKey(User) | 可为空 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |
| is_active | BooleanField | 默认True | 是否启用 |

**element_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| IMAGE | 图片元素 | 基于图像识别 |
| POS | 坐标元素 | 基于屏幕坐标 |
| REGION | 区域元素 | 基于屏幕区域 |

**config JSON 结构**：

```json
// IMAGE 类型
{
    "image_category": "common",
    "image_path": "common/login.png",
    "file_hash": "abc123...",
    "image_threshold": 0.7,
    "rgb": false
}

// POS 类型
{
    "x": 100,
    "y": 200
}

// REGION 类型
{
    "x1": 100,
    "y1": 200,
    "x2": 300,
    "y2": 400
}
```

**元素方法**：

| 方法 | 说明 |
|------|------|
| `increment_usage()` | 增加使用次数 |

#### 2.2.5 AppComponent (组件定义)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 组件ID |
| name | CharField(100) | 必填 | 组件名称 |
| type | CharField(50) | 唯一 | 组件类型 |
| category | CharField(50) | 可为空 | 类别 |
| description | TextField | 可选 | 描述 |
| schema | JSONField | 默认{} | 配置 Schema |
| default_config | JSONField | 默认{} | 默认配置 |
| enabled | BooleanField | 默认True | 是否启用 |
| sort_order | IntegerField | 默认0 | 排序 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

#### 2.2.6 AppCustomComponent (自定义组件)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 组件ID |
| name | CharField(100) | 必填 | 组件名称 |
| type | CharField(50) | 唯一 | 组件类型 |
| description | TextField | 可选 | 描述 |
| schema | JSONField | 默认{} | 参数 Schema |
| default_config | JSONField | 默认{} | 默认参数 |
| steps | JSONField | 默认[] | 组合步骤 |
| enabled | BooleanField | 默认True | 是否启用 |
| sort_order | IntegerField | 默认0 | 排序 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

#### 2.2.7 AppComponentPackage (组件包)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 包ID |
| name | CharField(100) | 必填 | 包名称 |
| version | CharField(50) | 可为空 | 版本 |
| description | TextField | 可选 | 描述 |
| author | CharField(100) | 可为空 | 作者 |
| source | CharField(20) | 默认upload | 来源 |
| manifest | JSONField | 默认{} | 包清单 |
| created_by | ForeignKey(User) | 可为空 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**source 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| upload | 上传 | 用户上传 |
| market | 市场 | 市场下载 |
| local | 本地 | 本地安装 |

#### 2.2.8 AppPackage (应用包名)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 包名ID |
| name | CharField(100) | 必填 | 应用名称 |
| package_name | CharField(255) | 唯一 | Android 包名 |
| created_by | ForeignKey(User) | 可为空 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

#### 2.2.9 AppTestSuite (测试套件)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 套件ID |
| project | ForeignKey(AppProject) | 可为空 | 所属项目 |
| name | CharField(200) | 必填 | 套件名称 |
| description | TextField | 可选 | 套件描述 |
| test_cases | ManyToManyField | - | 测试用例 |
| execution_status | CharField(20) | 默认not_run | 执行状态 |
| execution_result | CharField(20) | 可为空 | 测试结果 |
| passed_count | IntegerField | 默认0 | 通过用例数 |
| failed_count | IntegerField | 默认0 | 失败用例数 |
| last_run_at | DateTimeField | 可为空 | 最后执行时间 |
| created_by | ForeignKey(User) | 可为空 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**execution_status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| not_run | 未执行 | 尚未执行 |
| running | 执行中 | 正在执行 |
| completed | 已完成 | 执行完成 |
| error | 执行异常 | 执行出错 |

**execution_result 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| passed | 通过 | 全部通过 |
| failed | 失败 | 有用例失败 |
| skipped | 跳过 | 被跳过 |

**计算属性**：

```python
@property
def test_case_count(self):
    return self.suite_cases.count()
```

#### 2.2.10 AppTestSuiteCase (套件用例关联)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 关联ID |
| test_suite | ForeignKey(AppTestSuite) | 必填 | 测试套件 |
| test_case | ForeignKey(AppTestCase) | 必填 | 测试用例 |
| order | IntegerField | 默认0 | 执行顺序 |

**唯一约束**：`[test_suite, test_case]`

#### 2.2.11 AppTestCase (测试用例)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 用例ID |
| project | ForeignKey(AppProject) | 可为空 | 所属项目 |
| name | CharField(200) | 必填 | 用例名称 |
| description | TextField | 可选 | 用例描述 |
| ui_flow | JSONField | 默认[] | UI 流程定义 |
| variables | JSONField | 默认{} | 变量定义 |
| timeout | IntegerField | 默认300秒 | 超时时间 |
| retry_count | IntegerField | 默认0 | 重试次数 |
| package | ForeignKey(AppPackage) | 可为空 | 关联应用包名 |
| created_by | ForeignKey(User) | 可为空 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**ui_flow JSON 结构示例**：

```json
[
    {
        "step": 1,
        "action": "start_app",
        "target": "com.example.app",
        "params": {}
    },
    {
        "step": 2,
        "action": "wait",
        "target": "login_button",
        "params": {"timeout": 10}
    },
    {
        "step": 3,
        "action": "click",
        "target": "login_button",
        "params": {}
    },
    {
        "step": 4,
        "action": "input_text",
        "target": "username_input",
        "params": {"text": "{{username}}"}
    },
    {
        "step": 5,
        "action": "assert_exists",
        "target": "dashboard",
        "params": {}
    }
]
```

#### 2.2.12 AppTestExecution (执行记录)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 执行ID |
| project | ForeignKey(AppProject) | 可为空 | 所属项目 |
| test_suite | ForeignKey(AppTestSuite) | 可为空 | 测试套件 |
| test_case | ForeignKey(AppTestCase) | 可为空 | 测试用例 |
| device | ForeignKey(AppDevice) | 可为空 | 执行设备 |
| status | CharField(20) | 默认pending | 执行状态 |
| result | CharField(20) | 可为空 | 测试结果 |
| progress | IntegerField | 默认0 | 执行进度 |
| total_steps | IntegerField | 默认0 | 总步骤数 |
| passed_steps | IntegerField | 默认0 | 通过步骤数 |
| failed_steps | IntegerField | 默认0 | 失败步骤数 |
| task_id | CharField(255) | 可为空 | Celery 任务ID |
| report_path | CharField(500) | 可为空 | 报告路径 |
| error_message | TextField | 可选 | 错误信息 |
| executed_by | ForeignKey(User) | 可为空 | 执行人员 |
| started_at | DateTimeField | 可为空 | 开始时间 |
| finished_at | DateTimeField | 可为空 | 结束时间 |
| created_at | DateTimeField | 自动 | 创建时间 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| pending | 等待中 | 等待执行 |
| running | 执行中 | 正在执行 |
| completed | 已完成 | 执行完成 |
| error | 异常 | 执行出错 |
| stopped | 已停止 | 被手动停止 |

**result 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| passed | 通过 | 测试通过 |
| failed | 失败 | 测试失败 |
| skipped | 跳过 | 测试跳过 |

**pass_rate 计算属性**：

```python
@property
def pass_rate(self):
    if self.total_steps == 0:
        return 0
    return round((self.passed_steps / self.total_steps) * 100, 2)
```

#### 2.2.13 AppScheduledTask (定时任务)

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
| test_suite | ForeignKey(AppTestSuite) | 可为空 | 测试套件 |
| test_cases | JSONField | 可为空 | 用例列表 |
| device | ForeignKey(AppDevice) | 可为空 | 执行设备 |
| status | CharField(20) | 默认paused | 任务状态 |
| last_run_time | DateTimeField | 可为空 | 上次执行时间 |
| next_run_time | DateTimeField | 可为空 | 下次执行时间 |
| total_runs | IntegerField | 默认0 | 总执行次数 |
| successful_runs | IntegerField | 默认0 | 成功次数 |
| failed_runs | IntegerField | 默认0 | 失败次数 |
| created_by | ForeignKey(User) | 必填 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |

**task_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| TEST_SUITE | 测试套件 | 执行测试套件 |
| TEST_CASE | 测试用例 | 执行测试用例 |

**trigger_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| CRON | Cron表达式 | 按 Cron 表达式定时执行 |
| INTERVAL | 间隔执行 | 按固定间隔执行 |
| ONCE | 单次执行 | 在指定时间执行一次 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| paused | 已暂停 | 任务暂停 |
| active | 运行中 | 任务正在运行 |
| completed | 已完成 | 单次任务执行完毕 |

#### 2.2.14 AppNotificationLog (通知日志)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 日志ID |
| task | ForeignKey(AppScheduledTask) | 可为空 | 关联任务 |
| notification_type | CharField(50) | 必填 | 通知类型 |
| recipient_info | JSONField | 必填 | 收件人信息 |
| notification_content | TextField | 必填 | 通知内容 |
| status | CharField(20) | 默认pending | 发送状态 |
| error_message | TextField | 可选 | 错误信息 |
| created_at | DateTimeField | 自动 | 创建时间 |
| sent_at | DateTimeField | 可为空 | 发送时间 |

---

## 3. API 接口设计

### 3.1 路由总览

所有 API 接口前缀：`/api/app-automation/`

| 路由前缀 | ViewSet | 说明 |
|---------|---------|------|
| `projects/` | AppProjectViewSet | 项目管理 |
| `config/` | AppConfigViewSet | 配置管理 |
| `dashboard/` | AppDashboardViewSet | 仪表盘 |
| `devices/` | AppDeviceViewSet | 设备管理 |
| `elements/` | AppElementViewSet | 元素管理 |
| `components/` | AppComponentViewSet | 组件定义 |
| `custom-components/` | AppCustomComponentViewSet | 自定义组件 |
| `component-packages/` | AppComponentPackageViewSet | 组件包 |
| `packages/` | AppPackageViewSet | 应用包名 |
| `test-cases/` | AppTestCaseViewSet | 测试用例 |
| `test-suites/` | AppTestSuiteViewSet | 测试套件 |
| `scheduled-tasks/` | AppScheduledTaskViewSet | 定时任务 |
| `notification-logs/` | AppNotificationLogViewSet | 通知日志 |
| `executions/` | AppTestExecutionViewSet | 执行记录 |

### 3.2 项目管理 API (AppProjectViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/app-automation/projects/` | 获取项目列表 | `status`, 搜索, 分页 |
| POST | `/api/app-automation/projects/` | 创建项目 | `member_ids` |
| GET | `/api/app-automation/projects/{id}/` | 获取项目详情 | - |
| PUT | `/api/app-automation/projects/{id}/` | 更新项目 | - |
| DELETE | `/api/app-automation/projects/{id}/` | 删除项目 | - |

### 3.3 设备管理 API (AppDeviceViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/app-automation/devices/` | 获取设备列表 | `status`, `connection_type` |
| POST | `/api/app-automation/devices/` | 创建设备 | - |
| GET | `/api/app-automation/devices/{id}/` | 获取设备详情 | - |
| PUT | `/api/app-automation/devices/{id}/` | 更新设备 | - |
| DELETE | `/api/app-automation/devices/{id}/` | 删除设备 | - |
| GET | `/api/app-automation/devices/discover/` | 发现ADB设备 | - |
| POST | `/api/app-automation/devices/{id}/lock/` | 锁定设备 | - |
| POST | `/api/app-automation/devices/{id}/unlock/` | 释放设备 | - |
| POST | `/api/app-automation/devices/connect/` | 连接远程设备 | `ip_address`, `port` |
| POST | `/api/app-automation/devices/{id}/disconnect/` | 断开设备 | - |
| POST | `/api/app-automation/devices/{id}/screenshot/` | 获取截图 | - |

### 3.4 元素管理 API (AppElementViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/app-automation/elements/` | 获取元素列表 | `project`, `element_type`, 搜索 |
| POST | `/api/app-automation/elements/` | 创建元素 | - |
| GET | `/api/app-automation/elements/{id}/` | 获取元素详情 | - |
| PUT | `/api/app-automation/elements/{id}/` | 更新元素 | - |
| DELETE | `/api/app-automation/elements/{id}/` | 删除元素 | - |
| POST | `/api/app-automation/elements/upload/` | 上传元素图片 | - |
| GET | `/api/app-automation/elements/image-categories/` | 获取图片分类 | - |
| POST | `/api/app-automation/elements/image-categories/create/` | 创建分类 | `name` |
| DELETE | `/api/app-automation/elements/image-categories/{name}/` | 删除分类 | - |
| GET | `/api/app-automation/elements/{id}/preview/` | 预览图片 | - |
| POST | `/api/app-automation/elements/crop-image/` | 裁剪图片 | `image_id`, `crop_params` |

### 3.5 测试用例 API (AppTestCaseViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/app-automation/test-cases/` | 获取用例列表 | `project`, `package` |
| POST | `/api/app-automation/test-cases/` | 创建用例 | - |
| GET | `/api/app-automation/test-cases/{id}/` | 获取用例详情 | - |
| PUT | `/api/app-automation/test-cases/{id}/` | 更新用例 | - |
| DELETE | `/api/app-automation/test-cases/{id}/` | 删除用例 | - |
| POST | `/api/app-automation/test-cases/{id}/execute/` | 执行用例 | `device_id` |

### 3.6 测试套件 API (AppTestSuiteViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/app-automation/test-suites/` | 获取套件列表 | `project` |
| POST | `/api/app-automation/test-suites/` | 创建套件 | `test_case_ids` |
| GET | `/api/app-automation/test-suites/{id}/` | 获取套件详情 | - |
| PUT | `/api/app-automation/test-suites/{id}/` | 更新套件 | - |
| DELETE | `/api/app-automation/test-suites/{id}/` | 删除套件 | - |
| GET | `/api/app-automation/test-suites/{id}/test_cases/` | 获取套件用例 | - |
| POST | `/api/app-automation/test-suites/{id}/add_test_case/` | 添加用例 | `test_case_id` |
| POST | `/api/app-automation/test-suites/{id}/add_test_cases/` | 批量添加 | `test_case_ids` |
| POST | `/api/app-automation/test-suites/{id}/remove_test_case/` | 移除用例 | `test_case_id` |
| POST | `/api/app-automation/test-suites/{id}/update_test_case_order/` | 更新顺序 | `order_data` |
| POST | `/api/app-automation/test-suites/{id}/run/` | 执行套件 | `device_id` |
| GET | `/api/app-automation/test-suites/{id}/executions/` | 执行历史 | - |

### 3.7 定时任务 API (AppScheduledTaskViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/app-automation/scheduled-tasks/` | 获取任务列表 | `project`, `task_type`, `trigger_type`, `status` |
| POST | `/api/app-automation/scheduled-tasks/` | 创建任务 | - |
| GET | `/api/app-automation/scheduled-tasks/{id}/` | 获取任务详情 | - |
| PUT | `/api/app-automation/scheduled-tasks/{id}/` | 更新任务 | - |
| DELETE | `/api/app-automation/scheduled-tasks/{id}/` | 删除任务 | - |
| POST | `/api/app-automation/scheduled-tasks/{id}/pause/` | 暂停任务 | - |
| POST | `/api/app-automation/scheduled-tasks/{id}/resume/` | 恢复任务 | - |
| POST | `/api/app-automation/scheduled-tasks/{id}/run_now/` | 立即执行 | - |

### 3.8 执行记录 API (AppTestExecutionViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/app-automation/executions/` | 获取执行记录 | `status`, `project`, `device` |
| GET | `/api/app-automation/executions/{id}/` | 获取执行详情 | - |
| POST | `/api/app-automation/executions/{id}/stop/` | 停止执行 | - |
| GET | `/api/app-automation/executions/{id}/report/` | 获取报告 | - |
| GET | `/api/app-automation/executions/{execution_id}/report/` | 报告文件 | - |

### 3.9 仪表盘 API (AppDashboardViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/app-automation/dashboard/stats/` | 获取统计数据 |

**统计数据响应**：

```json
{
    "total_devices": 10,
    "online_devices": 8,
    "locked_devices": 2,
    "test_cases": 150,
    "total_executions": 500,
    "successful_executions": 450,
    "failed_executions": 50,
    "pass_rate": 90.0
}
```

---

## 4. 执行引擎设计

### 4.1 测试执行流程

```
┌─────────────────────────────────────────────────────────────────┐
│                      测试执行流程                                  │
├─────────────────────────────────────────────────────────────────┤
│ 1. 用户发起执行请求（用例/套件）                                  │
│    ↓                                                            │
│ 2. 后端创建 AppTestExecution 记录                               │
│    ↓                                                            │
│ 3. 触发 Celery 异步任务                                         │
│    ↓                                                            │
│ 4. 锁定目标设备                                                 │
│    ↓                                                            │
│ 5. 生成 pytest 测试脚本                                          │
│    ↓                                                            │
│ 6. 使用 Airtest 执行测试                                         │
│    ↓                                                            │
│ 7. 实时推送执行进度（WebSocket/轮询）                            │
│    ↓                                                            │
│ 8. 生成 Allure 测试报告                                          │
│    ↓                                                            │
│ 9. 更新执行状态和结果                                            │
│    ↓                                                            │
│ 10. 释放设备锁                                                  │
│    ↓                                                            │
│ 11. 发送通知（如已配置）                                         │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Airtest 测试脚本生成

根据测试用例的 `ui_flow` 配置动态生成 pytest 测试脚本：

```python
# 动态生成的测试脚本示例
import airtest
from airtest.core.api import *
from poco import Poco

class TestLogin:
    def setup(self):
        init_device("Android")
        auto_setup(__file__, devices=["Android:///device_id"])
        self.poco = Poco()
    
    def test_login_flow(self):
        # Step 1: 启动应用
        start_app("com.example.app")
        sleep(2)
        
        # Step 2: 点击登录按钮
        touch(Template("login_button.png"))
        sleep(1)
        
        # Step 3: 输入用户名
        self.poco("username_input").set_text("admin")
        
        # Step 4: 输入密码
        self.poco("password_input").set_text("password123")
        
        # Step 5: 点击登录
        touch(Template("submit_button.png"))
        
        # Step 6: 验证结果
        assert_exists(Template("dashboard.png"), "登录成功")
```

---

## 5. 前端页面设计

### 5.1 页面路由

| 路由路径 | 页面组件 | 说明 |
|---------|---------|------|
| `/app-automation/dashboard` | Dashboard.vue | 仪表盘 |
| `/app-automation/projects` | ProjectList.vue | 项目管理 |
| `/app-automation/devices` | DeviceList.vue | 设备管理 |
| `/app-automation/packages` | PackageList.vue | 应用包名 |
| `/app-automation/elements` | ElementList.vue | 元素管理 |
| `/app-automation/scene-builder` | SceneBuilder.vue | 场景构建器 |
| `/app-automation/test-cases` | TestCaseList.vue | 测试用例 |
| `/app-automation/test-suites` | SuiteList.vue | 测试套件 |
| `/app-automation/scheduled-tasks` | ScheduledTasks.vue | 定时任务 |
| `/app-automation/notification-logs` | NotificationLogs.vue | 通知日志 |
| `/app-automation/executions` | ExecutionList.vue | 执行记录 |
| `/app-automation/reports` | ReportList.vue | 测试报告 |

### 5.2 仪表盘页面 (Dashboard.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  APP 自动化测试                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│  设备统计                        │  测试统计                              │
│  ┌──────────┐ ┌──────────┐     │┌──────────┐ ┌──────────┐              │
│  │ 总设备数  │ │ 在线设备  │     ││  用例总数 │ │  执行总数 │              │
│  │    10   │ │    8    │     ││   150   │ │   500   │              │
│  └──────────┘ └──────────┘     │└──────────┘ └──────────┘              │
│  ┌──────────┐ ┌──────────┐     │┌──────────┐ ┌──────────┐              │
│  │ 已锁定设备│ │ 通过率   │     ││ 成功次数 │ │ 失败次数 │              │
│  │    2    │ │  90.0%  │     ││   450   │ │   50    │              │
│  └──────────┘ └──────────┘     │└──────────┘ └──────────┘              │
│                                  │                                       │
│ 最近执行记录                      │ 快速操作                              │
│ ┌──────────────────────────────┐ │┌───────────────────────────────────┐  │
│ │ 2026-04-10 登录流程测试  ✅ │ ││ 📱 设备管理  📦 元素管理         │  │
│ │ 2026-04-10 搜索功能测试  ❌ │ ││ 📝 用例编辑  ▶ 执行测试         │  │
│ │ 2026-04-10 购物车测试   ✅ │ ││ ⏰ 定时任务  📊 测试报告         │  │
│ └──────────────────────────────┘ │└───────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 设备管理页面 (DeviceList.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  设备管理                                          [刷新设备] [+ 添加设备] │
├─────────────────────────────────────────────────────────────────────────────┤
│  状态: [全部▼]   连接类型: [全部▼]   搜索: [__________]                │
├─────────────────────────────────────────────────────────────────────────────┤
│  设备序列号      │ 设备名称  │  状态  │ 锁定用户 │ Android版本 │ 操作 │
├─────────────────────────────────────────────────────────────────────────────┤
│  emulator-5554  │ 模拟器1   │ [可用] │   -     │   11.0    │ ... │
│  emulator-5556  │ 模拟器2   │[已锁定]│  张三   │   11.0    │ ... │
│  192.168.1.100 │ 远程设备1 │ [在线] │   -     │   12.0    │ ... │
│  RF8N123456789 │ 小米11   │ [可用] │   -     │   13.0    │ ... │
└─────────────────────────────────────────────────────────────────────────────┘

操作按钮: [锁定/解锁] [截图] [断开] [删除]
```

### 5.4 元素管理页面 (ElementList.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  元素管理                                          [+ 从设备捕获] [+ 手动创建] │
├─────────────────────────────────────────────────────────────────────────────┤
│  类型: [全部▼]   项目: [全部▼]   搜索: [__________]                     │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ 元素名称          │ 类型     │ 标签              │ 使用次数 │ 操作 │  │
│  ├─────────────────────────────────────────────────────────────────────┤  │
│  │ login_button      │ [图片]   │ [登录] [按钮]    │   15    │ ... │  │
│  │ username_input    │ [坐标]  │ [登录] [输入]    │   8     │ ... │  │
│  │ search_box        │ [区域]   │ [搜索]            │   12    │ ... │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  选中元素详情:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ 名称: login_button                    类型: 图片元素                │  │
│  │ 标签: 登录, 按钮                       使用次数: 15次              │  │
│  │                                                                  │  │
│  │ 配置:                                                          │  │
│  │ ┌────────────────┐  ┌────────────────────────────────────────┐   │  │
│  │ │                │  │                                        │   │  │
│  │ │   [预览图]    │  │ {                                       │   │  │
│  │ │                │  │   "image_category": "common",         │   │  │
│  │ │                │  │   "image_path": "common/login.png",   │   │  │
│  │ └────────────────┘  │   "image_threshold": 0.7                │   │  │
│  │                    └────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.5 场景构建器页面 (SceneBuilder.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  场景构建器 - 登录流程测试                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  基础配置                                                                  │
│  用例名称: [登录流程测试________________]  应用包名: [com.example.app▼]   │
│  描述:   [用户登录功能测试________________]  超时: [300]秒              │
├─────────────────────────────────────────────────────────────────────────────┤
│  步骤列表                                        [+ 添加步骤]              │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ #  │ 操作类型       │ 目标元素        │ 参数                    │ 操作 │  │
│  ├────┼────────────────┼────────────────┼────────────────────────────┼─────┤  │
│  │ 1  │ 启动应用       │ -              │ com.example.app        │ ⋮ │  │
│  │ 2  │ 等待元素       │ login_button   │ timeout: 10s          │ ⋮ │  │
│  │ 3  │ 点击           │ login_button   │ -                      │ ⋮ │  │
│  │ 4  │ 等待元素       │ username_input │ timeout: 5s           │ ⋮ │  │
│  │ 5  │ 输入文本       │ username_input │ text: admin            │ ⋮ │  │
│  │ 6  │ 输入密码       │ password_input │ text: ********         │ ⋮ │  │
│  │ 7  │ 点击           │ submit_button  │ -                      │ ⋮ │  │
│  │ 8  │ 断言存在       │ dashboard      │ -                      │ ⋮ │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  [+ 添加步骤 ▼]                                                           │
│  [启动应用] [等待元素] [点击] [输入文本] [滑动] [断言存在] [断言不存在]   │
│                                                                              │
│                              [保存用例]  [执行测试]                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.6 测试套件页面 (SuiteList.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  测试套件                                              [+ 创建测试套件]        │
├─────────────────────────────────────────────────────────────────────────────┤
│  项目: [全部▼]   状态: [全部▼]                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  套件名称          │ 用例数 │ 状态      │ 通过率 │ 最后执行 │ 操作      │
├─────────────────────────────────────────────────────────────────────────────┤
│  登录功能测试套件  │   5   │ [已完成]  │ 80%   │ 2026-04-10│ ▶ 执行  │
│  搜索功能测试套件  │   8   │ [执行中]  │  -    │ 2026-04-10│ ⏹ 停止 │
│  购物车测试套件    │   12  │ [未执行]  │  -    │     -     │ ▶ 执行  │
└─────────────────────────────────────────────────────────────────────────────┘

创建测试套件对话框:
┌─────────────────────────────────────────────────────────────────────────────┐
│  创建测试套件                                                          [X]  │
├─────────────────────────────────────────────────────────────────────────────┤
│  套件名称: [____________________]                                       │
│  所属项目: [选择项目▼____________]                                       │
│  描述:     [____________________]                                         │
│                                                                              │
│  选择测试用例:                                                           │
│  ┌─────────────────────────┐ ┌─────────────────────────┐                  │
│  │ 可选用例                │ │ 已选用例                 │                  │
│  │ ┌───────────────────┐ │ │ ┌───────────────────┐ │                  │
│  │ │ ☐ 登录流程测试   │ │ │ │ ☑ 登录成功测试   │ │                  │
│  │ │ ☐ 注册流程测试   │ │ │ │ ☑ 登录失败测试   │ │                  │
│  │ │ ☑ 搜索商品测试   │ │ │ │ ☑ 搜索结果测试   │ │                  │
│  │ │ ☐ 下单流程测试   │ │ │ └───────────────────┘ │                  │
│  │ └───────────────────┘ │ │         [移除]          │                  │
│  └─────────────────────────┘ └─────────────────────────┘                  │
│                                 [取消]  [创建]                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. 权限控制设计

### 6.1 权限矩阵

| 资源 | 查看 | 创建 | 编辑 | 删除 | 执行 |
|------|------|------|------|------|------|
| 项目 | 项目成员 | 登录用户 | 项目负责人/成员 | 项目负责人 | - |
| 设备 | 登录用户 | 登录用户 | 登录用户 | 登录用户 | 登录用户 |
| 元素 | 项目成员 | 项目成员 | 项目成员 | 项目成员 | - |
| 用例 | 项目成员 | 项目成员 | 项目成员 | 项目成员 | 项目成员 |
| 套件 | 项目成员 | 项目成员 | 项目成员 | 项目负责人 | 项目成员 |
| 定时任务 | 创建者 | 登录用户 | 创建者 | 创建者 | 创建者 |

### 6.2 设备锁定机制

设备使用采用锁定机制：
- 用户执行测试前需先锁定设备
- 锁定超时时间默认 8 小时
- 超时后自动释放锁
- 用户可手动解锁释放设备

---

## 7. 数据库表结构

### 7.1 数据库表清单

| 表名 | 对应模型 | 说明 |
|------|---------|------|
| app_projects | AppProject | APP自动化项目表 |
| app_test_config | AppTestConfig | 全局配置表 |
| app_devices | AppDevice | Android设备表 |
| app_elements | AppElement | UI元素表 |
| app_components | AppComponent | 组件定义表 |
| app_custom_components | AppCustomComponent | 自定义组件表 |
| app_component_packages | AppComponentPackage | 组件包表 |
| app_packages | AppPackage | 应用包名表 |
| app_test_suites | AppTestSuite | 测试套件表 |
| app_test_suite_cases | AppTestSuiteCase | 套件用例关联表 |
| app_test_cases | AppTestCase | 测试用例表 |
| app_test_executions | AppTestExecution | 执行记录表 |
| app_scheduled_tasks | AppScheduledTask | 定时任务表 |
| app_notification_logs | AppNotificationLog | 通知日志表 |

### 7.2 索引设计

| 表名 | 索引字段 | 类型 |
|------|---------|------|
| app_devices | status, device_id | 单字段 |
| app_elements | element_type, name, is_active | 单字段/复合 |
| app_packages | package_name, name | 单字段 |
| app_test_executions | status, created_at | 单字段 |

---

## 8. 依赖关系

### 8.1 系统依赖

**Python 包**：
- Django 4.2+
- djangorestframework
- celery (异步任务)
- redis (Celery broker)
- airtest (APP自动化测试框架)
- poco (跨平台UI自动化框架)
- allured (测试报告)
- Pillow (图像处理)

**Node.js 包**：
- vue 3.x
- element-plus
- pinia
- vue-router
- axios

### 8.2 模块间依赖

| 被依赖模块 | 依赖关系 | 说明 |
|-----------|---------|------|
| users | 外键 | User 模型用于 owner, members, created_by |
| core | ForeignKey | UnifiedNotificationConfig 通知配置 |

---

## 9. 已实现代码清单

### 9.1 后端代码

| 文件路径 | 说明 |
|---------|------|
| `apps/app_automation/__init__.py` | 应用初始化 |
| `apps/app_automation/apps.py` | Django 应用配置 |
| `apps/app_automation/constants.py` | 常量定义 |
| `apps/app_automation/models.py` | 数据模型定义（约930行） |
| `apps/app_automation/serializers.py` | 序列化器（约350行） |
| `apps/app_automation/views.py` | 视图实现（约900行） |
| `apps/app_automation/urls.py` | 路由配置 |
| `apps/app_automation/admin.py` | Admin 配置 |
| `apps/app_automation/tasks.py` | Celery 异步任务 |
| `apps/app_automation/wsconsumer.py` | WebSocket 消费者 |
| `apps/app_automation/generators/` | 测试脚本生成器目录 |
| `apps/app_automation/generators/__init__.py` | 生成器初始化 |
| `apps/app_automation/generators/airtest_generator.py` | Airtest 脚本生成 |
| `apps/app_automation/generators/test_template.py` | 测试模板 |
| `apps/app_automation/Template/` | 模板文件目录 |

### 9.2 前端代码

| 文件路径 | 说明 |
|---------|------|
| `frontend/src/views/app-automation/Index.vue` | 主入口页面 |
| `frontend/src/views/app-automation/dashboard/Dashboard.vue` | 仪表盘 |
| `frontend/src/views/app-automation/projects/ProjectList.vue` | 项目列表 |
| `frontend/src/views/app-automation/devices/DeviceList.vue` | 设备管理 |
| `frontend/src/views/app-automation/packages/PackageList.vue` | 应用包名 |
| `frontend/src/views/app-automation/elements/ElementList.vue` | 元素管理 |
| `frontend/src/views/app-automation/elements/components/CaptureElementDialog.vue` | 捕获元素对话框 |
| `frontend/src/views/app-automation/elements/components/ManualElementDialog.vue` | 手动创建对话框 |
| `frontend/src/views/app-automation/test-cases/TestCaseList.vue` | 用例列表 |
| `frontend/src/views/app-automation/test-cases/SceneBuilder.vue` | 场景构建器 |
| `frontend/src/views/app-automation/suites/SuiteList.vue` | 测试套件 |
| `frontend/src/views/app-automation/scheduled-tasks/ScheduledTasks.vue` | 定时任务 |
| `frontend/src/views/app-automation/notification/NotificationLogs.vue` | 通知日志 |
| `frontend/src/views/app-automation/executions/ExecutionList.vue` | 执行记录 |
| `frontend/src/views/app-automation/reports/ReportList.vue` | 报告列表 |
| `frontend/src/views/app-automation/settings/AppSettings.vue` | APP配置 |
| `frontend/src/api/app-automation.js` | 前端 API（约650行） |
| `frontend/src/locales/lang/zh-cn/app-automation.js` | 中文国际化（约300行） |

---

## 10. 后续优化建议

### 10.1 功能增强

1. **多平台支持**：扩展支持 iOS APP 自动化测试
2. **图像识别优化**：集成更智能的图像识别算法
3. **设备池管理**：建立设备池，自动分配可用设备
4. **执行录像**：录制测试执行过程视频
5. **智能用例推荐**：基于历史数据分析推荐相关用例

### 10.2 性能优化

1. **并行执行**：支持多设备同时执行测试用例
2. **增量执行**：只执行变更的用例
3. **执行缓存**：缓存常用元素和组件

### 10.3 集成扩展

1. **CI/CD 集成**：Jenkins、GitLab CI 触发执行
2. **缺陷管理集成**：自动创建缺陷单
3. **消息推送**：集成企业微信、钉钉 SDK

---

## 11. 附录

### 11.1 术语表

| 术语 | 说明 |
|------|------|
| Airtest | 跨平台 APP 自动化测试框架 |
| ADB | Android Debug Bridge，Android 调试桥 |
| POCO | 跨平台 UI 自动化框架 |
| Image Recognition | 图像识别元素定位 |
| Allure Report | 标准化测试报告框架 |

### 11.2 元素类型对比

| 类型 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| IMAGE | 抗 UI 变化能力强 | 需要维护图片库 | UI 稳定的元素 |
| POS | 实现简单 | 不同设备兼容差 | 临时调试 |
| REGION | 范围灵活 | 可能误匹配 | 大区域判断 |

### 11.3 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
