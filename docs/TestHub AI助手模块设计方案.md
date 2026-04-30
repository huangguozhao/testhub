# TestHub AI 助手模块设计方案

## 1. 模块概述

AI 助手模块是 TestHub 智能测试管理平台的智能对话功能模块，基于 Dify 平台提供智能问答和辅助能力。该模块支持多轮会话、上下文记忆、会话历史管理等功能，帮助测试人员在日常工作中快速获取测试相关问题的解答和辅助。

### 1.1 设计目标

- **智能问答**：基于 Dify LLM 平台提供智能对话服务
- **多轮会话**：支持上下文连续的多轮对话
- **会话管理**：支持会话创建、切换、删除等管理功能
- **历史记录**：保存对话历史，便于回顾和复用
- **配置灵活**：支持配置多个 Dify 应用

### 1.2 功能架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           AI 助手模块                                      │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐         │
│  │  会话管理  │ │  智能对话  │ │  历史记录  │ │  配置管理  │         │
│  │  Sessions  │ │   Chat    │ │  History   │ │   Config   │         │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘         │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                    Dify API 服务                                    │ │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │ │
│  │  │   Chat API   │  │  Session API │  │  Message API │       │ │
│  │  └───────────────┘  └───────────────┘  └───────────────┘       │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 技术选型

| 技术项 | 选型 | 说明 |
|-------|------|------|
| 后端框架 | Django 4.2 + Django REST Framework | 成熟稳定的 Python Web 框架 |
| AI 平台 | Dify | 开源的 LLM 应用开发平台 |
| 外部请求 | requests | Python HTTP 客户端 |
| 前端框架 | Vue 3 + Element Plus | 现代化组件库 |
| 数据库 | MySQL 8.0+ | 支持 utf8mb4 字符集 |

---

## 2. 数据模型设计

### 2.1 模型关系图

```
DifyConfig (Dify配置)
    │
    ▼
AssistantSession (智能助手会话)
    │
    └─── ChatMessage (聊天消息)
```

### 2.2 模型详细定义

#### 2.2.1 DifyConfig (Dify API配置)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 配置ID |
| api_url | URLField(500) | 必填 | Dify API 端点 URL |
| api_key | CharField(500) | 必填 | Dify API 密钥 |
| is_active | BooleanField | 默认True | 是否启用 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**类方法**：

```python
@classmethod
def get_active_config(cls):
    """获取当前激活的配置"""
    return cls.objects.filter(is_active=True).first()
```

#### 2.2.2 AssistantSession (智能助手会话记录)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 会话ID |
| user | ForeignKey(User) | 必填 | 用户 |
| session_id | CharField(200) | 必填 | 会话ID（前端生成） |
| conversation_id | CharField(200) | 可为空 | Dify对话ID（用于多轮会话） |
| title | CharField(500) | 可为空 | 会话标题 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**关联关系**：
- 一个用户可以有多个会话
- 一个会话包含多条聊天消息

#### 2.2.3 ChatMessage (聊天消息记录)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 消息ID |
| session | ForeignKey(AssistantSession) | 必填 | 所属会话 |
| role | CharField(20) | 必填 | 角色 |
| content | TextField | 必填 | 消息内容 |
| conversation_id | CharField(200) | 可为空 | Dify对话ID |
| message_id | CharField(200) | 可为空 | Dify消息ID |
| created_at | DateTimeField | 自动 | 创建时间 |

**role 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| user | 用户 | 用户发送的消息 |
| assistant | 助手 | AI助手的回复 |

---

## 3. API 接口设计

### 3.1 路由总览

所有 API 接口前缀：`/api/assistant/`

| 路由前缀 | ViewSet | 说明 |
|---------|---------|------|
| `sessions/` | AssistantSessionViewSet | 会话管理 |
| `chat/` | ChatViewSet | 聊天功能 |
| `config/dify/` | DifyConfigViewSet | Dify配置管理 |

### 3.2 会话管理 API (AssistantSessionViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/assistant/sessions/` | 获取用户会话列表 |
| POST | `/api/assistant/sessions/` | 创建新会话 |
| GET | `/api/assistant/sessions/{id}/` | 获取会话详情 |
| PUT | `/api/assistant/sessions/{id}/` | 更新会话 |
| DELETE | `/api/assistant/sessions/{id}/` | 删除会话 |
| POST | `/api/assistant/sessions/{id}/add_message/` | 添加消息到会话 |
| GET | `/api/assistant/sessions/{id}/messages/` | 获取会话消息列表 |

