# TestHub AI 需求分析与用例生成模块设计方案

## 1. 模块概述

AI 需求分析与用例生成模块是 TestHub 智能测试管理平台的核心功能之一，提供基于大语言模型（LLM）的智能需求分析和测试用例自动生成能力。该模块支持多种文档格式（PDF、Word、Text、Markdown）的解析，通过 AI 模型深度分析需求文档，自动识别功能点、异常场景和边界条件，生成高质量的测试用例。

### 1.1 设计目标

- **智能文档解析**：支持多种格式的需求文档自动解析和文本提取
- **AI 需求分析**：利用 LLM 自动识别和分类需求，提取功能点
- **用例自动生成**：基于需求自动生成覆盖全面的测试用例
- **AI 评审优化**：AI 专家评审测试用例并提供改进建议
- **流式输出体验**：实时流式展示生成过程，无需等待
- **灵活配置**：支持多种 AI 服务商和自定义提示词

### 1.2 功能架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                   AI 需求分析与用例生成模块                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │
│  │  需求文档  │  │  文档解析  │  │  需求分析  │  │  用例生成  │      │
│  │ Management │  │ Processing │  │ Analysis   │  │Generation │      │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │
│  │   业务需求  │  │  AI 评审  │  │  用例管理  │  │   配置管理  │      │
│  │ Require.   │  │ Review    │  │ Cases     │  │  Config   │      │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     AI 模型服务层                                   │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │   │
│  │  │ DeepSeek   │  │ 通义千问    │  │  硅基流动   │            │   │
│  │  │ Qwen       │  │ SiliconFlow │  │  智谱AI    │            │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 技术选型

| 技术项 | 选型 | 说明 |
|-------|------|------|
| 后端框架 | Django 4.2 + Django REST Framework | 成熟稳定的 Python Web 框架 |
| AI 服务 | httpx + asyncio | 异步调用 OpenAI 兼容 API |
| 文档解析 | PyPDF2 / python-docx | PDF/Word 文档解析 |
| 流式输出 | Server-Sent Events (SSE) | 实时流式响应 |
| 前端框架 | Vue 3 + Element Plus | 现代化组件库 |
| 数据库 | MySQL 8.0+ | 支持 utf8mb4 字符集 |

---

## 2. 数据模型设计

### 2.1 模型关系图

```
RequirementDocument (需求文档)
    │
    └─── RequirementAnalysis (需求分析记录)
              │
              └───< BusinessRequirement (业务需求)
                        │
                        └───< GeneratedTestCase (生成的测试用例)

TestCaseGenerationTask (测试用例生成任务)
    │
    ├─── AIModelConfig (AI模型配置)
    │
    ├─── PromptConfig (提示词配置)
    │
    └─── GenerationConfig (生成行为配置)

AnalysisTask (分析任务)
```

### 2.2 模型详细定义

#### 2.2.1 RequirementDocument (需求文档)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 文档ID |
| title | CharField(200) | 必填 | 文档标题 |
| file | FileField | 必填 | 文档文件 |
| document_type | CharField(10) | 必填 | 文档类型 |
| status | CharField(20) | 默认uploaded | 状态 |
| uploaded_by | ForeignKey(User) | 必填 | 上传者 |
| project | ForeignKey(Project) | 可为空 | 关联项目 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |
| file_size | PositiveIntegerField | 可为空 | 文件大小 |
| extracted_text | TextField | 可为空 | 提取的文本内容 |

**document_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| pdf | PDF文档 | PDF格式文档 |
| docx | Word文档 | Word格式文档 |
| txt | 文本文档 | 纯文本文件 |
| md | Markdown文档 | Markdown格式文档 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| uploaded | 已上传 | 文档刚上传 |
| analyzing | 分析中 | 正在分析 |
| analyzed | 分析完成 | 分析已完成 |
| failed | 分析失败 | 分析出错 |

