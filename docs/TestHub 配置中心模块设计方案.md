# TestHub 配置中心模块设计方案

## 1. 模块概述

配置中心模块是 TestHub 智能测试管理平台的基础配置管理模块，用于集中管理平台中的各类配置信息。该模块涵盖了 AI 服务配置、通知配置、AI 模型配置等多种配置类型，为平台各个功能模块提供统一的配置管理能力。

### 1.1 设计目标

- **集中管理**：统一管理平台各类配置
- **多类型支持**：支持 AI 服务、通知推送、模型配置等多种类型
- **配置灵活**：支持配置启用/禁用、默认值设置
- **安全存储**：敏感配置（如 API Key）安全存储
- **测试连接**：支持配置连接测试

### 1.2 功能架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           配置中心模块                                    │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐         │
│  │ AI服务配置 │ │ 通知配置  │ │ AI模型配置 │ │ Dify配置   │         │
│  │AI Service  │ │Notification│ │AIModel     │ │Dify Config│         │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘         │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     统一配置管理                                    │   │
│  │  配置列表  │  配置详情  │  测试连接  │  设置默认                    │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 技术选型

| 技术项 | 选型 | 说明 |
|-------|------|------|
| 后端框架 | Django 4.2 + Django REST Framework | 成熟稳定的 Python Web 框架 |
| 前端框架 | Vue 3 + Element Plus | 现代化组件库 |
| 数据库 | MySQL 8.0+ | 支持 utf8mb4 字符集 |

---

## 2. 数据模型设计

### 2.1 模型分布

配置中心的配置分散在多个模块中：

| 模型 | 所在模块 | 说明 |
|------|---------|------|
| UnifiedNotificationConfig | apps/core | 统一通知配置 |
| AIServiceConfig | apps/api_testing | API测试 AI服务配置 |
| AIModelConfig | apps/requirement_analysis | AI模型配置 |
| PromptConfig | apps/requirement_analysis | 提示词配置 |
| GenerationConfig | apps/requirement_analysis | 生成行为配置 |
| DifyConfig | apps/assistant | Dify AI助手配置 |

### 2.2 统一通知配置 (UnifiedNotificationConfig)

**模型路径**：`apps/core/models.py`

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| name | CharField(100) | 必填 | 配置名称 |
| config_type | CharField(20) | 默认webhook_feishu | 配置类型 |
| webhook_bots | JSONField | 可为空 | Webhook机器人配置 |
| is_default | BooleanField | 默认False | 是否默认配置 |
| is_active | BooleanField | 默认True | 是否启用 |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**config_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| webhook_feishu | 飞书机器人 | 飞书 Webhook 机器人 |
| webhook_wechat | 企业微信机器人 | 企微 Webhook 机器人 |
| webhook_dingtalk | 钉钉机器人 | 钉钉 Webhook 机器人 |

**webhook_bots JSON 结构**：

```json
{
    "feishu": {
        "name": "测试机器人",
        "webhook_url": "https://open.feishu.cn/...",
        "enabled": true,
        "enable_ui_automation": true,
        "enable_api_testing": true
    },
    "dingtalk": {
        "name": "钉钉机器人",
        "webhook_url": "https://oapi.dingtalk.com/...",
        "secret": "SEC...",
        "enabled": true,
        "enable_ui_automation": true,
        "enable_api_testing": true
    }
}
```

### 2.3 API测试 AI服务配置 (AIServiceConfig)

**模型路径**：`apps/api_testing/models.py`

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| name | CharField(200) | 必填 | 配置名称 |
| service_type | CharField(20) | 必填 | 服务类型 |
| role | CharField(20) | 必填 | 角色类型 |
| api_key | CharField(500) | 必填 | API Key |
| base_url | CharField(500) | 必填 | API Base URL |
| model_name | CharField(200) | 必填 | 模型名称 |
| max_tokens | IntegerField | 默认4096 | 最大Token数 |
| temperature | FloatField | 默认0.7 | 温度参数 |
| is_active | BooleanField | 默认True | 是否启用 |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**service_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| openai | OpenAI | OpenAI GPT 系列 |
| azure | Azure OpenAI | 微软 Azure OpenAI |
| anthropic | Anthropic | Anthropic Claude 系列 |
| deepseek | DeepSeek | DeepSeek 系列模型 |
| qwen | 通义千问 | 阿里云通义千问 |
| siliconflow | 硅基流动 | SiliconFlow API |
| other | 其他 | 其他兼容 API |

**role 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| doc_extractor | API文档提取 | 从文档中提取 API 信息 |
| naming | 参数命名规范化 | 规范化 API 参数命名 |
| mock_data | 模拟数据生成 | 生成 Mock 测试数据 |
| description | 参数描述补全 | 自动补全参数描述 |

