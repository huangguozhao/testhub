# TestHub 测试用例管理（手工测试）模块设计方案

## 文档概述

测试用例管理模块是 TestHub 平台的核心功能模块之一，负责手工测试用例的全生命周期管理。该模块的核心目标是：

1. 测试用例标准化管理：支持创建、编辑、删除、查看测试用例
2. 结构化测试步骤：支持多步骤测试用例，每步骤包含操作和预期结果
3. 用例复用与组织：通过版本、标签、测试类型等维度组织用例
4. 团队协作：支持指派负责人、附件上传、评论讨论
5. 权限隔离：确保用户只能访问有权限参与的项目中的用例

------

## 一、功能需求

### 1.1 功能列表

| 功能点 | 优先级 | 描述 |
| :--- | :----- | :--- |
| 用例列表查询 | P0 | 分页查看测试用例，支持搜索、筛选、排序 |
| 用例创建 | P0 | 创建新的测试用例，设置标题、描述、步骤、优先级等 |
| 用例详情查看 | P0 | 查看用例完整信息，包括步骤、附件、评论 |
| 用例编辑 | P0 | 修改测试用例的各字段信息 |
| 用例删除 | P0 | 删除测试用例（级联删除关联数据） |
| 测试步骤管理 | P0 | 添加、编辑、删除测试步骤（操作+预期结果） |
| 附件上传 | P1 | 上传用例相关的附件（截图、文档等） |
| 附件下载 | P1 | 下载用例附件 |
| 评论功能 | P1 | 对用例进行评论讨论 |
| 版本关联 | P1 | 用例关联多个版本，支持版本筛选 |
| 标签管理 | P1 | 用例标签（JSON数组格式） |
| 指派负责人 | P2 | 指派用例给特定成员 |
| 批量操作 | P2 | 批量删除、批量更新状态 |

### 1.2 优先级枚举

| 值 | 描述 | 说明 |
| :--- | :--- | :--- |
| low | 低 | 低优先级测试用例 |
| medium | 中 | 中等优先级测试用例 |
| high | 高 | 高优先级测试用例 |
| critical | 紧急 | 紧急优先级测试用例 |

### 1.3 状态枚举

| 值 | 描述 | 说明 |
| :--- | :--- | :--- |
| draft | 草稿 | 用例正在编写中 |
| active | 激活 | 用例已审核通过，可执行 |
| deprecated | 废弃 | 用例已废弃，不再使用 |

### 1.4 测试类型枚举

| 值 | 描述 | 说明 |
| :--- | :--- | :--- |
| functional | 功能测试 | 功能验证测试 |
| integration | 集成测试 | 模块集成测试 |
| api | API测试 | 接口测试 |
| ui | UI测试 | 界面测试 |
| performance | 性能测试 | 性能相关测试 |
| security | 安全测试 | 安全相关测试 |

------

## 二、数据模型

### 2.1 测试用例模型 (TestCase)

```python
class TestCase(models.Model):
    """测试用例模型"""
    PRIORITY_CHOICES = [
        ('low', '低'),
        ('medium', '中'),
        ('high', '高'),
        ('critical', '紧急'),
    ]
    
    STATUS_CHOICES = [
        ('draft', '草稿'),
        ('active', '激活'),
        ('deprecated', '废弃'),
    ]
    
    TYPE_CHOICES = [
        ('functional', '功能测试'),
        ('integration', '集成测试'),
        ('api', 'API测试'),
        ('ui', 'UI测试'),
        ('performance', '性能测试'),
        ('security', '安全测试'),
    ]
    
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='testcases')
    versions = models.ManyToManyField(Version, blank=True, related_name='testcases', verbose_name='关联版本')
    title = models.CharField(max_length=500, verbose_name='用例标题')
    description = models.TextField(blank=True, verbose_name='用例描述')
    preconditions = models.TextField(blank=True, verbose_name='前置条件')
    steps = models.TextField(blank=True, max_length=1000, verbose_name='操作步骤')
    expected_result = models.TextField(verbose_name='预期结果')
    priority = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default='medium', verbose_name='优先级')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft', verbose_name='状态')
    test_type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='functional', verbose_name='测试类型')
    tags = models.JSONField(default=list, verbose_name='标签')
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='authored_testcases', verbose_name='作者')
    assignee = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_testcases', verbose_name='指派人')
    created_at = models.DateTimeField(default=timezone.now, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
```

### 2.2 测试用例步骤模型 (TestCaseStep)

```python
class TestCaseStep(models.Model):
    """测试用例步骤"""
    testcase = models.ForeignKey(TestCase, on_delete=models.CASCADE, related_name='step_details')
    step_number = models.PositiveIntegerField(verbose_name='步骤序号')
    action = models.TextField(verbose_name='操作')
    expected = models.TextField(verbose_name='预期结果')
    
    class Meta:
        unique_together = ['testcase', 'step_number']  # 确保步骤序号唯一
```

### 2.3 测试用例附件模型 (TestCaseAttachment)

```python
class TestCaseAttachment(models.Model):
    """测试用例附件"""
    testcase = models.ForeignKey(TestCase, on_delete=models.CASCADE, related_name='attachments')
    name = models.CharField(max_length=255, verbose_name='附件名称')
    file = models.FileField(upload_to='testcase_attachments/', verbose_name='文件')
    uploaded_by = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name='上传者')
    uploaded_at = models.DateTimeField(default=timezone.now, verbose_name='上传时间')
```