#### 2.2.2 RequirementAnalysis (需求分析记录)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 分析ID |
| document | OneToOneField | 必填 | 关联文档 |
| analysis_report | TextField | 可为空 | 分析报告 |
| requirements_count | PositiveIntegerField | 默认0 | 需求数量 |
| analysis_time | FloatField | 可为空 | 分析耗时（秒） |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

#### 2.2.3 BusinessRequirement (业务需求)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 需求ID |
| analysis | ForeignKey | 必填 | 关联分析 |
| requirement_id | CharField(50) | 必填 | 需求编号 |
| requirement_name | CharField(200) | 必填 | 需求名称 |
| requirement_type | CharField(20) | 必填 | 需求类型 |
| parent_requirement | ForeignKey(self) | 可为空 | 父级需求 |
| module | CharField(100) | 必填 | 所属模块 |
| requirement_level | CharField(10) | 必填 | 需求级别 |
| reviewer | CharField(50) | 默认admin | 评审人 |
| estimated_hours | PositiveIntegerField | 默认8 | 预计工时 |
| description | TextField | 必填 | 需求描述 |
| acceptance_criteria | TextField | 必填 | 验收标准 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**requirement_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| functional | 功能需求 | 功能性需求 |
| performance | 性能需求 | 性能相关需求 |
| security | 安全需求 | 安全相关需求 |
| usability | 可用性需求 | 可用性相关需求 |
| interface | 接口需求 | 接口相关需求 |
| other | 其他需求 | 其他类型需求 |

**requirement_level 枚举**：

| 值 | 显示名称 |
|----|---------|
| high | 高 |
| medium | 中 |
| low | 低 |

**唯一约束**：`[analysis, requirement_id]`

#### 2.2.4 GeneratedTestCase (生成的测试用例)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 用例ID |
| requirement | ForeignKey | 必填 | 关联需求 |
| case_id | CharField(50) | 必填 | 用例编号 |
| title | CharField(300) | 必填 | 用例标题 |
| priority | CharField(5) | 必填 | 优先级 |
| precondition | TextField | 必填 | 前置条件 |
| test_steps | TextField | 必填 | 测试步骤 |
| expected_result | TextField | 必填 | 预期结果 |
| status | CharField(20) | 默认generated | 状态 |
| generated_by_ai | CharField(50) | 默认AI-A | 生成AI模型 |
| reviewed_by_ai | CharField(50) | 可为空 | 评审AI模型 |
| review_comments | TextField | 可为空 | 评审意见 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**priority 枚举**：

| 值 | 显示名称 |
|----|---------|
| P0 | 最高优先级 |
| P1 | 高优先级 |
| P2 | 中优先级 |
| P3 | 低优先级 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| generated | 已生成 | 刚生成 |
| reviewing | 评审中 | 正在评审 |
| reviewed | 已评审 | 评审完成 |
| approved | 已批准 | 审核通过 |
| rejected | 已拒绝 | 审核拒绝 |
| adopted | 已采纳 | 已被使用 |
| discarded | 已弃用 | 已被废弃 |

**唯一约束**：`[requirement, case_id]`

#### 2.2.5 AnalysisTask (分析任务)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 任务ID |
| task_id | CharField(100) | 唯一 | 任务ID字符串 |
| task_type | CharField(30) | 必填 | 任务类型 |
| document | ForeignKey | 必填 | 关联文档 |
| status | CharField(20) | 默认pending | 状态 |
| progress | PositiveIntegerField | 默认0 | 进度百分比 |
| result | JSONField | 可为空 | 任务结果 |
| error_message | TextField | 可为空 | 错误信息 |
| started_at | DateTimeField | 可为空 | 开始时间 |
| completed_at | DateTimeField | 可为空 | 完成时间 |
| created_at | DateTimeField | 自动 | 创建时间 |

**task_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| requirement_analysis | 需求分析 | 分析需求文档 |
| testcase_generation | 测试用例生成 | 生成测试用例 |
| testcase_review | 测试用例评审 | 评审测试用例 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| pending | 待处理 | 等待执行 |
| running | 运行中 | 正在执行 |
| completed | 已完成 | 执行完成 |
| failed | 失败 | 执行失败 |