### 2.4 AI模型配置 (AIModelConfig)

**模型路径**：`apps/requirement_analysis/models.py`

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| name | CharField(100) | 必填 | 配置名称 |
| model_type | CharField(20) | 必填 | 模型类型 |
| role | CharField(20) | 必填 | 角色 |
| api_key | CharField(200) | 可为空 | API Key |
| base_url | URLField | 必填 | API Base URL |
| model_name | CharField(100) | 必填 | 模型名称 |
| max_tokens | IntegerField | 默认4096 | 最大Token数 |
| temperature | FloatField | 默认0.7 | 温度参数 |
| top_p | FloatField | 默认0.9 | Top P参数 |
| is_active | BooleanField | 默认True | 是否启用 |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**model_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| deepseek | DeepSeek | DeepSeek AI |
| qwen | 通义千问 | 阿里云通义千问 |
| siliconflow | 硅基流动 | SiliconFlow API |
| zhipu | 智谱 | 智谱AI |
| other | 其他 | 其他兼容API |

**role 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| writer | 测试用例编写专家 | 负责生成测试用例 |
| reviewer | 测试评审专家 | 负责评审测试用例 |
| browser_use_text | Browser Use - 文本模式 | 浏览器自动化 |

### 2.5 提示词配置 (PromptConfig)

**模型路径**：`apps/requirement_analysis/models.py`

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| name | CharField(100) | 必填 | 配置名称 |
| prompt_type | CharField(20) | 必填 | 提示词类型 |
| content | TextField | 必填 | 提示词内容 |
| is_active | BooleanField | 默认True | 是否启用 |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**prompt_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| writer | 用例编写提示词 | AI 用例编写专家的角色定义 |
| reviewer | 用例评审提示词 | AI 用例评审专家的角色定义 |

### 2.6 生成行为配置 (GenerationConfig)

**模型路径**：`apps/requirement_analysis/models.py`

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| name | CharField(100) | 必填 | 配置名称 |
| default_output_mode | CharField(10) | 默认stream | 默认输出模式 |
| enable_auto_review | BooleanField | 默认True | 启用AI评审和改进 |
| review_timeout | IntegerField | 默认120 | 评审超时时间（秒） |
| is_active | BooleanField | 默认True | 是否启用 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**default_output_mode 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| stream | 实时流式输出 | 边生成边显示 |
| complete | 完整输出 | 生成完成后统一显示 |

### 2.7 Dify配置 (DifyConfig)

**模型路径**：`apps/assistant/models.py`

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| api_url | URLField(500) | 必填 | Dify API 端点 URL |
| api_key | CharField(500) | 必填 | Dify API 密钥 |
| is_active | BooleanField | 默认True | 是否启用 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

---

## 3. API 接口设计

### 3.1 路由总览

| 模块 | 路由前缀 | ViewSet | 说明 |
|------|---------|---------|------|
| core | `api/core/` | UnifiedNotificationConfigViewSet | 统一通知配置 |
| api_testing | `api/api-testing/` | AIServiceConfigViewSet | API测试 AI服务配置 |
| requirement_analysis | `api/requirement-analysis/` | AIModelConfigViewSet | AI模型配置 |
| requirement_analysis | `api/requirement-analysis/` | PromptConfigViewSet | 提示词配置 |
| requirement_analysis | `api/requirement-analysis/` | GenerationConfigViewSet | 生成行为配置 |
| assistant | `api/assistant/` | DifyConfigViewSet | Dify配置 |

### 3.2 统一通知配置 API

#### UnifiedNotificationConfigViewSet

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/core/notification-configs/` | 获取配置列表 |
| POST | `/api/core/notification-configs/` | 创建配置 |
| GET | `/api/core/notification-configs/{id}/` | 获取配置详情 |
| PUT | `/api/core/notification-configs/{id}/` | 更新配置 |
| DELETE | `/api/core/notification-configs/{id}/` | 删除配置 |
| POST | `/api/core/notification-configs/{id}/set_default/` | 设置为默认 |
| GET | `/api/core/notification-configs/active_configs/` | 获取启用配置 |

### 3.3 AI服务配置 API

#### AIServiceConfigViewSet

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/api-testing/ai-service-configs/` | 获取配置列表 |
| POST | `/api/api-testing/ai-service-configs/` | 创建配置 |
| GET | `/api/api-testing/ai-service-configs/{id}/` | 获取配置详情 |
| PUT | `/api/api-testing/ai-service-configs/{id}/` | 更新配置 |
| DELETE | `/api/api-testing/ai-service-configs/{id}/` | 删除配置 |
| POST | `/api/api-testing/ai-service-configs/test_connection/` | 测试连接 |
| POST | `/api/api-testing/ai-service-configs/complete_parameter_descriptions/` | 自动补全参数描述 |