### 2.4 测试用例评论模型 (TestCaseComment)

```python
class TestCaseComment(models.Model):
    """测试用例评论"""
    testcase = models.ForeignKey(TestCase, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name='评论者')
    content = models.TextField(verbose_name='评论内容')
    created_at = models.DateTimeField(default=timezone.now, verbose_name='评论时间')
```

### 2.5 数据模型关系图

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                           测试用例数据模型关系                                │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌────────────────────────────────────────────────────────────────────────┐

    │                           用户 (User)                                   │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
              ┌──────────────────────────┼──────────────────────────┐
              │                          │                          │
              ▼                          ▼                          ▼
    ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
    │   author        │      │   assignee     │      │   uploaded_by  │
    │  (创建者)       │      │  (指派人)       │      │  (上传者)      │
    └─────────────────┘      └─────────────────┘      └─────────────────┘
              │                          │                          │
              └──────────────────────────┼──────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                          TestCase (测试用例)                            │

    │                                                                        │
    │  - title          : 用例标题                                            │
    │  - description    : 用例描述                                            │
    │  - preconditions  : 前置条件                                            │
    │  - steps          : 操作步骤 (旧字段)                                   │
    │  - expected_result: 预期结果                                            │
    │  - priority       : 优先级 (low/medium/high/critical)                   │
    │  - status         : 状态 (draft/active/deprecated)                      │
    │  - test_type      : 测试类型 (functional/api/ui/...)                    │
    │  - tags           : 标签 (JSON数组)                                     │
    │                                                                        │
    └────────────────────────────────────────────────────────────────────────┘
                     │                                        │
          ┌──────────┼──────────┐                    ┌────────┼────────┐
          │          │          │                    │        │        │
          ▼          ▼          ▼                    ▼        ▼        ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐  ┌──────────┐ ┌──────┐ ┌──────────┐
    │TestCase  │ │TestCase  │ │TestCase  │  │ TestCase │ │      │ │TestCase  │
    │Step      │ │Attachment│ │Comment   │  │ Version  │ │      │ │ (M2M)   │
    │(步骤)    │ │(附件)    │ │(评论)    │  │ (版本)   │ │      │ │          │
    └──────────┘ └──────────┘ └──────────┘  └──────────┘ └──────┘ └──────────┘
          │          │          │               │
          ▼          ▼          ▼               ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
    │ step_num │ │ file     │ │ content  │ │  Version │
    │ action   │ │ name     │ │ author   │ │ (版本表) │
    │ expected │ │ uploaded │ │ created  │ └──────────┘
    └──────────┘ └──────────┘ └──────────┘
```

### 2.6 与项目和版本的关系

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                        测试用例与项目、版本的关系                            │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐
    │     Project      │
    │    (项目)        │
    │                 │
    │  - name        │
    │  - owner       │
    │                 │
    └────────┬────────┘
             │
             │ 1:N (级联删除)
             │
             ▼
    ┌─────────────────┐
    │    TestCase     │
    │   (测试用例)    │
    │                 │
    │  - title       │
    │  - status      │
    │  - priority    │
    │  - ...         │
    │                 │
    └────────┬────────┘
             │
             │ M:N (ManyToMany)
             │
             ▼
    ┌─────────────────┐
    │     Version     │
    │    (版本)       │
    │                 │
    │  - name        │
    │  - is_baseline │
    │  - ...         │
    └─────────────────┘
```

------

## 三、关键流程

### 3.1 测试用例创建流程

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                              用例创建流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │  填写用例信息  │
    │ 标题/描述/   │
    │ 步骤/优先级  │
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ 前端表单验证  │ ──► 标题非空、优先级有效
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ 发送创建请求 │
    │ POST /testcases/
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         后端处理                                        │

    │                                                                        │

    │  1. 权限验证：检查用户是否已登录                                       │

    │  2. 获取用户有权限的项目                                               │

    │  3. 检查 project_id 是否有效且用户有权限                               │

    │  4. 若无有效项目，自动创建"默认项目"                                  │

    │  5. 创建用例记录，自动设置 author = 当前用户                          │

    │  6. 处理版本关联 (version_ids)                                         │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐
    │ 返回用例详情 │
    │ 201 Created │
    └─────────────┘
```

### 3.2 测试用例列表查询流程

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                            用例列表查询流程                                  │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │ 访问用例列表 │
    │ GET /testcases/
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         权限过滤                                        │

    │                                                                        │

    │  SELECT * FROM testcases                                                │

    │  WHERE project_id IN (                                                  │

    │    SELECT id FROM projects                                              │

    │    WHERE owner = current_user                                          │

    │       OR id IN (SELECT project_id FROM project_members                 │

    │                  WHERE user_id = current_user)                         │

    │  )                                                                     │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
    │ 搜索过滤    │ ──► │ 字段筛选    │ ──► │ 排序处理    │
    │ title/desc  │     │ priority    │     │ -created_at │
    │             │     │ test_type   │     │ -updated_at │
    └─────────────┘     │ project     │     │ priority    │
                        └─────────────┘     └──────┬──────┘
                                                   │
                                                   ▼
                                           ┌─────────────┐
                                           │ 分页处理    │
                                           │ page=1     │
                                           │ page_size=10│
                                           │ max=100    │
                                           └──────┬──────┘
                                                  │
                                                  ▼
                                          ┌─────────────┐
                                          │ 返回分页结果 │
                                          │             │
                                          │ count       │
                                          │ results[]   │
                                          │ next/prev   │
                                          └─────────────┘
```