#### 2.2.6 AIModelConfig (AI模型配置)

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

**类方法**：

```python
@classmethod
def get_active_config(cls, model_type: str, role: str):
    """获取活跃的配置"""
    return cls.objects.filter(
        model_type=model_type,
        role=role,
        is_active=True
    ).first()
```

#### 2.2.7 PromptConfig (提示词配置)

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

**类方法**：

```python
@classmethod
def get_active_config(cls, prompt_type: str):
    """获取活跃的提示词配置"""
    return cls.objects.filter(
        prompt_type=prompt_type,
        is_active=True
    ).first()
```

#### 2.2.8 GenerationConfig (生成行为配置)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| name | CharField(100) | 必填 | 配置名称 |
| default_output_mode | CharField(10) | 默认stream | 默认输出模式 |
| enable_auto_review | BooleanField | 默认True | 启用AI评审和改进 |
| review_timeout | IntegerField | 默认120秒 | 评审超时时间 |
| is_active | BooleanField | 默认True | 是否启用 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**default_output_mode 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| stream | 实时流式输出 | 边生成边显示 |
| complete | 完整输出 | 生成完成后统一显示 |

#### 2.2.9 TestCaseGenerationTask (测试用例生成任务)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 任务ID |
| task_id | CharField(50) | 唯一 | 任务ID字符串 |
| title | CharField(200) | 必填 | 任务标题 |
| requirement_text | TextField | 必填 | 需求描述 |
| status | CharField(20) | 默认pending | 状态 |
| progress | IntegerField | 默认0 | 进度百分比 |
| output_mode | CharField(10) | 默认stream | 输出模式 |
| stream_buffer | TextField | 可为空 | 流式输出缓冲区 |
| stream_position | IntegerField | 默认0 | 流式输出位置 |
| last_stream_update | DateTimeField | 可为空 | 最后流式更新时间 |
| project | ForeignKey(Project) | 可为空 | 关联项目 |
| writer_model_config | ForeignKey(AIModelConfig) | 可为空 | 编写模型配置 |
| reviewer_model_config | ForeignKey(AIModelConfig) | 可为空 | 评审模型配置 |
| writer_prompt_config | ForeignKey(PromptConfig) | 可为空 | 编写提示词配置 |
| reviewer_prompt_config | ForeignKey(PromptConfig) | 可为空 | 评审提示词配置 |
| generated_test_cases | TextField | 可为空 | 生成的测试用例 |
| review_feedback | TextField | 可为空 | 评审反馈 |
| final_test_cases | TextField | 可为空 | 最终测试用例 |
| generation_log | TextField | 可为空 | 生成日志 |
| error_message | TextField | 可为空 | 错误信息 |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |
| completed_at | DateTimeField | 可为空 | 完成时间 |
| is_saved_to_records | BooleanField | 默认False | 是否已保存到记录 |
| saved_at | DateTimeField | 可为空 | 保存到记录时间 |

**status 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| pending | 等待中 | 等待开始 |
| generating | 生成中 | 正在生成用例 |
| reviewing | 评审中 | 正在AI评审 |
| revising | 改进中 | 正在根据评审改进 |
| completed | 已完成 | 全部完成 |
| failed | 失败 | 执行失败 |
| cancelled | 已取消 | 用户取消 |

---

## 3. AI 模型服务设计

### 3.1 服务架构

AI 模型服务通过 `AIModelService` 类实现，支持多种 OpenAI 兼容格式的 API：

```python
class AIModelService:
    """AI模型服务类"""
    
    @staticmethod
    async def call_openai_compatible_api(config, messages, max_tokens=None):
        """调用 OpenAI 兼容格式的 API"""
        
    @staticmethod
    async def generate_test_cases(task):
        """生成测试用例（完整模式）"""
        
    @staticmethod
    async def review_test_cases(task, test_cases):
        """评审测试用例（完整模式）"""
        
    @staticmethod
    async def generate_test_cases_stream(task, callback=None):
        """流式生成测试用例"""
        
    @staticmethod
    async def review_test_cases_stream(task, test_cases, callback=None):
        """流式评审测试用例"""
        
    @staticmethod
    async def revise_test_cases_based_on_review(task, original, feedback, callback=None):
        """根据评审意见改进测试用例"""
```