### 3.4 AI模型配置 API

#### AIModelConfigViewSet

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/requirement-analysis/ai-models/` | 获取配置列表 |
| POST | `/api/requirement-analysis/ai-models/` | 创建配置 |
| GET | `/api/requirement-analysis/ai-models/{id}/` | 获取配置详情 |
| PUT | `/api/requirement-analysis/ai-models/{id}/` | 更新配置 |
| DELETE | `/api/requirement-analysis/ai-models/{id}/` | 删除配置 |
| POST | `/api/requirement-analysis/ai-models/{id}/test/` | 测试连接 |

### 3.5 提示词配置 API

#### PromptConfigViewSet

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/requirement-analysis/prompts/` | 获取配置列表 |
| POST | `/api/requirement-analysis/prompts/` | 创建配置 |
| GET | `/api/requirement-analysis/prompts/{id}/` | 获取配置详情 |
| PUT | `/api/requirement-analysis/prompts/{id}/` | 更新配置 |
| DELETE | `/api/requirement-analysis/prompts/{id}/` | 删除配置 |

### 3.6 Dify配置 API

#### DifyConfigViewSet

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/assistant/config/dify/` | 获取激活配置 |
| POST | `/api/assistant/config/dify/` | 创建配置 |
| PUT | `/api/assistant/config/dify/{id}/` | 更新配置 |
| DELETE | `/api/assistant/config/dify/{id}/` | 删除配置 |
| POST | `/api/assistant/config/dify/test_connection/` | 测试连接 |

---

## 4. 前端页面设计

### 4.1 页面路由

| 路由路径 | 页面组件 | 说明 |
|---------|---------|------|
| `/api-testing/ai-service-config` | AIServiceConfig.vue | API测试 AI服务配置 |
| `/settings/notifications` | (待开发) | 通知配置 |
| `/requirement-analysis/ai-model-config` | (已实现) | AI模型配置 |
| `/requirement-analysis/prompt-config` | (已实现) | 提示词配置 |
| `/assistant` | AssistantView.vue | AI助手（含Dify配置入口） |

### 4.2 AI服务配置页面 (AIServiceConfig.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AI 服务配置                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  [+ 添加配置]                                                             │
│                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │ 配置名称 │服务类型│ 角色类型 │ 模型名称   │ 状态 │ 创建者 │ 操作     │ │
│  ├─────────────────────────────────────────────────────────────────────┤ │
│  │ DeepSeek Writer│DeepSeek│参数描述补全│deepseek-chat│ ✅启用│ 张三 │ │
│  │                                                                [测试]│ │
│  │                                                                [编辑]│ │
│  │                                                                [删除]│ │
│  └─────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  添加/编辑配置                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  配置名称: [________________________]                                       │
│  服务类型: [DeepSeek ▼________________]                                    │
│  角色类型: [参数描述补全 ▼____________]                                    │
│  API Key:   [••••••••••••••••••••______]                                   │
│  API Base URL: [https://api.deepseek.com________]                          │
│  模型名称:  [deepseek-chat______________]                                  │
│  最大Token: [4096_____]  温度: [0.7____]                                  │
│  是否启用:  [●]                                                            │
│                                                                            │
│                              [取消]  [保存]                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 页面功能说明

**配置列表**：
- 显示所有配置，支持按状态筛选
- 显示配置名称、服务类型、角色、模型、状态、创建者、时间
- 支持测试连接、编辑、删除操作

**配置表单**：
- 配置名称（必填）
- 服务类型（必填）：OpenAI/Azure/DeepSeek/通义千问/硅基流动等
- 角色类型（必填）：API文档提取/参数命名/Mock数据/参数描述
- API Key（必填，密码框）
- API Base URL（必填）
- 模型名称（必填）
- 最大Token数（默认4096）
- 温度参数（默认0.7）
- 是否启用（默认启用）

---

## 5. 配置使用场景

### 5.1 通知配置使用

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        通知发送流程                                     │
├─────────────────────────────────────────────────────────────────────────┤
│ 1. 执行任务完成                                                         │
│                                                                          │
│ 2. 获取默认通知配置                                                     │
│    UnifiedNotificationConfig.get_default_config()                       │
│                                                                          │
│ 3. 遍历 webhook_bots                                                   │
│                                                                          │
│ 4. 根据任务类型筛选机器人                                                │
│    - UI自动化任务 → enable_ui_automation=true 的机器人                  │
│    - API测试任务 → enable_api_testing=true 的机器人                     │
│                                                                          │
│ 5. 发送通知到对应平台                                                   │
│    - 飞书 → 调用飞书 Webhook API                                        │
│    - 企微 → 调用企微 Webhook API                                         │
│    - 钉钉 → 调用钉钉 Webhook API（含签名）                               │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 AI服务配置使用

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        AI 服务调用流程                                   │
├─────────────────────────────────────────────────────────────────────────┤
│ 1. 创建 API 请求                                                         │
│                                                                          │
│ 2. 获取对应角色的AI配置                                                  │
│    AIServiceConfig.objects.filter(                                      │
│        role='description',                                              │
│        is_active=True                                                   │
│    ).first()                                                            │
│                                                                          │
│ 3. 构造请求                                                              │
│    headers = {'Authorization': f'Bearer {config.api_key}'}              │
│    payload = {                                                          │
│        'model': config.model_name,                                       │
│        'messages': [...],                                                │
│        'max_tokens': config.max_tokens,                                 │
│        'temperature': config.temperature                                 │
│    }                                                                    │
│                                                                          │
│ 4. 调用 API                                                              │
│    requests.post(f'{config.base_url}/chat/completions',                 │
│                  headers=headers, json=payload)                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 6. 数据库表结构

### 6.1 数据库表清单

| 表名 | 对应模型 | 所在模块 |
|------|---------|---------|
| unified_notification_configs | UnifiedNotificationConfig | core |
| api_ai_service_configs | AIServiceConfig | api_testing |
| ai_model_config | AIModelConfig | requirement_analysis |
| prompt_config | PromptConfig | requirement_analysis |
| generation_config | GenerationConfig | requirement_analysis |
| dify_configs | DifyConfig | assistant |

### 6.2 索引设计

| 表名 | 索引字段 | 类型 |
|------|---------|------|
| unified_notification_configs | config_type | 单字段 |
| unified_notification_configs | is_default | 单字段 |
| api_ai_service_configs | service_type, role | 复合 |
| api_ai_service_configs | is_active | 单字段 |

---

## 7. 依赖关系

### 7.1 系统依赖

**Python 包**：
- Django 4.2+
- djangorestframework
- django-filter
- requests

### 7.2 模块间依赖

| 被依赖模块 | 依赖关系 | 说明 |
|-----------|---------|------|
| users | 外键 | User 模型用于 created_by 字段 |

---

## 8. 已实现代码清单

### 8.1 后端代码

| 文件路径 | 说明 |
|---------|------|
| `apps/core/models.py` | 统一通知配置模型 |
| `apps/core/views.py` | 统一通知配置视图 |
| `apps/core/serializers.py` | 统一通知配置序列化器 |
| `apps/api_testing/models.py` (AIServiceConfig) | AI服务配置模型 |
| `apps/api_testing/views.py` (AIServiceConfigViewSet) | AI服务配置视图 |
| `apps/api_testing/serializers.py` (AIServiceConfigSerializer) | AI服务配置序列化器 |
| `apps/requirement_analysis/models.py` (AIModelConfig, PromptConfig, GenerationConfig) | AI模型/提示词/生成配置 |
| `apps/assistant/models.py` (DifyConfig) | Dify配置模型 |

### 8.2 前端代码

| 文件路径 | 说明 |
|---------|------|
| `frontend/src/views/api-testing/AIServiceConfig.vue` | AI服务配置页面（约290行） |

---

## 9. 后续优化建议

### 9.1 功能增强

1. **配置中心首页**：创建统一的配置中心首页，展示所有配置概览
2. **配置导入导出**：支持配置导出为 JSON/YAML 格式
3. **配置版本管理**：记录配置变更历史
4. **配置模板**：提供常用配置的模板

### 9.2 页面完善

1. **通知配置页面**：开发通知配置管理页面
2. **配置对比**：支持对比不同配置的差异
3. **配置复制**：支持快速复制已有配置

### 9.3 安全增强

1. **配置加密**：对敏感配置进行加密存储
2. **访问日志**：记录配置的访问和修改日志
3. **权限控制**：细粒度的配置访问权限控制

---

## 10. 附录

### 10.1 术语表

| 术语 | 说明 |
|------|------|
| Webhook | Web钩子，用于向第三方服务推送消息 |
| API Key | API密钥，用于身份验证 |
| Base URL | API基础URL |
| Temperature | 温度参数，控制生成的随机性 |
| Max Tokens | 最大Token数，控制生成内容长度 |

### 10.2 通知平台对比

| 平台 | Webhook格式 | 特殊配置 |
|------|------------|---------|
| 飞书 | URL + access_token | 无 |
| 企业微信 | URL + key | 无 |
| 钉钉 | URL + secret | 需要签名验证 |

### 10.3 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
