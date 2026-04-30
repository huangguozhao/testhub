# TestHub UI 自动化测试模块设计方案

## 1. 模块概述

UI 自动化测试模块是 TestHub 智能测试管理平台的核心功能之一，提供完整的 Web UI 自动化测试能力。该模块支持 Playwright 和 Selenium 双引擎驱动，提供可视化的元素管理、脚本编辑、测试套件编排、定时执行和多渠道通知功能，并创新性地集成了 AI 智能模式，通过自然语言描述自动生成测试用例和执行操作。

### 1.1 设计目标

- **双引擎支持**：Playwright + Selenium 双引擎驱动，兼容多种浏览器
- **元素智能管理**：集中管理页面元素，支持多种定位策略和备用定位器
- **页面对象模式**：基于 Page Object 设计模式，提升脚本可维护性
- **可视化编辑**：低代码/无代码测试用例编辑，降低使用门槛
- **AI 智能模式**：自然语言描述任务，AI 自动执行浏览器操作
- **定时任务**：灵活配置定时执行，支持 CI/CD 集成
- **全面通知**：邮件、企业微信、飞书、钉钉等多渠道通知

### 1.2 功能架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         UI 自动化测试模块                                  │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │
│  │   仪表盘   │  │   项目管理  │  │  元素管理  │  │  页面对象  │      │
│  │ Dashboard  │  │  Projects  │  │  Elements  │  │Page Objects│      │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │
│  │  脚本管理  │  │  用例管理  │  │  套件管理  │  │  执行记录  │      │
│  │  Scripts   │  │Test Cases │  │  Suites    │  │Executions │      │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │
│  │  定时任务  │  │   测试报告  │  │  通知管理  │  │ AI智能测试 │      │
│  │   Tasks    │  │  Reports   │  │Notifications│  │AI Testing │      │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     AI 智能模式引擎                               │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │   │
│  │  │ browser-use │  │  LangChain  │  │   LLM API  │            │   │
│  │  │   Library   │  │  Integration │  │  Multi-Provider │        │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 技术选型

| 技术项 | 选型 | 说明 |
|-------|------|------|
| 后端框架 | Django 4.2 + Django REST Framework | 成熟稳定的 Python Web 框架 |
| 自动化引擎 | Playwright + Selenium | 双引擎支持多浏览器 |
| AI 集成 | browser-use + LangChain | 智能浏览器自动化 |
| 前端框架 | Vue 3 + Element Plus | 现代化组件库 |
| 状态管理 | Pinia | Vue 3 官方推荐 |
| 数据库 | MySQL 8.0+ | 支持 utf8mb4 字符集 |

---

## 2. 数据模型设计

### 2.1 模型关系图

```
UiProject (UI自动化项目)
    │
    ├── ElementGroup (元素分组) ────< ElementGroup (子分组，树形结构)
    │         │
    │         └───< Element (UI元素)
    │                   │
    │                   └───< Element (自关联，父元素)
    │
    ├── PageObject (页面对象)
    │         │
    │         └───< PageObjectElement (页面对象元素关联)
    │
    ├── TestScript (测试脚本)
    │         │
    │         ├───< ScriptStep (脚本步骤)
    │         └───< ScriptElementUsage (元素使用记录)
    │
    ├── TestCase (UI测试用例)
    │         │
    │         └───< TestCaseStep (用例步骤)
    │
    ├── TestSuite (测试套件)
    │         │
    │         ├───< TestSuiteScript (套件脚本关联)
    │         └───< TestSuiteTestCase (套件用例关联)
    │
    ├── TestExecution (测试执行记录)
    │         │
    │         └───< Screenshot (截图)
    │
    ├── UiScheduledTask (定时任务)
    │         │
    │         └───< UiTaskNotificationSetting (通知设置)
    │
    ├── AICase (AI测试用例)
    │         │
    │         └───< AIExecutionRecord (AI执行记录)
    │
    └── OperationRecord (操作记录)

LocatorStrategy (定位策略)
```

### 2.2 模型详细定义

#### 2.2.1 UiProject (UI自动化项目)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 项目ID |
| name | CharField(200) | 必填 | 项目名称 |
| description | TextField | 可选 | 项目描述 |
| status | CharField(20) | 默认IN_PROGRESS | 项目状态 |
| base_url | URLField | 必填 | 基础URL |
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

#### 2.2.2 LocatorStrategy (定位策略)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 策略ID |
| name | CharField(50) | 必填 | 策略名称 |
| description | TextField | 可选 | 策略描述 |

**内置定位策略**：

| 策略名称 | 说明 |
|---------|------|
| ID | 元素 ID 属性 |
| CSS | CSS Selector |
| XPATH | XPath 表达式 |
| NAME | 元素 name 属性 |
| CLASS_NAME | 元素 class 属性 |
| TAG_NAME | HTML 标签名 |
| LINK_TEXT | 链接文本 |
| PARTIAL_LINK_TEXT | 部分链接文本 |

#### 2.2.3 ElementGroup (元素分组)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 分组ID |
| name | CharField(200) | 必填 | 分组名称 |
| description | TextField | 可选 | 分组描述 |
| project | ForeignKey(UiProject) | 必填 | 所属项目 |
| parent_group | ForeignKey(self) | 可为空 | 父分组（支持树形结构） |
| order | IntegerField | 默认0 | 排序 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