### 3.2 支持的 AI 服务商

| 服务商 | Base URL 示例 | 模型名称示例 |
|-------|---------------|-------------|
| DeepSeek | `https://api.deepseek.com` | `deepseek-chat` |
| 通义千问 | `https://dashscope.aliyuncs.com` | `qwen-turbo` |
| 硅基流动 | `https://api.siliconflow.cn` | `deepseek-ai/DeepSeek-V2.5` |
| 智谱 AI | `https://open.bigmodel.cn` | `glm-4-flash` |
| 自定义 | 用户指定 | 用户指定 |

### 3.3 API 调用流程

```
1. 构建消息列表
   messages = [
       {"role": "system", "content": writer_prompt},
       {"role": "user", "content": user_message}
   ]

2. 设置请求头
   headers = {
       'Authorization': f'Bearer {config.api_key}',
       'Content-Type': 'application/json'
   }

3. 构建请求体
   data = {
       'model': config.model_name,
       'messages': messages,
       'max_tokens': config.max_tokens,
       'temperature': config.temperature,
       'top_p': config.top_p,
       'stream': True/False
   }

4. 发送请求并处理响应
```

### 3.4 超时配置

```python
timeout_config = httpx.Timeout(
    connect=60.0,   # 连接超时：60秒
    read=900.0,     # 读取超时：900秒（15分钟）
    write=60.0,      # 写入超时：60秒
    pool=60.0        # 连接池超时：60秒
)
```

---

## 4. 测试用例生成策略

### 4.1 生成指令设计

系统使用精心设计的生成指令，确保测试用例的质量和覆盖率：

```python
user_message = f"""
请深入分析以下需求文档，并设计高覆盖率的测试用例。

【生成指令】
1. 数量原则：根据需求内容复杂度决定用例数量，覆盖所有功能点、异常场景和边界条件
2. 深度遍历策略：按文档结构逐章节分析，对每个功能点设计正常场景+2-3个异常/边界场景
3. 拒绝合并：严禁将多个验证点合并在一条用例中
4. 场景扩展库：
   - 数据完整性（必填项、默认值、数据类型）
   - 业务逻辑约束（状态流转、权限控制、重复操作）
   - 外部接口异常（超时、断网、返回错误）
   - UI交互体验（提示文案、跳转逻辑、防误触）
5. 输出顺序要求：按用例编号从小到大顺序输出
6. 特殊字符处理：管道符使用 HTML 实体 &#124; 代替

【需求文档内容】
{task.requirement_text}
"""
```

### 4.2 用例评审流程

```python
user_message = f"""
请对以下生成的测试用例进行严格的专家级评审。

【评审重点】
1. 覆盖率漏洞：检查是否覆盖异常场景和边界条件
2. 逻辑严密性：检查预期结果是否具体、可验证
3. 冗余检查：指出重复或无效的用例

【待评审用例】
{test_cases}

【输出格式要求】
输出包含评分、问题列表和改进建议的详细评审报告
"""
```

### 4.3 用例自动改进

根据评审意见，AI 自动改进测试用例：

```python
user_message = f"""
请根据以下专家评审意见，改进和完善测试用例。

【原始测试用例】
{original_test_cases}

【评审意见】
{review_feedback}

【改进要求】
1. 严格根据评审意见修改
2. 补充缺失的测试场景
3. 修正不合理的预期结果
4. 删除冗余的测试用例
5. 使用加粗标记新增/修改的内容
"""
```

---

## 5. API 接口设计

### 5.1 路由总览

所有 API 接口前缀：`/api/requirement-analysis/`