### 3.3 测试用例详情查询流程

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                            用例详情查询流程                                  │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │ 访问用例详情 │
    │ GET /testcases/{id}/
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         权限检查                                        │

    │                                                                        │

    │  1. 获取当前用户                                                         │

    │  2. 获取用例关联的项目                                                   │

    │  3. 检查用户是否是项目 owner 或 member                                    │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         预加载优化                                        │

    │                                                                        │

    │  select_related:                                                        │

    │    - author (创建者)                                                    │

    │    - assignee (指派人)                                                  │

    │    - project (项目)                                                     │

    │                                                                        │

    │  prefetch_related:                                                      │

    │    - versions (版本列表)                                                │

    │    - step_details (步骤列表)                                            │

    │    - attachments (附件列表)                                             │

    │    - comments (评论列表)                                                │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐
    │ 返回完整详情 │
    │ 200 OK     │
    └─────────────┘
```

### 3.4 测试用例更新流程

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                              用例更新流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │ 发送更新请求 │
    │ PUT/PATCH   │
    │ /testcases/{id}/
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         后端处理                                        │

    │                                                                        │

    │  PUT (全量更新):                                                        │

    │    - 验证所有必填字段                                                   │

    │    - 更新所有字段                                                       │

    │    - 处理 version_ids                                                   │

    │                                                                        │

    │  PATCH (部分更新):                                                      │

    │    - 只验证提交的字段                                                   │

    │    - 更新提交的字段                                                     │

    │    - 处理 version_ids (如果有)                                           │

    │                                                                        │

    │  项目变更处理:                                                          │

    │    - 如果提交了 project_id 且有效且用户有权限，更新项目                  │

    │    - 否则保持原项目不变                                                  │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐
    │ 返回更新结果 │
    │ 200 OK     │
    └─────────────┘
```

### 3.5 测试用例删除流程

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                              用例删除流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │ 发送删除请求 │
    │ DELETE      │
    │ /testcases/{id}/
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         级联删除                                        │

    │                                                                        │

    │  Django on_delete=models.CASCADE 自动处理:                              │

    │                                                                        │

    │  1. 删除 TestCase (测试用例)                                            │

    │     └─► 2. 删除 TestCaseStep (测试步骤) - related_name='step_details'  │

    │     └─► 3. 删除 TestCaseAttachment (附件) - related_name='attachments' │

    │     └─► 4. 删除 TestCaseComment (评论) - related_name='comments'      │

    │                                                                        │

    │  5. 断开与 Version 的 ManyToMany 关联                                   │

    │                                                                        │

    │  6. 删除文件 (需要手动处理 FileField)                                   │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐
    │ 返回删除结果 │
    │ 204 No Content │
    └─────────────┘
```

------

## 四、接口设计

### 4.1 测试用例列表接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/testcases/` |
| Method | `GET` |
| 认证 | 需要认证 |

**Query Parameters**

| 参数 | 类型 | 描述 |
| :--- | :--- | :--- |
| page | int | 页码 (默认 1) |
| page_size | int | 每页数量 (默认 10，最大 100) |
| search | string | 搜索关键词 (可选，搜索 title/description) |
| priority | string | 优先级筛选 (可选: low/medium/high/critical) |
| test_type | string | 测试类型筛选 (可选: functional/integration/api/ui/performance/security) |
| project | int | 项目ID筛选 (可选) |
| ordering | string | 排序字段 (可选: -created_at/created_at/-updated_at/updated_at/priority) |

**Success Response (200 OK)**

```json
{
  "count": 100,
  "next": "http://api.example.com/testcases/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "title": "用户登录功能测试",
      "description": "验证用户登录功能是否正常",
      "preconditions": "1. 用户已注册\n2. 系统正常运行",
      "steps": "1. 打开登录页面\n2. 输入用户名密码\n3. 点击登录按钮",
      "expected_result": "登录成功，跳转到首页",
      "priority": "high",
      "test_type": "functional",
      "tags": ["登录", "核心功能"],
      "author": {
        "id": 1,
        "username": "zhangsan"
      },
      "assignee": {
        "id": 2,
        "username": "lisi"
      },
      "project": {
        "id": 1,
        "name": "电商平台测试"
      },
      "versions": [
        {
          "id": 1,
          "name": "V1.0",
          "is_baseline": true
        }
      ],
      "created_at": "2026-04-01T10:00:00Z",
      "updated_at": "2026-04-10T10:00:00Z"
    }
  ]
}
```

### 4.2 创建测试用例接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/testcases/` |
| Method | `POST` |
| 认证 | 需要认证 |

**Request Body**

```json
{
  "title": "用户登录功能测试",
  "description": "验证用户登录功能是否正常",
  "preconditions": "1. 用户已注册\n2. 系统正常运行",
  "steps": "1. 打开登录页面\n2. 输入用户名密码\n3. 点击登录按钮",
  "expected_result": "登录成功，跳转到首页",
  "priority": "high",
  "test_type": "functional",
  "tags": ["登录", "核心功能"],
  "project_id": 1,
  "version_ids": [1, 2]
}
```