#### 2.2.4 Element (UI元素)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 元素ID |
| project | ForeignKey(UiProject) | 必填 | 所属项目 |
| group | ForeignKey(ElementGroup) | 可为空 | 所属分组 |
| name | CharField(200) | 必填 | 元素名称 |
| description | TextField | 可选 | 元素描述 |
| element_type | CharField(50) | 默认BUTTON | 元素类型 |
| locator_strategy | ForeignKey(LocatorStrategy) | 必填 | 定位策略 |
| locator_value | CharField(500) | 必填 | 定位表达式 |
| backup_locators | JSONField | 可为空 | 备用定位器 |
| page | CharField(200) | 可为空 | 所属页面 |
| component_name | CharField(100) | 可为空 | 组件名称 |
| parent_element | ForeignKey(self) | 可为空 | 父元素（层次关系） |
| is_unique | BooleanField | 默认False | 是否唯一 |
| wait_timeout | IntegerField | 默认5秒 | 等待超时 |
| is_visible | BooleanField | 默认True | 是否可见 |
| is_enabled | BooleanField | 默认True | 是否启用 |
| force_action | BooleanField | 默认False | 强制操作 |
| usage_count | IntegerField | 默认0 | 使用次数 |
| last_validated | DateTimeField | 可为空 | 最后验证时间 |
| validation_status | CharField(20) | 默认UNKNOWN | 验证状态 |
| validation_message | TextField | 可选 | 验证消息 |
| created_by | ForeignKey(User) | 可为空 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**element_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| INPUT | 输入框 | 文本输入框 |
| BUTTON | 按钮 | 可点击按钮 |
| LINK | 链接 | 超链接 |
| DROPDOWN | 下拉框 | 下拉选择框 |
| CHECKBOX | 复选框 | 多选框 |
| RADIO | 单选框 | 单选按钮 |
| TEXT | 文本 | 文本元素 |
| IMAGE | 图片 | 图片元素 |
| CONTAINER | 容器 | 容器元素 |
| TABLE | 表格 | 表格元素 |
| FORM | 表单 | 表单元素 |
| MODAL | 弹窗 | 模态框 |

**validation_status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| VALID | 有效 | 定位器有效 |
| INVALID | 无效 | 定位器无效 |
| UNKNOWN | 未知 | 未验证 |
| PENDING | 待验证 | 等待验证 |

**backup_locators JSON 结构示例**：

```json
[
    {"strategy": "css", "value": ".submit-button"},
    {"strategy": "xpath", "value": "//button[@class='btn primary']"},
    {"strategy": "text", "value": "提交"}
]
```

#### 2.2.5 PageObject (页面对象)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 页面对象ID |
| name | CharField(200) | 必填 | 页面对象名称 |
| class_name | CharField(200) | 必填 | 类名 |
| url_pattern | CharField(500) | 可为空 | URL模式（支持正则） |
| project | ForeignKey(UiProject) | 必填 | 所属项目 |
| description | TextField | 可选 | 描述 |
| template_code | TextField | 可选 | 模板代码 |
| created_by | ForeignKey(User) | 可为空 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**唯一约束**：`[project, name]`

#### 2.2.6 PageObjectElement (页面对象元素关联)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 关联ID |
| page_object | ForeignKey(PageObject) | 必填 | 页面对象 |
| element | ForeignKey(Element) | 必填 | 元素 |
| method_name | CharField(100) | 必填 | 方法/属性名称 |
| is_property | BooleanField | 默认True | 是否为属性 |
| order | IntegerField | 默认0 | 排序 |

**唯一约束**：`[page_object, method_name]`

#### 2.2.7 TestScript (测试脚本)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 脚本ID |
| project | ForeignKey(UiProject) | 必填 | 所属项目 |
| name | CharField(200) | 必填 | 脚本名称 |
| description | TextField | 可选 | 脚本描述 |
| script_type | CharField(20) | 默认LOW_CODE | 脚本类型 |
| content | TextField | 必填 | 脚本内容 |
| language | CharField(20) | 默认python | 脚本语言 |
| framework | CharField(20) | 默认playwright | 执行框架 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**script_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| CODE | 代码 | 完整代码脚本 |
| LOW_CODE | 低代码 | 可视化编排的脚本 |
| NO_CODE | 无代码 | 完全配置化的脚本 |

**language 枚举**：

| 值 | 显示名称 |
|----|---------|
| python | Python |
| javascript | JavaScript |

**framework 枚举**：

| 值 | 显示名称 |
|----|---------|
| playwright | Playwright |
| selenium | Selenium |

#### 2.2.8 ScriptStep (脚本步骤)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 步骤ID |
| script | ForeignKey(TestScript) | 必填 | 所属脚本 |
| step_order | IntegerField | 必填 | 步骤顺序 |
| action_type | CharField(20) | 必填 | 操作类型 |
| target_element | ForeignKey(Element) | 可为空 | 目标元素 |
| page_object | ForeignKey(PageObject) | 可为空 | 页面对象 |
| action_params | JSONField | 可为空 | 操作参数 |
| description | CharField(500) | 可选 | 步骤描述 |
| expected_result | CharField(500) | 可为空 | 预期结果 |
| wait_before | IntegerField | 默认0毫秒 | 执行前等待 |
| wait_after | IntegerField | 默认0毫秒 | 执行后等待 |
| retry_count | IntegerField | 默认0 | 重试次数 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**action_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| CLICK | 点击 | 点击元素 |
| INPUT | 输入 | 输入文本 |
| SELECT | 选择 | 选择下拉选项 |
| VERIFY | 验证 | 验证元素状态 |
| WAIT | 等待 | 等待元素出现 |
| HOVER | 悬停 | 鼠标悬停 |
| SCROLL | 滚动 | 滚动页面 |
| NAVIGATE | 导航 | 页面跳转 |
| SCREENSHOT | 截图 | 页面截图 |
| SWITCH_TAB | 切换标签页 | 切换浏览器标签 |
| CUSTOM | 自定义 | 自定义操作 |