| 路由前缀 | ViewSet | 说明 |
|---------|---------|------|
| `documents/` | RequirementDocumentViewSet | 需求文档管理 |
| `analyses/` | RequirementAnalysisViewSet | 需求分析记录 |
| `requirements/` | BusinessRequirementViewSet | 业务需求管理 |
| `test-cases/` | GeneratedTestCaseViewSet | 生成的测试用例 |
| `tasks/` | AnalysisTaskViewSet | 分析任务 |
| `ai-models/` | AIModelConfigViewSet | AI模型配置 |
| `prompts/` | PromptConfigViewSet | 提示词配置 |
| `generation-config/` | GenerationConfigViewSet | 生成行为配置 |
| `testcase-generation/` | TestCaseGenerationTaskViewSet | 测试用例生成任务 |
| `config/` | ConfigStatusViewSet | 配置状态查询 |

**特殊端点**：

| 端点 | 方法 | 说明 |
|------|------|------|
| `upload-and-analyze/` | POST | 上传并分析文档 |
| `analyze-text/` | POST | 分析文本内容 |

### 5.2 需求文档 API (RequirementDocumentViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/requirement-analysis/documents/` | 获取文档列表 |
| POST | `/api/requirement-analysis/documents/` | 上传文档 |
| GET | `/api/requirement-analysis/documents/{id}/` | 获取文档详情 |
| PUT | `/api/requirement-analysis/documents/{id}/` | 更新文档 |
| DELETE | `/api/requirement-analysis/documents/{id}/` | 删除文档 |
| POST | `/api/requirement-analysis/documents/{id}/analyze/` | 分析文档 |

### 5.3 业务需求 API (BusinessRequirementViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/requirement-analysis/requirements/` | 获取需求列表 |
| POST | `/api/requirement-analysis/requirements/` | 创建需求 |
| GET | `/api/requirement-analysis/requirements/{id}/` | 获取需求详情 |
| PUT | `/api/requirement-analysis/requirements/{id}/` | 更新需求 |
| DELETE | `/api/requirement-analysis/requirements/{id}/` | 删除需求 |

### 5.4 测试用例 API (GeneratedTestCaseViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/requirement-analysis/test-cases/` | 获取用例列表 |
| POST | `/api/requirement-analysis/test-cases/` | 创建用例 |
| GET | `/api/requirement-analysis/test-cases/{id}/` | 获取用例详情 |
| PUT | `/api/requirement-analysis/test-cases/{id}/` | 更新用例 |
| DELETE | `/api/requirement-analysis/test-cases/{id}/` | 删除用例 |

### 5.5 测试用例生成 API (TestCaseGenerationTaskViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/requirement-analysis/testcase-generation/` | 获取任务列表 |
| POST | `/api/requirement-analysis/testcase-generation/` | 创建生成任务 |
| GET | `/api/requirement-analysis/testcase-generation/{id}/` | 获取任务详情 |
| POST | `/api/requirement-analysis/testcase-generation/{id}/start/` | 开始生成 |
| POST | `/api/requirement-analysis/testcase-generation/{id}/cancel/` | 取消任务 |
| GET | `/api/requirement-analysis/testcase-generation/{id}/stream/` | 流式获取结果 |
| GET | `/api/requirement-analysis/testcase-generation/{id}/status/` | 获取任务状态 |

### 5.6 AI 模型配置 API (AIModelConfigViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/requirement-analysis/ai-models/` | 获取模型配置列表 |
| POST | `/api/requirement-analysis/ai-models/` | 创建模型配置 |
| GET | `/api/requirement-analysis/ai-models/{id}/` | 获取配置详情 |
| PUT | `/api/requirement-analysis/ai-models/{id}/` | 更新配置 |
| DELETE | `/api/requirement-analysis/ai-models/{id}/` | 删除配置 |
| POST | `/api/requirement-analysis/ai-models/{id}/test/` | 测试连接 |

### 5.7 配置状态 API (ConfigStatusViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/requirement-analysis/config/status/` | 获取配置状态 |

**配置状态响应**：