| 字段 | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| title | string | 是 | 用例标题 (最大500字符) |
| description | string | 否 | 用例描述 |
| preconditions | string | 否 | 前置条件 |
| steps | string | 否 | 操作步骤 |
| expected_result | string | 是 | 预期结果 |
| priority | string | 否 | 优先级 (默认 medium) |
| test_type | string | 否 | 测试类型 (默认 functional) |
| tags | array | 否 | 标签列表 |
| project_id | int | 否 | 项目ID，不填则使用第一个可访问项目 |
| version_ids | array | 否 | 关联版本ID列表 |

**Success Response (201 Created)**

```json
{
  "id": 1,
  "title": "用户登录功能测试",
  "description": "验证用户登录功能是否正常",
  "preconditions": "1. 用户已注册\n2. 系统正常运行",
  "steps": "1. 打开登录页面\n2. 输入用户名密码\n3. 点击登录按钮",
  "expected_result": "登录成功，跳转到首页",
  "priority": "high",
  "test_type": "functional",
  "status": "draft",
  "tags": ["登录", "核心功能"],
  "author": {
    "id": 1,
    "username": "zhangsan"
  },
  "assignee": null,
  "project": {
    "id": 1,
    "name": "电商平台测试"
  },
  "versions": [
    {
      "id": 1,
      "name": "V1.0",
      "is_baseline": true
    },
    {
      "id": 2,
      "name": "V1.1",
      "is_baseline": false
    }
  ],
  "step_details": [],
  "attachments": [],
  "comments": [],
  "created_at": "2026-04-10T10:00:00Z",
  "updated_at": "2026-04-10T10:00:00Z"
}
```

**Error Response (400 Bad Request)**

```json
{
  "title": ["这个字段是必填项。"],
  "expected_result": ["这个字段是必填项。"]
}
```

### 4.3 测试用例详情接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/testcases/<id>/` |
| Method | `GET` |
| 认证 | 需要认证 |

**Success Response (200 OK)**

```json
{
  "id": 1,
  "title": "用户登录功能测试",
  "description": "验证用户登录功能是否正常",
  "preconditions": "1. 用户已注册\n2. 系统正常运行",
  "steps": "1. 打开登录页面\n2. 输入用户名密码\n3. 点击登录按钮",
  "expected_result": "登录成功，跳转到首页",
  "priority": "high",
  "test_type": "functional",
  "status": "draft",
  "tags": ["登录", "核心功能"],
  "author": {
    "id": 1,
    "username": "zhangsan",
    "email": "zhangsan@example.com"
  },
  "assignee": {
    "id": 2,
    "username": "lisi",
    "email": "lisi@example.com"
  },
  "project": {
    "id": 1,
    "name": "电商平台测试"
  },
  "versions": [
    {
      "id": 1,
      "name": "V1.0",
      "is_baseline": true
    }
  ],
  "step_details": [
    {
      "id": 1,
      "testcase": 1,
      "step_number": 1,
      "action": "打开登录页面",
      "expected": "显示用户名和密码输入框"
    },
    {
      "id": 2,
      "testcase": 1,
      "step_number": 2,
      "action": "输入正确的用户名和密码",
      "expected": "输入框显示输入的内容"
    },
    {
      "id": 3,
      "testcase": 1,
      "step_number": 3,
      "action": "点击登录按钮",
      "expected": "登录成功，跳转到首页"
    }
  ],
  "attachments": [
    {
      "id": 1,
      "name": "登录页面截图.png",
      "file": "/media/testcase_attachments/login.png",
      "uploaded_by": {
        "id": 1,
        "username": "zhangsan"
      },
      "uploaded_at": "2026-04-10T11:00:00Z"
    }
  ],
  "comments": [
    {
      "id": 1,
      "content": "建议增加密码错误时的提示信息测试",
      "author": {
        "id": 2,
        "username": "lisi"
      },
      "created_at": "2026-04-10T12:00:00Z"
    }
  ],
  "created_at": "2026-04-10T10:00:00Z",
  "updated_at": "2026-04-10T12:00:00Z"
}
```

**Error Response (404 Not Found)**

```json
{
  "detail": "未找到。"
}
```

### 4.4 更新测试用例接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/testcases/<id>/` |
| Method | `PUT` (全量) / `PATCH` (部分) |
| 认证 | 需要认证 |

**Request Body (PUT 全量更新)**

```json
{
  "title": "用户登录功能测试（修改版）",
  "description": "验证用户登录功能是否正常，增加边界测试",
  "preconditions": "1. 用户已注册\n2. 系统正常运行\n3. 网络连接正常",
  "steps": "1. 打开登录页面\n2. 输入正确的用户名和密码\n3. 点击登录按钮\n4. 验证跳转",
  "expected_result": "登录成功，显示用户信息",
  "priority": "critical",
  "test_type": "functional",
  "status": "active",
  "tags": ["登录", "核心功能", "边界测试"],
  "project_id": 1,
  "version_ids": [1, 2, 3]
}
```

**Request Body (PATCH 部分更新)**

```json
{
  "status": "active",
  "priority": "critical"
}
```

**Success Response (200 OK)**

```json
{
  "id": 1,
  "title": "用户登录功能测试（修改版）",
  "status": "active",
  "priority": "critical",
  ... (返回完整用例信息)
}
```

### 4.5 删除测试用例接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/testcases/<id>/` |
| Method | `DELETE` |
| 认证 | 需要认证 |

**Success Response (204 No Content)**

无响应体

**Error Response (404 Not Found)**

```json
{
  "detail": "未找到。"
}
```

------

## 五、数据库设计

### 5.1 测试用例表 (testcases)