**唯一约束**：`[script, step_order]`

#### 2.2.9 TestSuite (测试套件)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 套件ID |
| project | ForeignKey(UiProject) | 必填 | 所属项目 |
| name | CharField(200) | 必填 | 套件名称 |
| description | TextField | 可选 | 套件描述 |
| execution_status | CharField(20) | 默认not_run | 执行状态 |
| passed_count | IntegerField | 默认0 | 通过数 |
| failed_count | IntegerField | 默认0 | 失败数 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**execution_status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| not_run | 未执行 | 尚未执行 |
| passed | 通过 | 所有用例通过 |
| failed | 失败 | 有用例失败 |
| running | 执行中 | 正在执行 |

#### 2.2.10 TestCase (UI测试用例)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 用例ID |
| name | CharField(200) | 必填 | 用例名称 |
| description | TextField | 可选 | 用例描述 |
| project | ForeignKey(UiProject) | 必填 | 所属项目 |
| status | CharField(20) | 默认draft | 状态 |
| priority | CharField(10) | 默认medium | 优先级 |
| created_by | ForeignKey(User) | 必填 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| draft | 草稿 | 尚未完成 |
| ready | 就绪 | 可以执行 |
| running | 执行中 | 正在执行 |
| passed | 通过 | 执行通过 |
| failed | 失败 | 执行失败 |

**priority 枚举**：

| 值 | 显示名称 |
|----|---------|
| high | 高 |
| medium | 中 |
| low | 低 |

#### 2.2.11 TestCaseStep (用例步骤)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 步骤ID |
| test_case | ForeignKey(TestCase) | 必填 | 所属用例 |
| step_number | IntegerField | 必填 | 步骤序号 |
| action_type | CharField(20) | 必填 | 操作类型 |
| element | ForeignKey(Element) | 可为空 | 目标元素 |
| input_value | TextField | 可为空 | 输入值 |
| assert_type | CharField(20) | 可为空 | 断言类型 |
| expected_value | TextField | 可为空 | 预期值 |
| created_at | DateTimeField | 自动 | 创建时间 |

#### 2.2.12 TestExecution (测试执行记录)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 执行ID |
| project | ForeignKey(UiProject) | 必填 | 所属项目 |
| test_suite | ForeignKey(TestSuite) | 可为空 | 测试套件 |
| test_script | ForeignKey(TestScript) | 可为空 | 测试脚本 |
| environment | CharField(20) | 默认CHROME | 执行环境 |
| status | CharField(20) | 默认PENDING | 执行状态 |
| total_cases | IntegerField | 默认0 | 总用例数 |
| passed_cases | IntegerField | 默认0 | 通过用例数 |
| failed_cases | IntegerField | 默认0 | 失败用例数 |
| skipped_cases | IntegerField | 默认0 | 跳过用例数 |
| started_at | DateTimeField | 可为空 | 开始时间 |
| finished_at | DateTimeField | 可为空 | 结束时间 |
| duration | FloatField | 默认0秒 | 执行时长 |
| executed_by | ForeignKey(User) | 可为空 | 执行人员 |
| engine | CharField(20) | 默认playwright | 测试引擎 |
| browser | CharField(20) | 默认chrome | 浏览器 |
| headless | BooleanField | 默认False | 无头模式 |
| result_data | JSONField | 可为空 | 执行结果数据 |
| error_message | TextField | 可选 | 错误信息 |
| report_url | CharField(500) | 可为空 | 报告URL |
| created_at | DateTimeField | 自动 | 创建时间 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| PENDING | 待执行 | 等待执行 |
| RUNNING | 运行中 | 正在执行 |
| SUCCESS | 成功 | 执行成功 |
| FAILED | 失败 | 执行失败 |
| ABORTED | 中止 | 执行中止 |

**environment 枚举**：

| 值 | 显示名称 |
|----|---------|
| CHROME | Chrome |
| FIREFOX | Firefox |
| SAFARI | Safari |
| EDGE | Edge |
| IE | IE |

**pass_rate 计算属性**：

```python
@property
def pass_rate(self):
    if self.total_cases == 0:
        return 0
    return round((self.passed_cases / self.total_cases) * 100, 2)
```

#### 2.2.13 Screenshot (截图)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 截图ID |
| execution | ForeignKey(TestExecution) | 必填 | 测试执行 |
| name | CharField(200) | 必填 | 截图名称 |
| image | ImageField | 必填 | 截图文件 |
| description | TextField | 可选 | 截图描述 |
| captured_at | DateTimeField | 自动 | 捕获时间 |

#### 2.2.14 UiScheduledTask (定时任务)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 任务ID |
| name | CharField(200) | 必填 | 任务名称 |
| description | TextField | 可选 | 任务描述 |
| task_type | CharField(20) | 必填 | 任务类型 |
| trigger_type | CharField(20) | 必填 | 触发器类型 |
| cron_expression | CharField(100) | 可为空 | Cron表达式 |
| interval_seconds | IntegerField | 可为空 | 间隔秒数 |
| execute_at | DateTimeField | 可为空 | 单次执行时间 |
| test_suite | ForeignKey(TestSuite) | 可为空 | 测试套件 |
| test_cases | JSONField | 可为空 | 用例列表 |
| status | CharField(20) | 默认PAUSED | 任务状态 |
| last_run_time | DateTimeField | 可为空 | 上次执行时间 |
| next_run_time | DateTimeField | 可为空 | 下次执行时间 |
| total_runs | IntegerField | 默认0 | 总执行次数 |
| successful_runs | IntegerField | 默认0 | 成功次数 |
| failed_runs | IntegerField | 默认0 | 失败次数 |
| created_by | ForeignKey(User) | 必填 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |

#### 2.2.15 AICase (AI测试用例)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 用例ID |
| name | CharField(200) | 必填 | 用例名称 |
| description | TextField | 可选 | 用例描述 |
| project | ForeignKey(UiProject) | 必填 | 所属项目 |
| task_description | TextField | 必填 | 任务描述 |
| planned_tasks | JSONField | 可为空 | 规划的任务列表 |
| created_by | ForeignKey(User) | 必填 | 创建人 |
| created_at | DateTimeField | 自动 | 创建时间 |

#### 2.2.16 AIExecutionRecord (AI执行记录)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 记录ID |
| project | ForeignKey(UiProject) | 必填 | 所属项目 |
| ai_case | ForeignKey(AICase) | 可为空 | AI用例 |
| status | CharField(20) | 默认PENDING | 执行状态 |
| logs | TextField | 可为空 | 执行日志 |
| steps_completed | JSONField | 可为空 | 已完成步骤 |
| planned_tasks | JSONField | 可为空 | 规划的任务 |
| screenshots_sequence | JSONField | 可为空 | 截图序列 |
| started_at | DateTimeField | 可为空 | 开始时间 |
| finished_at | DateTimeField | 可为空 | 结束时间 |
| created_at | DateTimeField | 自动 | 创建时间 |

#### 2.2.17 OperationRecord (操作记录)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 记录ID |
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
| run | 运行 | 执行测试 |
| save | 保存 | 保存配置 |

**resource_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| project | 项目 | UI自动化项目 |
| element | 元素 | UI元素 |
| script | 脚本 | 测试脚本 |
| suite | 套件 | 测试套件 |
| case | 用例 | 测试用例 |
| page_object | 页面对象 | 页面对象 |

---

## 3. API 接口设计

### 3.1 路由总览

所有 API 接口前缀：`/api/ui-automation/`

| 路由前缀 | ViewSet | 说明 |
|---------|---------|------|
| `dashboard/` | UiDashboardViewSet | 仪表盘 |
| `projects/` | UiProjectViewSet | 项目管理 |
| `locator-strategies/` | LocatorStrategyViewSet | 定位策略 |
| `element-groups/` | ElementGroupViewSet | 元素分组 |
| `elements/` | ElementViewSet | 元素管理 |
| `test-scripts/` | TestScriptViewSet | 测试脚本 |
| `page-objects/` | PageObjectViewSet | 页面对象 |
| `steps/` | ScriptStepViewSet | 脚本步骤 |
| `test-suites/` | TestSuiteViewSet | 测试套件 |
| `test-executions/` | TestExecutionViewSet | 执行记录 |
| `screenshots/` | ScreenshotViewSet | 截图管理 |
| `test-cases/` | TestCaseViewSet | 测试用例 |
| `test-case-steps/` | TestCaseStepViewSet | 用例步骤 |
| `test-case-executions/` | TestCaseExecutionViewSet | 用例执行 |
| `scheduled-tasks/` | UiScheduledTaskViewSet | 定时任务 |
| `ai-execution-records/` | AIExecutionRecordViewSet | AI执行记录 |
| `ai-cases/` | AICaseViewSet | AI用例 |
| `notification-logs/` | UiNotificationLogViewSet | 通知日志 |
| `operation-records/` | OperationRecordViewSet | 操作记录 |
| `config/environment/` | EnvironmentConfigViewSet | 环境配置 |
| `config/ai-mode/` | AIIntelligentModeConfigViewSet | AI模式配置 |

### 3.2 项目管理 API (UiProjectViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/ui-automation/projects/` | 获取项目列表 | `status`, `owner`, `members`, 搜索, 分页 |
| POST | `/api/ui-automation/projects/` | 创建项目 | - |
| GET | `/api/ui-automation/projects/{id}/` | 获取项目详情 | - |
| PUT | `/api/ui-automation/projects/{id}/` | 更新项目 | - |
| DELETE | `/api/ui-automation/projects/{id}/` | 删除项目 | - |

### 3.3 元素管理 API (ElementViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/ui-automation/elements/` | 获取元素列表 | `project`, `locator_strategy`, `element_type`, `validation_status`, `group`, 搜索 |
| POST | `/api/ui-automation/elements/` | 创建元素 | - |
| GET | `/api/ui-automation/elements/{id}/` | 获取元素详情 | - |
| PUT | `/api/ui-automation/elements/{id}/` | 更新元素 | - |
| DELETE | `/api/ui-automation/elements/{id}/` | 删除元素 | - |
| GET | `/api/ui-automation/elements/{id}/validate_locator/` | 验证定位器 | - |
| GET | `/api/ui-automation/elements/{id}/usages/` | 获取元素使用情况 | - |
| GET | `/api/ui-automation/elements/tree/` | 获取元素树 | `project` |
| POST | `/api/ui-automation/elements/{id}/add_backup_locator/` | 添加备用定位器 | `strategy`, `value` |
| GET | `/api/ui-automation/elements/generate_suggestions/` | 生成建议 | `project`, `page` |