```json
{
    "writer_model_configured": true,
    "reviewer_model_configured": true,
    "writer_prompt_configured": true,
    "reviewer_prompt_configured": true,
    "generation_configured": true,
    "all_configured": true
}
```

---

## 6. 前端页面设计

### 6.1 页面路由

| 路由路径 | 页面组件 | 说明 |
|---------|---------|------|
| `/requirement-analysis` | RequirementAnalysisView.vue | 需求分析主页面 |
| `/requirement-analysis/generated-cases` | GeneratedTestCaseList.vue | 生成的测试用例列表 |
| `/requirement-analysis/task-detail/:id` | TaskDetail.vue | 任务详情 |
| `/requirement-analysis/ai-model-config` | AIModelConfig.vue | AI 模型配置 |
| `/requirement-analysis/generation-config` | GenerationConfigView.vue | 生成行为配置 |
| `/requirement-analysis/prompt-config` | PromptConfig.vue | 提示词配置 |

### 6.2 需求分析主页面 (RequirementAnalysisView.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AI 需求分析与用例生成                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────┐  ┌─────────────────────────────────────────┐ │
│  │ 文档管理                 │  │ AI 配置状态                              │ │
│  │ [+ 上传文档]            │  │ ✅ 编写模型: DeepSeek Chat            │ │
│  │ ┌───────────────────┐ │  │ ✅ 评审模型: DeepSeek Chat              │ │
│  │ │ 需求文档V1.0.pdf  │ │  │ ✅ 编写提示词: 已配置                   │ │
│  │ │ 2026-04-10 上传   │ │  │ ✅ 评审提示词: 已配置                   │ │
│  │ │ [分析] [查看]      │ │  │                                       │ │
│  │ └───────────────────┘ │  │ [配置 AI 模型]  [配置提示词]            │ │
│  │ ┌───────────────────┐ │  └─────────────────────────────────────────┘ │
│  │ │ 产品需求文档.docx  │ │                                              │
│  │ │ 2026-04-09 上传   │ │  ┌─────────────────────────────────────────┐ │
│  │ │ [分析] [查看]      │ │  │ 快速生成测试用例                         │ │
│  │ └───────────────────┘ │  │                                          │ │
│  └─────────────────────────┘  │ 需求描述:                               │ │
│                               │ ┌─────────────────────────────────────┐ │ │
│  ┌─────────────────────────┐ │ │                                     │ │ │
│  │ 分析结果                 │ │ │ 输入测试需求描述...                  │ │ │
│  │ ┌───────────────────┐ │ │ │                                     │ │ │
│  │ │ REQ001 功能需求   │ │ │ └─────────────────────────────────────┘ │ │
│  │ │  描述: xxx        │ │ │                                          │ │
│  │ │  类型: 功能需求   │ │ │ 输出模式: (●) 流式输出  ( ) 完整输出    │ │
│  │ │  模块: 用户模块   │ │ │ ☑ 自动评审并改进                          │ │
│  │ │  用例数: 12       │ │ │                                          │ │
│  │ │  [查看用例] [生成] │ │ │          [开始生成测试用例]              │ │
│  │ └───────────────────┘ │ │                                          │ │
│  └─────────────────────────┘  └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3 任务详情页面 (TaskDetail.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  测试用例生成任务 - 登录功能测试用例                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  任务信息                          │ 状态: 生成中 (60%)                     │
│  ──────────────────────────────    │ ████████████████░░░░░░  60%          │
│  任务ID: GEN-20260410-001          │                                       │
│  创建时间: 2026-04-10 10:30       │ 耗时: 45秒                           │
│  关联项目: 电商系统                │ 预计剩余: 30秒                         │
├─────────────────────────────────────────────────────────────────────────────┤
│  生成过程                          │ 评审反馈                              │
│  ┌─────────────────────────────┐ │ ┌─────────────────────────────────┐ │
│  │ TC-001 用户名正确格式验证   │ │ │ 评审结果: 优秀                    │ │
│  │ TC-002 用户名为空验证       │ │ │                                  │ │
│  │ TC-003 用户名超长验证       │ │ │ 问题:                           │ │
│  │ TC-004 用户名特殊字符验证   │ │ │ - TC-005 缺少边界值测试         │ │
│  │ TC-005 密码为空验证         │ │ │ - TC-008 预期结果不够具体       │ │
│  │ TC-006 密码错误验证         │ │ │                                  │ │
│  │ TC-007 登录成功验证         │ │ │ 建议:                           │ │
│  │ TC-008 登录失败提示验证     │ │ │ - 补充边界值测试用例             │ │
│  │ TC-009 ...                 │ │ │ - 明确预期结果中的具体文案       │ │
│  └─────────────────────────────┘ │ └─────────────────────────────────┘ │
│                                    │                                       │
│                              [保存到用例库]  [重新生成]                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.4 AI 模型配置页面 (AIModelConfig.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AI 模型配置                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 测试用例编写模型                                                    │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ 配置名称: [DeepSeek Writer________________]                       │   │
│  │ 模型类型: [DeepSeek ▼________________]                           │   │
│  │ API Key:   [sk-xxxxxxxxxxxxxxxx____________]                     │   │
│  │ Base URL:  [https://api.deepseek.com_______]                     │   │
│  │ 模型名称:  [deepseek-chat_________________]                      │   │
│  │ 最大Token: [4096_______]  温度: [0.7____]  Top P: [0.9____]      │   │
│  │                                                                    │   │
│  │                                           [测试连接] [保存]       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 测试用例评审模型                                                    │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ 配置名称: [DeepSeek Reviewer_______________]                       │   │
│  │ 模型类型: [DeepSeek ▼________________]                           │   │
│  │ API Key:   [sk-xxxxxxxxxxxxxxxx____________]                     │   │
│  │ Base URL:  [https://api.deepseek.com_______]                     │   │
│  │ 模型名称:  [deepseek-chat_________________]                      │   │
│  │                                                                    │   │
│  │                                           [测试连接] [保存]       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. 文档解析服务设计

### 7.1 支持的文档格式

| 格式 | 扩展名 | 解析库 |
|------|--------|-------|
| PDF | .pdf | PyPDF2 / pdfplumber |
| Word | .docx | python-docx |
| Word | .doc | python-docx (兼容性) |
| 文本 | .txt | 内置文件读取 |
| Markdown | .md | 内置文件读取 |

### 7.2 解析流程

```python
class DocumentProcessor:
    """文档处理器"""
    
    @staticmethod
    def extract_text(document):
        """从文档中提取文本内容"""
        
        if document.document_type == 'pdf':
            return DocumentProcessor._extract_pdf(document.file)
        elif document.document_type == 'docx':
            return DocumentProcessor._extract_docx(document.file)
        elif document.document_type in ['txt', 'md']:
            return DocumentProcessor._extract_text(document.file)
        else:
            raise ValueError(f"不支持的文档类型: {document.document_type}")
    
    @staticmethod
    def _extract_pdf(file):
        """提取 PDF 文本"""
        
    @staticmethod
    def _extract_docx(file):
        """提取 Word 文档文本"""
        
    @staticmethod
    def _extract_text(file):
        """提取纯文本"""
```

---

## 8. 数据库表结构

### 8.1 数据库表清单

| 表名 | 对应模型 | 说明 |
|------|---------|------|
| requirement_documents | RequirementDocument | 需求文档表 |
| requirement_analyses | RequirementAnalysis | 需求分析记录表 |
| business_requirements | BusinessRequirement | 业务需求表 |
| generated_test_cases | GeneratedTestCase | 生成的测试用例表 |
| analysis_tasks | AnalysisTask | 分析任务表 |
| ai_model_config | AIModelConfig | AI模型配置表 |
| prompt_config | PromptConfig | 提示词配置表 |
| generation_config | GenerationConfig | 生成行为配置表 |
| testcase_generation_task | TestCaseGenerationTask | 测试用例生成任务表 |

### 8.2 索引设计

| 表名 | 索引字段 | 类型 |
|------|---------|------|
| requirement_documents | status, uploaded_by, created_at | 复合/单字段 |
| business_requirements | analysis, requirement_id | 唯一索引 |
| generated_test_cases | requirement, case_id, status | 复合/唯一 |
| analysis_tasks | task_id, task_type, status | 唯一/复合 |
| testcase_generation_task | task_id, status, created_by | 唯一/复合 |

---

## 9. 依赖关系

### 9.1 系统依赖

**Python 包**：
- Django 4.2+
- djangorestframework
- httpx (异步 HTTP 客户端)
- PyPDF2 / pdfplumber (PDF 解析)
- python-docx (Word 文档解析)
- asgiref (异步支持)

**Node.js 包**：
- vue 3.x
- element-plus
- vue-router
- axios

### 9.2 模块间依赖

| 被依赖模块 | 依赖关系 | 说明 |
|-----------|---------|------|
| users | 外键 | User 模型用于 created_by, uploaded_by |
| projects | 外键 | Project 模型用于关联项目 |

---

## 10. 已实现代码清单

### 10.1 后端代码

| 文件路径 | 说明 |
|---------|------|
| `apps/requirement_analysis/__init__.py` | 应用初始化 |
| `apps/requirement_analysis/apps.py` | Django 应用配置 |
| `apps/requirement_analysis/models.py` | 数据模型定义（约1215行） |
| `apps/requirement_analysis/serializers.py` | 序列化器（约280行） |
| `apps/requirement_analysis/views.py` | 视图实现（约3000+行） |
| `apps/requirement_analysis/urls.py` | 路由配置 |
| `apps/requirement_analysis/services.py` | 业务服务层 |
| `apps/requirement_analysis/admin.py` | Admin 配置 |
| `apps/requirement_analysis/advanced_analyzer.py` | 高级分析器 |

### 10.2 前端代码

| 文件路径 | 说明 |
|---------|------|
| `frontend/src/views/requirement-analysis/RequirementAnalysisView.vue` | 需求分析主页面 |
| `frontend/src/views/requirement-analysis/GeneratedTestCaseList.vue` | 生成的测试用例列表 |
| `frontend/src/views/requirement-analysis/TaskDetail.vue` | 任务详情页面 |
| `frontend/src/views/requirement-analysis/AIModelConfig.vue` | AI 模型配置页面 |
| `frontend/src/views/requirement-analysis/GenerationConfigView.vue` | 生成行为配置页面 |
| `frontend/src/views/requirement-analysis/PromptConfig.vue` | 提示词配置页面 |

---

## 11. 后续优化建议

### 11.1 功能增强

1. **多语言支持**：支持生成多语言的测试用例
2. **用例版本管理**：记录用例变更历史
3. **批量导入**：支持批量导入需求文档
4. **自定义模板**：支持用户自定义用例模板
5. **AIGC 评分**：对生成的用例进行质量评分

### 11.2 AI 模型优化

1. **模型对比**：支持同时使用多个模型对比效果
2. **模型微调**：支持自定义微调模型
3. **提示词优化**：提供提示词优化建议
4. **知识库**：构建测试领域知识库

### 11.3 集成扩展

1. **测试平台集成**：与现有测试用例模块无缝对接
2. **CI/CD 集成**：支持触发 CI/CD 流水线
3. **缺陷管理集成**：自动创建缺陷单

---

## 12. 附录

### 12.1 术语表

| 术语 | 说明 |
|------|------|
| LLM | Large Language Model，大语言模型 |
| Prompt | 提示词，用于引导 AI 生成特定内容 |
| Stream | 流式输出，边生成边显示 |
| CoT | Chain of Thought，思维链 |
| SSE | Server-Sent Events，服务端推送事件 |

### 12.2 用例编号规则

系统建议的用例编号格式：

| 前缀 | 示例 | 说明 |
|------|------|------|
| TC | TC-001, TC-002 | Test Case，测试用例 |
| LOGIN | LOGIN_001 | 按功能模块编号 |
| IMMSG | IMMSG001 | 按业务编号 |

### 12.3 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