#### 创建会话

**POST** `/api/assistant/sessions/`

请求体：

```json
{
    "session_id": "session_1234567890_abc123",
    "title": "关于API测试的问题"
}
```

响应：

```json
{
    "id": 1,
    "session_id": "session_1234567890_abc123",
    "conversation_id": null,
    "title": "关于API测试的问题",
    "created_at": "2026-04-10T10:30:00Z",
    "updated_at": "2026-04-10T10:30:00Z"
}
```

#### 获取会话消息

**GET** `/api/assistant/sessions/{id}/messages/`

响应：

```json
[
    {
        "id": 1,
        "role": "user",
        "content": "如何编写API测试用例？",
        "conversation_id": "conv_xxx",
        "message_id": "msg_xxx",
        "created_at": "2026-04-10T10:30:00Z"
    },
    {
        "id": 2,
        "role": "assistant",
        "content": "编写API测试用例需要注意以下几点...",
        "conversation_id": "conv_xxx",
        "message_id": "msg_yyy",
        "created_at": "2026-04-10T10:30:05Z"
    }
]
```

### 3.3 聊天 API (ChatViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| POST | `/api/assistant/chat/send_message/` | 发送消息并获取回复 |

#### 发送消息

**POST** `/api/assistant/chat/send_message/`

请求体：

```json
{
    "session_id": "session_1234567890_abc123",
    "message": "如何进行性能测试？"
}
```

响应：

```json
{
    "user_message": {
        "id": 1,
        "role": "user",
        "content": "如何进行性能测试？",
        "conversation_id": "conv_xxx",
        "message_id": "msg_user",
        "created_at": "2026-04-10T10:30:00Z"
    },
    "assistant_message": {
        "id": 2,
        "role": "assistant",
        "content": "性能测试主要包括以下几个方面...",
        "conversation_id": "conv_xxx",
        "message_id": "msg_assistant",
        "created_at": "2026-04-10T10:30:05Z"
    },
    "conversation_id": "conv_xxx"
}
```

**请求参数说明**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| session_id | string | 是 | 会话ID |
| message | string | 是 | 消息内容 |

### 3.4 Dify 配置 API (DifyConfigViewSet)

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/assistant/config/dify/` | 获取激活的配置 |
| POST | `/api/assistant/config/dify/` | 创建新配置 |
| PUT | `/api/assistant/config/dify/{id}/` | 更新配置 |
| DELETE | `/api/assistant/config/dify/{id}/` | 删除配置 |
| POST | `/api/assistant/config/dify/test_connection/` | 测试连接 |

#### 测试连接

**POST** `/api/assistant/config/dify/test_connection/`

请求体：

```json
{
    "api_url": "https://api.dify.ai",
    "api_key": "app-xxxxxxxxxxxx"
}
```

响应成功：

```json
{
    "message": "连接成功！",
    "success": true
}
```

响应失败：

```json
{
    "error": "连接失败: 401",
    "detail": "Invalid API key",
    "success": false
}
```

---

## 4. Dify API 集成

### 4.1 API 调用流程

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Dify API 调用流程                                 │
├─────────────────────────────────────────────────────────────────────────┤
│ 1. 构造请求                                                              │
│    POST /chat-messages                                                  │
│    Headers: Authorization: Bearer {api_key}                           │
│    Body: {inputs, query, user, response_mode}                          │
│                                                                          │
│ 2. 发送请求                                                              │
│    requests.post(api_url + '/chat-messages', headers, json=payload)    │
│                                                                          │
│ 3. 处理响应                                                              │
│    - 保存用户消息到数据库                                                 │
│    - 保存助手回复到数据库                                                 │
│    - 更新会话的 conversation_id（首次对话时）                             │
│                                                                          │
│ 4. 返回结果                                                              │
│    {user_message, assistant_message, conversation_id}                   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Dify 请求格式

```python
# 请求头
headers = {
    'Authorization': f'Bearer {dify_config.api_key}',
    'Content-Type': 'application/json'
}

# 请求体
payload = {
    'inputs': {},  # 输入参数（可选）
    'query': message,  # 用户消息
    'user': str(request.user.id),  # 用户标识
    'response_mode': 'blocking'  # 阻塞模式，等待完整响应
}

# 如果有 conversation_id，保持会话连续性
if session.conversation_id:
    payload['conversation_id'] = session.conversation_id