### 3.4 测试用例 API (TestCaseViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/ui-automation/test-cases/` | 获取用例列表 | `project`, `status`, `priority` |
| POST | `/api/ui-automation/test-cases/` | 创建用例 | - |
| GET | `/api/ui-automation/test-cases/{id}/` | 获取用例详情 | - |
| PUT | `/api/ui-automation/test-cases/{id}/` | 更新用例 | - |
| DELETE | `/api/ui-automation/test-cases/{id}/` | 删除用例 | - |
| POST | `/api/ui-automation/test-cases/{id}/run/` | 执行用例 | `browser`, `headless` |
| POST | `/api/ui-automation/test-cases/{id}/copy_case/` | 复制用例 | - |

### 3.5 测试套件 API (TestSuiteViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/ui-automation/test-suites/` | 获取套件列表 | `project` |
| POST | `/api/ui-automation/test-suites/` | 创建套件 | - |
| GET | `/api/ui-automation/test-suites/{id}/` | 获取套件详情 | - |
| PUT | `/api/ui-automation/test-suites/{id}/` | 更新套件 | - |
| DELETE | `/api/ui-automation/test-suites/{id}/` | 删除套件 | - |
| POST | `/api/ui-automation/test-suites/{id}/run_suite/` | 执行套件 | `browser`, `headless` |
| POST | `/api/ui-automation/test-suites/{id}/add_test_case/` | 添加用例 | `test_case_ids` |
| POST | `/api/ui-automation/test-suites/{id}/remove_test_case/` | 移除用例 | `test_case_id` |
| POST | `/api/ui-automation/test-suites/{id}/update_test_case_order/` | 更新用例顺序 | `order_data` |

### 3.6 定时任务 API (UiScheduledTaskViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/ui-automation/scheduled-tasks/` | 获取任务列表 | `task_type`, `trigger_type`, `status` |
| POST | `/api/ui-automation/scheduled-tasks/` | 创建任务 | - |
| GET | `/api/ui-automation/scheduled-tasks/{id}/` | 获取任务详情 | - |
| PUT | `/api/ui-automation/scheduled-tasks/{id}/` | 更新任务 | - |
| DELETE | `/api/ui-automation/scheduled-tasks/{id}/` | 删除任务 | - |
| POST | `/api/ui-automation/scheduled-tasks/{id}/pause/` | 暂停任务 | - |
| POST | `/api/ui-automation/scheduled-tasks/{id}/resume/` | 恢复任务 | - |
| POST | `/api/ui-automation/scheduled-tasks/{id}/run_now/` | 立即执行 | - |

### 3.7 AI 执行 API (AIExecutionRecordViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/ui-automation/ai-execution-records/` | 获取AI执行记录 | `project`, `status` |
| GET | `/api/ui-automation/ai-execution-records/{id}/` | 获取记录详情 | - |
| POST | `/api/ui-automation/ai-execution-records/{id}/run_adhoc/` | 执行临时任务 | `task_description`, `enable_gif` |
| POST | `/api/ui-automation/ai-execution-records/{id}/stop/` | 停止执行 | - |
| GET | `/api/ui-automation/ai-execution-records/{id}/report/` | 获取执行报告 | - |
| GET | `/api/ui-automation/ai-execution-records/{id}/export_pdf/` | 导出PDF报告 | - |

### 3.8 仪表盘 API (UiDashboardViewSet)

| 方法 | 端点 | 说明 | 特殊参数 |
|------|------|------|---------|
| GET | `/api/ui-automation/dashboard/stats/` | 获取统计数据 | - |
| GET | `/api/ui-automation/dashboard/operation_records/` | 操作记录 | 分页 |

**统计数据响应**：

```json
{
    "project_count": 5,
    "test_case_count": 120,
    "suite_count": 15,
    "execution_count": 350
}
```

### 3.9 环境配置 API (EnvironmentConfigViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/ui-automation/config/environment/check_environment/` | 检测环境 | 检查浏览器、驱动 |
| POST | `/api/ui-automation/config/environment/install_driver/` | 安装驱动 | `browser` |

---

## 4. AI 智能模式设计

### 4.1 技术架构

AI 智能模式基于 `browser-use` 库和 LangChain 实现，支持自然语言描述任务并自动执行浏览器操作。

```
┌─────────────────────────────────────────────────────────────────┐
│                    AI 智能模式架构                                │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────┐                                              │
│  │ 自然语言输入   │  "登录电商网站并搜索商品"                      │
│  └───────┬───────┘                                              │
│          │                                                       │
│          ▼                                                       │
│  ┌───────────────┐                                              │
│  │   LLM 分析    │  DeepSeek / Qwen / OpenAI / SiliconFlow       │
│  │  Task Planning │  将任务分解为可执行的步骤                       │
│  └───────┬───────┘                                              │
│          │                                                       │
│          ▼                                                       │
│  ┌───────────────┐                                              │
│  │ browser-use   │  Playwright 浏览器自动化                       │
│  │   Agent       │  执行鼠标点击、键盘输入等操作                   │
│  └───────┬───────┘                                              │
│          │                                                       │
│          ▼                                                       │
│  ┌───────────────┐                                              │
│  │  执行日志     │  实时返回操作日志和任务进度                      │
│  │  截图/GIF    │  可选的执行过程录制                             │
│  └───────────────┘                                              │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 执行流程

```python
def run_full_process_sync(
    task_description: str,      # 任务描述
    analysis_callback,           # 分析回调（返回规划的任务）
    step_callback,              # 步骤回调（返回执行日志）
    should_stop,                # 停止检查函数
    execution_mode: str,       # 'text' 或 'vision'
    enable_gif: bool,          # 是否启用GIF录制
    case_name: str             # 用例名称
):
    # 1. 调用 LLM 分析任务，生成执行计划
    # 2. 逐个执行计划中的任务
    # 3. 实时回调执行日志
    # 4. 可选生成 GIF 动画
    # 5. 保存执行记录