```sql
CREATE TABLE `testcases` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用例唯一标识',
  `project_id` BIGINT NOT NULL COMMENT '项目ID',
  `title` VARCHAR(500) NOT NULL COMMENT '用例标题',
  `description` TEXT COMMENT '用例描述',
  `preconditions` TEXT COMMENT '前置条件',
  `steps` VARCHAR(1000) COMMENT '操作步骤 (旧字段)',
  `expected_result` TEXT NOT NULL COMMENT '预期结果',
  `priority` VARCHAR(20) NOT NULL DEFAULT 'medium' COMMENT '优先级',
  `status` VARCHAR(20) NOT NULL DEFAULT 'draft' COMMENT '状态',
  `test_type` VARCHAR(20) NOT NULL DEFAULT 'functional' COMMENT '测试类型',
  `tags` JSON COMMENT '标签列表',
  `author_id` BIGINT NOT NULL COMMENT '作者ID',
  `assignee_id` BIGINT COMMENT '指派人ID',
  `created_at` DATETIME NOT NULL COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL COMMENT '更新时间',

  INDEX `idx_project` (`project_id`),
  INDEX `idx_author` (`author_id`),
  INDEX `idx_assignee` (`assignee_id`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_status` (`status`),
  INDEX `idx_test_type` (`test_type`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_updated_at` (`updated_at`),
  FULLTEXT INDEX `ft_title_desc` (`title`, `description`),
  FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`author_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`assignee_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试用例表';
```

### 5.2 测试用例步骤表 (testcase_steps)

```sql
CREATE TABLE `testcase_steps` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '步骤唯一标识',
  `testcase_id` BIGINT NOT NULL COMMENT '测试用例ID',
  `step_number` INT UNSIGNED NOT NULL COMMENT '步骤序号',
  `action` TEXT NOT NULL COMMENT '操作描述',
  `expected` TEXT NOT NULL COMMENT '预期结果',

  UNIQUE KEY `uk_testcase_step` (`testcase_id`, `step_number`),
  INDEX `idx_testcase` (`testcase_id`),
  FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试用例步骤表';
```

### 5.3 测试用例附件表 (testcase_attachments)

```sql
CREATE TABLE `testcase_attachments` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '附件唯一标识',
  `testcase_id` BIGINT NOT NULL COMMENT '测试用例ID',
  `name` VARCHAR(255) NOT NULL COMMENT '附件名称',
  `file` VARCHAR(500) NOT NULL COMMENT '文件路径',
  `uploaded_by_id` BIGINT NOT NULL COMMENT '上传者ID',
  `uploaded_at` DATETIME NOT NULL COMMENT '上传时间',

  INDEX `idx_testcase` (`testcase_id`),
  INDEX `idx_uploaded_by` (`uploaded_by_id`),
  FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`uploaded_by_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试用例附件表';
```

### 5.4 测试用例评论表 (testcase_comments)

```sql
CREATE TABLE `testcase_comments` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '评论唯一标识',
  `testcase_id` BIGINT NOT NULL COMMENT '测试用例ID',
  `author_id` BIGINT NOT NULL COMMENT '评论者ID',
  `content` TEXT NOT NULL COMMENT '评论内容',
  `created_at` DATETIME NOT NULL COMMENT '评论时间',

  INDEX `idx_testcase` (`testcase_id`),
  INDEX `idx_author` (`author_id`),
  INDEX `idx_created_at` (`created_at`),
  FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`author_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试用例评论表';
```

### 5.5 测试用例-版本关联表 (testcases_versions)

```sql
CREATE TABLE `testcases_versions` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
  `testcase_id` BIGINT NOT NULL COMMENT '测试用例ID',
  `version_id` BIGINT NOT NULL COMMENT '版本ID',

  UNIQUE KEY `uk_testcase_version` (`testcase_id`, `version_id`),
  INDEX `idx_testcase` (`testcase_id`),
  INDEX `idx_version` (`version_id`),
  FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`version_id`) REFERENCES `versions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试用例-版本关联表';
```

------

## 六、序列化器设计

### 6.1 序列化器层次结构

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                          序列化器层次结构                                    │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌────────────────────────────────────────────────────────────────────────┐

    │                    TestCaseSerializer (详情视图)                        │

    │                                                                        │

    │  用于: GET /testcases/{id}/                                            │

    │                                                                        │

    │  嵌套序列化:                                                           │

    │    - author: UserSerializer (完整用户信息)                             │

    │    - assignee: UserSerializer (完整用户信息)                            │

    │    - project: ProjectSimpleSerializer (简化项目信息)                    │

    │    - versions: VersionSimpleSerializer (简化版本信息)                   │

    │    - step_details: TestCaseStepSerializer[] (步骤列表)                  │

    │    - attachments: TestCaseAttachmentSerializer[] (附件列表)           │

    │    - comments: TestCaseCommentSerializer[] (评论列表)                   │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                    TestCaseListSerializer (列表视图)                   │

    │                                                                        │

    │  用于: GET /testcases/                                                  │

    │                                                                        │

    │  轻量化设计 (不使用嵌套对象):                                           │

    │    - author: { id, username }                                          │

    │    - assignee: { id, username }                                        │

    │    - project: { id, name }                                             │

    │    - versions: [{ id, name, is_baseline }]                            │

    │                                                                        │

    │  排除: step_details, attachments, comments (列表不需要)                │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                  TestCaseCreateSerializer (创建)                        │

    │                                                                        │

    │  输入格式 (使用ID而非对象):                                             │

    │    - project_id: int (项目ID，可选)                                    │

    │    - version_ids: int[] (版本ID列表，可选)                             │

    │                                                                        │

    │  create() 方法:                                                        │

    │    1. 提取 version_ids                                                  │

    │    2. 调用 super().create()                                            │

    │    3. 设置版本关联 testcase.versions.set(version_ids)                  │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                  TestCaseUpdateSerializer (更新)                      │

    │                                                                        │

    │  输入格式 (使用ID而非对象):                                             │

    │    - project_id: int (项目ID，可选)                                    │

    │    - version_ids: int[] (版本ID列表，可选)                             │

    │                                                                        │

    │  update() 方法:                                                        │

    │    1. 提取 version_ids (如果提供)                                       │

    │    2. 调用 super().update()                                            │

    │    3. 更新版本关联 (如果提供)                                            │

    └────────────────────────────────────────────────────────────────────────┘
```

### 6.2 子模型序列化器

**TestCaseStepSerializer**

```python
class TestCaseStepSerializer(serializers.ModelSerializer):
    class Meta:
        model = TestCaseStep
        fields = '__all__'
```

**TestCaseAttachmentSerializer**

```python
class TestCaseAttachmentSerializer(serializers.ModelSerializer):
    uploaded_by = UserSerializer(read_only=True)  # 嵌套上传者信息
    
    class Meta:
        model = TestCaseAttachment
        fields = '__all__'
```

**TestCaseCommentSerializer**

```python
class TestCaseCommentSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)  # 嵌套评论者信息
    
    class Meta:
        model = TestCaseComment
        fields = '__all__'
```

### 6.3 序列化器性能优化策略

| 视图 | 序列化器 | 优化措施 |
| :--- | :--- | :--- |
| 列表视图 | TestCaseListSerializer | 轻量化字段，避免嵌套查询 |
| 详情视图 | TestCaseSerializer | 完整嵌套，数据量大 |
| 创建 | TestCaseCreateSerializer | 接受ID，设置关联 |
| 更新 | TestCaseUpdateSerializer | 接受ID，可选更新关联 |

------

## 七、前端实现

### 7.1 页面结构

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                            测试用例管理页面结构                              │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌────────────────────────────────────────────────────────────────────────┐

    │  测试用例管理                                                          │
    ├────────────────────────────────────────────────────────────────────────┤
    │  [+ 创建用例]  [批量操作 ▼]    [搜索...]    [筛选 ▼]    [排序 ▼]     │
    ├────────────────────────────────────────────────────────────────────────┤
    │                                                                        │
    │  ┌──────────────────────────────────────────────────────────────────┐ │
    │  │ ☐ │ ID  │ 用例标题          │ 优先级 │ 状态 │ 类型 │ 版本 │ 操作 │ │
    │  ├──────────────────────────────────────────────────────────────────┤ │
    │  │ ☐ │  1 │ 用户登录功能测试   │  🔴高  │ 激活 │ 功能 │ V1.0 │ ⋮    │ │
    │  │ ☐ │  2 │ 用户注册功能测试   │  🟡中  │ 草稿 │ 功能 │ V1.0 │ ⋮    │ │
    │  │ ☐ │  3 │ 商品搜索接口测试   │  🔴高  │ 激活 │ API  │ V1.1 │ ⋮    │ │
    │  └──────────────────────────────────────────────────────────────────┘ │
    │                                                                        │
    │  ┌──────────────────────────────────────────────────────────────────┐ │
    │  │                         分页组件                                  │ │
    │  │                    [< 1 2 3 ... 10 >]                            │ │
    │  └──────────────────────────────────────────────────────────────────┘ │
    └────────────────────────────────────────────────────────────────────────┘
```

### 7.2 用例详情抽屉/弹窗

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                              用例详情                                        │

├─────────────────────────────────────────────────────────────────────────────┤
│  用户登录功能测试                                           [编辑] [删除] X │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  基本信息                                                                  │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 项目: 电商平台测试                    状态: [激活 ▼]                │ │
│  │ 优先级: [🔴高 ▼]                     类型: [功能测试 ▼]            │ │
│  │ 作者: zhangsan                        创建时间: 2026-04-01          │ │
│  │ 标签: [登录] [核心功能]                                            │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  描述                                                                      │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 验证用户登录功能是否正常工作，包括正常登录和错误密码场景           │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  前置条件                                                                  │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 1. 用户已注册                                                     │ │
│  │ 2. 系统正常运行                                                   │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  测试步骤                                                                  │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 步骤1                          预期结果                            │ │
│  │ ┌────────────────────────────┐ ┌────────────────────────────┐  │ │
│  │ │ 1. 打开登录页面             │ │ 显示用户名和密码输入框       │  │ │
│  │ │ 2. 输入正确的用户名和密码    │ │ 输入框显示输入内容           │  │ │
│  │ │ 3. 点击登录按钮            │ │ 登录成功，跳转首页           │  │ │
│  │ └────────────────────────────┘ └────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  附件                                                                      │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 📎 登录页面截图.png (2026-04-10)                          [下载]   │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  评论                                                                      │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 💬 lisi (2026-04-10 12:00)                                         │ │
│  │    建议增加密码错误时的提示信息测试                                │ │
│  │                                                                     │ │
│  │ ┌────────────────────────────────────────┐ [发送]                   │ │
│  │ │ 输入评论...                           │                         │ │
│  │ └────────────────────────────────────────┘                         │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.3 用例创建/编辑表单

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                          创建测试用例                                        │

├─────────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  用例标题 *                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 输入用例标题...                                                    │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  关联项目                                                               │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ [电商平台测试 ▼]                                                   │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  关联版本                                                               │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ [x] V1.0 (基线版本)                                                │ │
│  │ [ ] V1.1                                                           │ │
│  │ [ ] V2.0                                                           │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  优先级 / 类型 / 状态                                                    │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 优先级: [高 ▼]    测试类型: [功能测试 ▼]    状态: [草稿 ▼]        │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  标签                                                                  │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ [登录 ×] [注册 ×] [+ 添加标签]                                    │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  描述                                                                  │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 输入用例描述...                                                    │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  前置条件                                                               │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 输入前置条件...                                                    │ │
│  │ (换行分隔每条条件)                                                 │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  操作步骤                                                               │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 步骤1: [输入操作...]                    预期: [输入预期结果...]    │ │
│  │                                           [+ 添加步骤]              │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  预期结果 *                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ 输入预期结果...                                                    │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│                                        [取消]  [保存]                   │
│                                                                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.4 API 服务层设计

```javascript
// api/testcase.js
import api from '@/utils/api'

// 获取测试用例列表
export function getTestCaseList(params) {
  return api.get('/testcases/', { params })
}

// 获取测试用例详情
export function getTestCaseDetail(id) {
  return api.get(`/testcases/${id}/`)
}

// 创建测试用例
export function createTestCase(data) {
  return api.post('/testcases/', data)
}

// 更新测试用例
export function updateTestCase(id, data) {
  return api.patch(`/testcases/${id}/`, data)
}

// 删除测试用例
export function deleteTestCase(id) {
  return api.delete(`/testcases/${id}/`)
}

// 批量删除测试用例
export function batchDeleteTestCases(ids) {
  return api.post('/testcases/batch-delete/', { ids })
}
```

### 7.5 Pinia Store 设计

```javascript
// stores/testcase.js
import { defineStore } from 'pinia'
import { getTestCaseList, getTestCaseDetail, createTestCase, updateTestCase, deleteTestCase } from '@/api/testcase'

export const useTestCaseStore = defineStore('testcase', () => {
  // 状态
  const testcases = ref([])
  const currentTestCase = ref(null)
  const total = ref(0)
  const loading = ref(false)
  
  // 筛选条件
  const filters = ref({
    page: 1,
    page_size: 10,
    search: '',
    priority: '',
    test_type: '',
    project: null,
    ordering: '-created_at'
  })
  
  // 获取用例列表
  const fetchTestCases = async () => {
    loading.value = true
    try {
      const response = await getTestCaseList(filters.value)
      testcases.value = response.data.results
      total.value = response.data.count
    } finally {
      loading.value = false
    }
  }
  
  // 获取用例详情
  const fetchTestCaseDetail = async (id) => {
    loading.value = true
    try {
      const response = await getTestCaseDetail(id)
      currentTestCase.value = response.data
    } finally {
      loading.value = false
    }
  }
  
  // 创建用例
  const create = async (data) => {
    await createTestCase(data)
    await fetchTestCases()
  }
  
  // 更新用例
  const update = async (id, data) => {
    await updateTestCase(id, data)
    await fetchTestCases()
  }
  
  // 删除用例
  const remove = async (id) => {
    await deleteTestCase(id)
    await fetchTestCases()
  }
  
  return {
    testcases,
    currentTestCase,
    total,
    loading,
    filters,
    fetchTestCases,
    fetchTestCaseDetail,
    create,
    update,
    remove
  }
})
```

------

## 八、路由汇总

| URL | Method | 认证 | 描述 |
| :--- | :--- | :--- | :--- |
| `/api/testcases/` | GET | 是 | 测试用例列表 (分页、搜索、筛选、排序) |
| `/api/testcases/` | POST | 是 | 创建测试用例 |
| `/api/testcases/<id>/` | GET | 是 | 测试用例详情 |
| `/api/testcases/<id>/` | PUT | 是 | 全量更新测试用例 |
| `/api/testcases/<id>/` | PATCH | 是 | 部分更新测试用例 |
| `/api/testcases/<id>/` | DELETE | 是 | 删除测试用例 |

------

## 九、与其他模块的关系

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                       测试用例模块与其他模块的关系                            │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐
    │   TestCase     │
    │  (测试用例)    │
    │                 │
    └────────┬────────┘
             │
    ┌────────┼────────┬────────────────┐
    │        │        │                │
    ▼        ▼        ▼                ▼
┌─────────┐ ┌─────────┐ ┌─────────────┐ ┌─────────────┐
│ Project │ │ Version │ │ TestSuite   │ │ TestPlan   │
│ (项目)  │ │ (版本)  │ │ (测试套件)  │ │ (测试计划) │
│         │ │         │ │             │ │            │
│ - owner │ │ - name  │ │ - name      │ │ - name     │
│ - ...   │ │ - ...   │ │ - cases(M2M)│ │ - cases(M2M)│
└─────────┘ └─────────┘ └─────────────┘ └─────────────┘
    │                              │
    │                              ▼
    │                       ┌─────────────┐
    │                       │ Execution   │
    │                       │ (执行记录)  │
    │                       │             │
    │                       │ - case (FK) │
    │                       │ - result   │
    │                       │ - ...      │
    └───────────────────────┴─────────────┘

    ┌────────────────────────────────────────────────────────────────────────┐

    │                            模块依赖关系                                  │

    └────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
    │   Users     │      │  Projects   │      │  Versions   │
    │   (用户)    │◄─────│   (项目)    │◄─────│   (版本)    │
    └─────────────┘      └──────┬──────┘      └─────────────┘
                                │
                                ▼
                         ┌─────────────┐
                         │ TestCases   │
                         │ (测试用例)  │────► Reviews (评审)
                         └──────┬──────┘
                                │
            ┌───────────────────┼───────────────────┐
            │                   │                   │
            ▼                   ▼                   ▼
     ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
     │ Executions  │    │  Reports    │    │Attachments  │
     │  (执行记录) │    │   (报告)    │    │   (附件)    │
     └─────────────┘    └─────────────┘    └─────────────┘
```

------

## 十、权限控制

### 10.1 权限检查机制

测试用例模块基于项目权限进行访问控制：

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                           权限检查流程                                      │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │  用户访问   │
    │ 用例列表    │
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                    获取用户有权限的项目                                   │

    │                                                                        │

    │  accessible_projects = Project.objects.filter(                        │

    │    Q(owner=user) | Q(members=user)                                    │

    │  )                                                                     │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                    查询属于这些项目的用例                                 │

    │                                                                        │

    │  queryset = TestCase.objects.filter(                                   │

    │    project__in=accessible_projects                                     │

    │  )                                                                     │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐
    │  返回结果   │
    │ (仅限有权限)│
    └─────────────┘
```

### 10.2 权限矩阵

| 操作 | Owner | Admin | Developer | Tester | Viewer |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 查看用例 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 创建用例 | ✅ | ✅ | ✅ | ✅ | ❌ |
| 编辑用例 | ✅ | ✅ | ✅ | ✅ | ❌ |
| 删除用例 | ✅ | ❌ | ❌ | ❌ | ❌ |
| 上传附件 | ✅ | ✅ | ✅ | ✅ | ❌ |
| 添加评论 | ✅ | ✅ | ✅ | ✅ | ✅ |

### 10.3 当前实现说明

**当前实现状态**：
- 基础权限检查已实现（基于项目的 owner 或 member 身份）
- 详细角色权限（Admin/Developer/Tester/Viewer）待完善
- 建议后续在视图中添加更细粒度的权限检查

**建议的权限检查增强**：

```python
def check_project_permission(user, project, action='read'):
    """检查用户对项目的权限"""
    # 项目负责人拥有所有权限
    if project.owner == user:
        return True
    
    # 获取用户在项目中的角色
    try:
        member = ProjectMember.objects.get(project=project, user=user)
    except ProjectMember.DoesNotExist:
        return False
    
    # 根据操作和角色判断权限
    permission_map = {
        'read': ['owner', 'admin', 'developer', 'tester', 'viewer'],
        'create': ['owner', 'admin', 'developer', 'tester'],
        'update': ['owner', 'admin', 'developer', 'tester'],
        'delete': ['owner'],
    }
    
    return member.role in permission_map.get(action, [])
```

------

## 十一、性能优化

### 11.1 数据库查询优化

| 优化点 | 实现方式 | 说明 |
| :--- | :--- | :--- |
| select_related | 列表视图 | 预加载 author, assignee, project |
| select_related | 详情视图 | 预加载 author, assignee, project |
| prefetch_related | 列表视图 | 预加载 versions |
| prefetch_related | 详情视图 | 预加载 versions, step_details, attachments, comments |

### 11.2 索引优化

| 索引类型 | 字段 | 用途 |
| :--- | :--- | :--- |
| 普通索引 | project_id | 按项目筛选 |
| 普通索引 | priority | 按优先级筛选 |
| 普通索引 | status | 按状态筛选 |
| 普通索引 | test_type | 按类型筛选 |
| 普通索引 | created_at | 按时间排序 |
| 组合索引 | (project, status) | 项目+状态筛选 |
| 全文索引 | (title, description) | 全文搜索 |

### 11.3 序列化器优化

| 视图 | 序列化器 | 优化原因 |
| :--- | :--- | :--- |
| 列表 | TestCaseListSerializer | 轻量化，避免不必要的数据 |
| 详情 | TestCaseSerializer | 完整数据，嵌套关系 |
| 创建 | TestCaseCreateSerializer | 接受ID，设置关联 |
| 更新 | TestCaseUpdateSerializer | 可选关联更新 |

------

## 十二、后续扩展建议

### 12.1 功能扩展

1. **批量操作**：支持批量删除、批量更新状态、批量指派
2. **用例导入/导出**：支持 Excel 导入导出
3. **用例复制**：快速复制用例创建新用例
4. **用例评审**：与 reviews 模块集成
5. **执行记录**：与 executions 模块集成
6. **测试报告**：生成用例执行报告

### 12.2 代码完善

1. **admin.py**：注册模型到 Django Admin 后台
2. **signals.py**：添加信号处理（如删除附件文件）
3. **apps.py**：添加 App 配置
4. **单元测试**：编写完整的测试用例

### 12.3 性能优化

1. **缓存**：引入 Redis 缓存热门用例
2. **分表**：大数据量时按项目分表
3. **异步任务**：附件上传异步处理

------

文档版本：V1.0
编写日期：2026-04-10
基于项目：TestHub 智能测试管理平台