```

### 4.3 多会话支持

系统通过 `conversation_id` 支持多轮会话：
- 首次对话时，Dify 会返回 `conversation_id`
- 后续消息携带 `conversation_id`，Dify 会保持上下文连续性

---

## 5. 前端页面设计

### 5.1 页面路由

| 路由路径 | 页面组件 | 说明 |
|---------|---------|------|
| `/assistant` | AssistantView.vue | AI 助手主页面 |

### 5.2 页面布局

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ┌────────────┐ ┌─────────────────────────────────────────────────────┐   │
│  │            │ │                                                     │   │
│  │  侧边栏     │ │  欢迎页/对话区                                       │   │
│  │            │ │                                                     │   │
│  │ [+新对话]  │ │  ┌───────────────────────────────────────────────┐ │   │
│  │            │ │  │                                               │ │   │
│  │ 历史会话    │ │  │          🤖 智能测试助手                       │ │   │
│  │ ─────────  │ │  │                                               │ │   │
│  │ 💬 会话1   │ │  │    我可以帮你解答测试相关的问题...              │ │   │
│  │ 💬 会话2   │ │  │                                               │ │   │
│  │ 💬 会话3   │ │  └───────────────────────────────────────────────┘ │   │
│  │            │ │                                                     │   │
│  │            │ │  ┌───────────────────────────────────────────────┐ │   │
│  │            │ │  │ 请输入您的问题...                      [发送] │ │   │
│  │ ─────────  │ │  └───────────────────────────────────────────────┘ │   │
│  │            │ │                                                     │   │
│  │ 用户信息    │ │  ┌───┐ ┌───┐ ┌───┐ ┌───┐                      │   │
│  │ [头像] 用户│ │  │建议1│ │建议2│ │建议3│ │建议4│                 │   │
│  └────────────┘ │  └───┘ └───┘ └───┘ └───┘                      │   │
│                  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 页面组件说明

**侧边栏**：
- 新建对话按钮
- 历史会话列表（按更新时间倒序）
- 会话项：显示标题、删除按钮
- 用户信息（头像、用户名）

**欢迎页**：
- Logo 和标题
- 功能介绍
- 建议问题快捷按钮
- 居中输入框

**对话页**：
- 顶部：会话标题、更新时间
- 中部：消息列表（用户/助手消息气泡）
- 底部：输入框、发送按钮

### 5.4 消息展示

```javascript
// 格式化消息内容（支持 Markdown）
const formatMessageContent = (content) => {
    return content
        .replace(/\n/g, '<br>')
        .replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>')
        .replace(/`([^`]+)`/g, '<code>$1</code>')
}
```

### 5.5 消息发送流程

```
1. 用户输入消息并点击发送
   ↓
2. 创建临时会话（如果需要）
   ↓
3. 保存用户消息到前端状态（立即显示）
   ↓
4. 添加"思考中..."提示
   ↓
5. 调用 POST /assistant/chat/send_message/
   ↓
6. 收到响应后：
   - 移除"思考中"提示
   - 替换为真实助手回复
   - 保存消息到历史
   ↓
7. 滚动到最新消息
```

---

## 6. 会话管理逻辑

### 6.1 会话创建流程

```javascript
const sendMessage = async () => {
    // 1. 如果是新会话（没有ID），先创建会话
    if (!sessionId) {
        const newSessionId = `session_${Date.now()}_${randomId()}`
        const title = text.length > 10 ? text.substring(0, 10) + '...' : text
        
        const response = await api.post('/assistant/sessions/', {
            session_id: newSessionId,
            title: title
        })
        
        currentSession.value = response.data
        sessionId = currentSession.value.session_id
    }
    
    // 2. 发送消息
    const response = await api.post('/assistant/chat/send_message/', {
        session_id: sessionId,
        message: text
    })
    
    // 3. 更新会话信息
    if (response.data.conversation_id) {
        currentSession.value.conversation_id = response.data.conversation_id
    }
}
```

### 6.2 会话历史加载

```javascript
// 加载历史会话列表
const loadHistory = async () => {
    const response = await api.get('/assistant/sessions/')
    historySessions.value = response.data.results || []
}

// 加载会话消息
const switchToSession = async (session) => {
    currentSession.value = { ...session }
    const response = await api.get(`/assistant/sessions/${session.id}/messages/`)
    messages.value = response.data
}
```

### 6.3 会话删除