```

### 4.3 LLM 配置

支持多种 AI 服务商：

| 服务商 | 说明 |
|-------|------|
| OpenAI | OpenAI 官方 API |
| Azure OpenAI | Azure OpenAI Service |
| DeepSeek | DeepSeek AI |
| 通义千问 | 阿里云通义千问 |
| 硅基流动 | SiliconFlow API |
| 自定义 | 自定义 API 服务 |

---

## 5. 前端页面设计

### 5.1 页面路由

| 路由路径 | 页面组件 | 说明 |
|---------|---------|------|
| `/ui-automation/dashboard` | Dashboard.vue | 仪表盘 |
| `/ui-automation/projects` | ProjectList.vue | 项目管理 |
| `/ui-automation/elements-enhanced` | ElementManagerEnhanced.vue | 元素管理器 |
| `/ui-automation/test-cases` | TestCaseManager.vue | 测试用例 |
| `/ui-automation/scripts-enhanced` | ScriptEditorEnhanced.vue | 脚本编辑器 |
| `/ui-automation/scripts` | ScriptList.vue | 脚本列表 |
| `/ui-automation/suites` | SuiteList.vue | 测试套件 |
| `/ui-automation/executions` | ExecutionList.vue | 执行记录 |
| `/ui-automation/reports` | ReportList.vue | 测试报告 |
| `/ui-automation/scheduled-tasks` | ScheduledTasks.vue | 定时任务 |
| `/ui-automation/notification-logs` | NotificationLogs.vue | 通知日志 |
| `/ai-intelligent-mode/testing` | AITesting.vue | AI智能测试 |
| `/ai-intelligent-mode/cases` | AICaseList.vue | AI用例 |
| `/ai-intelligent-mode/execution-records` | AIExecutionRecords.vue | AI执行记录 |

### 5.2 仪表盘页面 (Dashboard.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  数据概览                                                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   项目数      │  │   用例数      │  │   套件数     │  │   执行次数    │  │
│  │     12       │  │    256       │  │     35       │  │    1,280     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                                            │
│  最近活动 (50%)              │  快速操作 (50%)                               │
│  ┌────────────────────────┐││┌────────────────────────────────────────┐│
│  │ 👤 张三 创建了元素       ││││ 🟢 项目管理    🔵 元素管理             ││
│  │ 2分钟前                  ││││ 🟡 用例管理    🟣 脚本生成             ││
│  │                          ││││ 🟠 运行测试    🔴 执行记录             ││
│  │ 👤 李四 执行了测试套件   ││││ 🟢 测试报告                           ││
│  │ 15分钟前                 │││└────────────────────────────────────────┘│
│  │                          │││                                              │
│  │ 👤 王五 添加了备用定位器 │││                                              │
│  │ 1小时前                   │││                                              │
│  └────────────────────────┘││                                              │
│                                                                            │
│  核心功能介绍                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ 🔍 元素定位   │  │ ⚙️ 双引擎驱动 │  │ 🌐 多浏览器   │  │ 📧 全平台通知 │  │
│  │ ID/CSS/XPath  │  │ Playwright   │  │ Chrome/Fire  │  │ 企微/飞书/钉 │  │
│  └──────────────┘  │ Selenium      │  │ fox/Edge     │  └──────────────┘  │
│                    └──────────────┘  └──────────────┘                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 元素管理器页面 (ElementManagerEnhanced.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  元素管理器                                                    [+ 新建元素]  │
├─────────────────────────────────────────────────────────────────────────────┤
│  左侧：元素树 (250px)      │  右侧：元素详情                              │
│  ┌───────────────────────┐ │┌─────────────────────────────────────────┐ │
│  │ 🔍 搜索元素...        │ ││ 基本信息                                  │ │
│  ├───────────────────────┤ ││ 名称: [登录按钮__________]                │ │
│  │ 📄 登录页面           │ ││ 类型: [按钮 ▼________]                    │ │
│  │   ├── 🔘 用户名输入框│ ││ 页面: [登录页面____]                      │ │
│  │   ├── 🔘 密码输入框  │ ││                                         │ │
│  │   ├── 🔘 登录按钮    │ ││ 定位配置                                 │ │
│  │   └── 🔘 记住我复选框 │ ││ 策略: [CSS Selector ▼]                   │ │
│  │ 📄 商品列表页面       │ ││ 表达式: [#login-btn_________]             │ │
│  │   ├── 🔘 搜索输入框  │ ││                                         │ │
│  │   ├── 🔘 商品卡片    │ ││ 备用定位器                               │ │
│  │   └── 🔘 加入购物车  │ ││ ┌─────────────────────────────────────┐ │ │
│  │ 📄 购物车页面        │ ││ │ 1. XPath  //button[@class='btn']   │ │ │
│  └───────────────────────┘ ││ │ 2. Text    登录                      │ │ │
│                           ││ └─────────────────────────────────────┘ │ │
│  右键菜单: 添加元素/编辑/删除││                                         │ │
│                           ││ 验证状态: ✓ 有效                         │ │
│                           ││ 使用次数: 15次                           │ │
│                           │└─────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.4 AI 智能测试页面 (AITesting.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AI 智能测试                                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  左侧：任务输入 (50%)          │  右侧：任务列表 (50%)                      │
│  ┌────────────────────────────┐│┌─────────────────────────────────────────┐ │
│  │ 任务描述                    │││ 任务列表                                │ │
│  │ ┌────────────────────────┐ │││                                         │ │
│  │ │                        │ │││ ✅ 1. 打开电商网站首页                  │ │
│  │ │ 请帮我完成以下操作：    │ │││ ✅ 2. 点击登录按钮                     │ │
│  │ │ 1. 打开电商网站        │ │││ ✅ 3. 输入用户名 admin                  │ │
│  │ │ 2. 点击登录按钮        │ │││ ⏳ 4. 输入密码 ***                     │ │
│  │ │ 3. 输入用户名密码      │ │││ ⬜ 5. 点击确认登录                     │ │
│  │ │ 4. 完成登录            │ │││ ⬜ 6. 验证登录成功                    │ │
│  │ │                        │ │││                                         │ │
│  │ └────────────────────────┘ │││                                         │ │
│  │                            │││                                         │ │
│  │ GIF录制: [开] ●───────── │││                                         │ │
│  │                            │││                                         │ │
│  │ [▶ 开始执行] [⏹ 停止]    │││                                         │ │
│  │ [💾 保存为用例]          │││                                         │ │
│  └────────────────────────────┘│└─────────────────────────────────────────┘ │
│                                                                            │
│  执行日志                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ [10:30:01] 🔍 正在打开浏览器...                                    │  │
│  │ [10:30:03] 🌐 已导航到 https://shop.example.com                    │  │
│  │ [10:30:05] ✅ 找到登录按钮                                          │  │
│  │ [10:30:06] 🖱️ 点击登录按钮成功                                     │  │
│  │ [10:30:08] 📝 输入用户名: admin                                     │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.5 脚本编辑器页面 (ScriptEditorEnhanced.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  脚本编辑器                                                    [保存] [运行]  │
├─────────────────────────────────────────────────────────────────────────────┤
│  左侧：元素库 (200px)    │  中间：代码编辑器    │  右侧：日志/元素详情   │
│  ┌───────────────────┐ │┌──────────────────┐│┌──────────────────────────┐│
│  │ 🔍 搜索元素       │ ││ from playwright  │││ [日志] [元素详情]      ││
│  ├───────────────────┤ ││ import locate    │││                         ││
│  │ 📄 登录页面       │ ││                 │││ [10:30] 脚本开始执行   ││
│  │   ├── 用户名输入 │ ││ page.goto(url)  │││ [10:30] 打开页面成功   ││
│  │   ├── 密码输入   │ ││ page.fill(     │││ [10:30] 输入用户名      ││
│  │   ├── 登录按钮   │ ││   "#username",  │││ [10:31] 输入密码        ││
│  │ 📄 商品列表     │ ││   "admin"       │││ [10:31] 点击登录按钮    ││
│  │   ├── 搜索框     │ ││ )              │││ [10:31] ✅ 执行完成     ││
│  │   ├── 商品卡片   │ ││ page.click(    │││                         ││
│  │   └── 加入购物车 │ ││   "#login-btn" │││                         ││
│  └───────────────────┘ ││ )              │││                         ││
│                         │└──────────────────┘││                         ││
│  点击插入到编辑器: [+]   │                     │└──────────────────────────┘│
│                         │  工具栏: 格式化|清除|  │                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. 权限控制设计

### 6.1 权限矩阵

| 资源 | 查看 | 创建 | 编辑 | 删除 | 执行 |
|------|------|------|------|------|------|
| 项目 | 项目成员 | 登录用户 | 项目负责人/成员 | 项目负责人 | - |
| 元素 | 项目成员 | 项目成员 | 项目成员 | 项目成员 | - |
| 脚本 | 项目成员 | 项目成员 | 项目成员 | 项目成员 | 项目成员 |
| 用例 | 项目成员 | 项目成员 | 项目成员 | 项目成员 | 项目成员 |
| 套件 | 项目成员 | 项目成员 | 项目成员 | 项目负责人 | 项目成员 |
| 定时任务 | 创建者 | 登录用户 | 创建者 | 创建者 | 创建者 |

### 6.2 数据访问范围

所有列表查询自动过滤为当前用户有权限访问的资源：

```python
def get_queryset(self):
    user = self.request.user
    return UiProject.objects.filter(
        models.Q(owner=user) | models.Q(members=user)
    ).distinct()