```javascript
const deleteSession = async (sessionId) => {
    await api.delete(`/assistant/sessions/${sessionId}/`)
    historySessions.value = historySessions.value.filter(s => s.id !== sessionId)
    
    if (currentSession.value?.id === sessionId) {
        startNewChat()
    }
}
```

---

## 7. 数据库表结构

### 7.1 数据库表清单

| 表名 | 对应模型 | 说明 |
|------|---------|------|
| dify_configs | DifyConfig | Dify API配置表 |
| assistant_sessions | AssistantSession | 智能助手会话表 |
| chat_messages | ChatMessage | 聊天消息表 |
| assistant_messages | AssistantMessage | 智能助手消息表（保留，向后兼容） |

### 7.2 表结构

```sql
-- Dify配置表
CREATE TABLE `dify_configs` (
    `id` bigint AUTO_INCREMENT PRIMARY KEY,
    `api_url` varchar(500) NOT NULL,
    `api_key` varchar(500) NOT NULL,
    `is_active` tinyint(1) DEFAULT TRUE,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 智能助手会话表
CREATE TABLE `assistant_sessions` (
    `id` bigint AUTO_INCREMENT PRIMARY KEY,
    `user_id` int NOT NULL,
    `session_id` varchar(200) NOT NULL,
    `conversation_id` varchar(200) DEFAULT NULL,
    `title` varchar(500) DEFAULT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    INDEX `assistant_sessions_user_id_idx` (`user_id`),
    INDEX `assistant_sessions_session_id_idx` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 聊天消息表
CREATE TABLE `chat_messages` (
    `id` bigint AUTO_INCREMENT PRIMARY KEY,
    `session_id` bigint NOT NULL,
    `role` varchar(20) NOT NULL,
    `content` longtext NOT NULL,
    `conversation_id` varchar(200) DEFAULT NULL,
    `message_id` varchar(200) DEFAULT NULL,
    `created_at` datetime(6) NOT NULL,
    INDEX `chat_messages_session_id_idx` (`session_id`),
    INDEX `chat_messages_created_at_idx` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 8. 依赖关系

### 8.1 系统依赖

**Python 包**：
- Django 4.2+
- djangorestframework
- requests (HTTP 客户端)

### 8.2 模块间依赖

| 被依赖模块 | 依赖关系 | 说明 |
|-----------|---------|------|
| users | 外键 | User 模型用于 user 字段 |

---

## 9. 已实现代码清单

### 9.1 后端代码

| 文件路径 | 说明 |
|---------|------|
| `apps/assistant/__init__.py` | 应用初始化 |
| `apps/assistant/apps.py` | Django 应用配置 |
| `apps/assistant/models.py` | 数据模型定义（约90行） |
| `apps/assistant/serializers.py` | 序列化器（约40行） |
| `apps/assistant/views.py` | 会话和聊天视图（约160行） |
| `apps/assistant/views_config.py` | Dify配置视图（约110行） |
| `apps/assistant/urls.py` | 路由配置 |
| `apps/assistant/admin.py` | Admin 配置 |

### 9.2 前端代码

| 文件路径 | 说明 |
|---------|------|
| `frontend/src/views/assistant/AssistantView.vue` | AI 助手主页面（约830行） |

---

## 10. 后续优化建议

### 10.1 功能增强

1. **流式响应**：支持 Server-Sent Events 流式输出
2. **文件上传**：支持上传截图、文档等辅助内容
3. **会话导出**：支持将会话导出为 Markdown 或 PDF
4. **会话分享**：支持分享会话链接

### 10.2 集成扩展

1. **知识库集成**：对接 Dify 知识库，提供文档问答
2. **多 AI 模型**：支持配置多个 AI 模型（Dify 应用）
3. **Webhook**：支持 webhook 回调通知

### 10.3 用户体验优化

1. **快捷指令**：预设常用快捷指令
2. **消息草稿**：自动保存未发送的消息草稿
3. **深色模式**：支持深色模式切换

---

## 11. 附录

### 11.1 术语表

| 术语 | 说明 |
|------|------|
| Dify | 开源的 LLM 应用开发平台，支持构建 AI 应用 |
| conversation_id | Dify 对话 ID，用于保持多轮会话上下文 |
| session_id | 前端会话 ID，用于标识用户会话 |
| blocking | 阻塞模式，等待 AI 生成完整响应后返回 |

### 11.2 Dify API 端点

| 端点 | 方法 | 说明 |
|------|------|------|
| `/chat-messages` | POST | 发送聊天消息 |

### 11.3 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