```

---

## 7. 数据库表结构

### 7.1 数据库表清单

| 表名 | 对应模型 | 说明 |
|------|---------|------|
| ui_projects | UiProject | UI自动化项目表 |
| locator_strategies | LocatorStrategy | 定位策略表 |
| ui_element_groups | ElementGroup | 元素分组表 |
| ui_elements | Element | UI元素表 |
| ui_page_objects | PageObject | 页面对象表 |
| ui_page_object_elements | PageObjectElement | 页面对象元素关联表 |
| ui_script_steps | ScriptStep | 脚本步骤表 |
| ui_script_element_usages | ScriptElementUsage | 脚本元素使用记录表 |
| ui_test_scripts | TestScript | 测试脚本表 |
| ui_test_suites | TestSuite | 测试套件表 |
| ui_test_suite_scripts | TestSuiteScript | 套件脚本关联表 |
| ui_test_suite_test_cases | TestSuiteTestCase | 套件用例关联表 |
| ui_test_executions | TestExecution | 测试执行记录表 |
| ui_screenshots | Screenshot | 截图表 |
| ui_test_cases | TestCase | UI测试用例表 |
| ui_test_case_steps | TestCaseStep | 用例步骤表 |
| ui_test_environments | TestEnvironment | 测试环境表 |
| ui_scheduled_tasks | UiScheduledTask | 定时任务表 |
| ui_notification_logs | UiNotificationLog | 通知日志表 |
| ui_task_notification_settings | UiTaskNotificationSetting | 任务通知设置表 |
| ui_ai_cases | AICase | AI测试用例表 |
| ui_ai_execution_records | AIExecutionRecord | AI执行记录表 |
| ui_operation_records | OperationRecord | 操作记录表 |

### 7.2 索引设计

| 表名 | 索引字段 | 类型 |
|------|---------|------|
| ui_elements | project+page, project+element_type, validation_status | 复合/单字段 |
| ui_test_executions | status, created_at | 单字段 |
| ui_operation_records | created_at, resource_type+resource_id | 复合/单字段 |
| ui_ai_execution_records | status, created_at | 单字段 |

---

## 8. 依赖关系

### 8.1 系统依赖

**Python 包**：
- Django 4.2+
- djangorestframework
- django-filter
- playwright (浏览器自动化)
- selenium (浏览器自动化)
- browser-use (AI 智能模式)
- langchain (AI 集成)
- Pillow (图像处理)
- reportlab (PDF 生成)

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
| `apps/ui_automation/__init__.py` | 应用初始化 |
| `apps/ui_automation/apps.py` | Django 应用配置 |
| `apps/ui_automation/models.py` | 数据模型定义（约1060行） |
| `apps/ui_automation/serializers.py` | 序列化器（约940行） |
| `apps/ui_automation/views.py` | 视图实现（约3700+行） |
| `apps/ui_automation/views_config.py` | 配置视图（约530行） |
| `apps/ui_automation/urls.py` | 路由配置 |
| `apps/ui_automation/ai_base.py` | AI 智能模式核心（约1500行） |
| `apps/ui_automation/ai_agent.py` | AI 代理函数 |
| `apps/ui_automation/test_executor.py` | 测试执行引擎 |
| `apps/ui_automation/playwright_engine.py` | Playwright 执行器 |
| `apps/ui_automation/selenium_engine.py` | Selenium 执行器 |
| `apps/ui_automation/variable_resolver.py` | 变量解析器 |
| `apps/ui_automation/operation_logger.py` | 操作日志记录器 |
| `apps/ui_automation/reports.py` | 报告生成器 |
| `apps/ui_automation/pdf_generator.py` | PDF 导出 |
| `apps/ui_automation/admin.py` | Admin 配置 |

### 9.2 前端代码

| 文件路径 | 说明 |
|---------|------|
| `frontend/src/views/ui-automation/index.vue` | 主布局组件 |
| `frontend/src/views/ui-automation/dashboard/Dashboard.vue` | 仪表盘（约1100行） |
| `frontend/src/views/ui-automation/projects/ProjectList.vue` | 项目列表 |
| `frontend/src/views/ui-automation/elements/ElementManagerEnhanced.vue` | 元素管理器增强版 |
| `frontend/src/views/ui-automation/test-cases/TestCaseManager.vue` | 测试用例管理 |
| `frontend/src/views/ui-automation/scripts/ScriptEditorEnhanced.vue` | 脚本编辑器增强版 |
| `frontend/src/views/ui-automation/scripts/ScriptList.vue` | 脚本列表 |
| `frontend/src/views/ui-automation/suites/SuiteList.vue` | 测试套件 |
| `frontend/src/views/ui-automation/executions/ExecutionList.vue` | 执行记录 |
| `frontend/src/views/ui-automation/reports/ReportList.vue` | 报告列表 |
| `frontend/src/views/ui-automation/scheduled-tasks/ScheduledTasks.vue` | 定时任务 |
| `frontend/src/views/ui-automation/notification/NotificationLogs.vue` | 通知日志 |
| `frontend/src/views/ui-automation/notification/NotificationConfigs.vue` | 通知配置 |
| `frontend/src/views/ui-automation/ai/AITesting.vue` | AI智能测试 |
| `frontend/src/views/ui-automation/ai/AICaseList.vue` | AI用例列表 |
| `frontend/src/views/ui-automation/ai/AIExecutionRecords.vue` | AI执行记录 |
| `frontend/src/views/ui-automation/ai/AIExecutionReport.vue` | AI执行报告 |
| `frontend/src/api/ui_automation.js` | 前端API（约1060行） |
| `frontend/src/locales/lang/zh-cn/ui-automation.js` | 中文国际化（约1173行） |
| `frontend/src/locales/lang/en/ui-automation.js` | 英文国际化（约1173行） |

---

## 10. 后续优化建议

### 10.1 功能增强

1. **元素录制**：集成浏览器插件自动录制用户操作生成元素
2. **视觉识别**：基于 AI 的视觉元素识别，降低对定位器的依赖
3. **数据驱动测试**：支持外部数据文件（Excel、CSV）驱动测试
4. **分布式执行**：支持多机器并行执行测试用例
5. **版本控制**：脚本和用例的版本管理与变更历史

### 10.2 性能优化

1. **执行效率**：优化元素定位策略，提升执行速度
2. **并行执行**：支持测试用例并行执行
3. **增量执行**：只执行变更的用例

### 10.3 集成扩展

1. **CI/CD 集成**：Jenkins、GitLab CI、GitHub Actions
2. **缺陷管理集成**：JIRA、禅道等
3. **移动端支持**：扩展到 iOS/Android 应用测试

---

## 11. 附录

### 11.1 术语表

| 术语 | 说明 |
|------|------|
| Page Object | 页面对象模式，将页面封装为对象 |
| Locator | 定位器，用于定位页面元素 |
| Backup Locator | 备用定位器，主定位器失效时使用 |
| Test Suite | 测试套件，包含多个测试用例 |
| AI Execution | AI 智能模式执行 |
| GIF Recording | 执行过程 GIF 动画录制 |

### 11.2 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
