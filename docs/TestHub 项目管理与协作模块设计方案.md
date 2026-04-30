# TestHub 项目管理与协作模块设计方案

## 文档概述

项目管理与协作模块是 TestHub 平台的核心模块之一，负责管理测试项目和团队协作。该模块的核心目标是：

1. 项目全生命周期管理：支持项目的创建、编辑、删除、状态变更
2. 团队成员管理：支持多角色成员管理，控制成员权限
3. 环境配置管理：支持多环境变量配置，满足不同测试场景
4. 权限隔离：确保用户只能访问有权限参与的项目

------

## 一、功能需求

### 1.1 功能列表

| 功能点   | 优先级 | 描述                                       |
| :------- | :----- | :----------------------------------------- |
| 项目创建 | P0     | 创建新项目，设置名称、描述、状态           |
| 项目列表 | P0     | 分页查看用户参与的项目，支持搜索和状态筛选 |
| 项目详情 | P0     | 查看项目详细信息、成员列表、环境列表       |
| 项目编辑 | P0     | 修改项目名称、描述、状态                   |
| 项目删除 | P1     | 删除项目（级联删除相关数据）               |
| 成员管理 | P0     | 添加/移除项目成员，设置成员角色            |
| 成员列表 | P0     | 查看项目所有成员（包含负责人）             |
| 环境管理 | P0     | 创建/编辑/删除项目环境配置                 |
| 权限控制 | P0     | 项目负责人管理成员，其他成员只读           |

### 1.2 项目状态

| 状态值    | 描述   | 说明           |
| :-------- | :----- | :------------- |
| active    | 进行中 | 项目正在执行   |
| paused    | 暂停   | 项目暂时停止   |
| completed | 已完成 | 项目已全部完成 |
| archived  | 已归档 | 项目归档封存   |

### 1.3 成员角色

| 角色      | 描述   | 权限                       |
| :-------- | :----- | :------------------------- |
| owner     | 负责人 | 全部权限，可管理成员和环境 |
| admin     | 管理员 | 可管理环境配置             |
| developer | 开发者 | 可执行测试、查看结果       |
| tester    | 测试者 | 可执行测试、提交结果       |
| viewer    | 观察者 | 只读权限                   |

------

## 二、数据模型

### 2.1 项目模型 (Project)

class Project(models.Model):

​    """项目模型"""

​    STATUS_CHOICES = [

​        ('active', '进行中'),

​        ('paused', '暂停'),

​        ('completed', '已完成'),

​        ('archived', '已归档'),

​    ]

​    

​    name = models.CharField(max_length=200, verbose_name='项目名称')

​    description = models.TextField(blank=True, verbose_name='项目描述')

​    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')

​    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_projects')

​    members = models.ManyToManyField(User, through='ProjectMember', related_name='joined_projects')

​    created_at = models.DateTimeField(default=timezone.now)

​    updated_at = models.DateTimeField(auto_now=True)

### 2.2 项目成员模型 (ProjectMember)

class ProjectMember(models.Model):

​    """项目成员"""

​    ROLE_CHOICES = [

​        ('owner', '负责人'),

​        ('admin', '管理员'),

​        ('developer', '开发者'),

​        ('tester', '测试者'),

​        ('viewer', '观察者'),

​    ]

​    

​    project = models.ForeignKey(Project, on_delete=models.CASCADE)

​    user = models.ForeignKey(User, on_delete=models.CASCADE)

​    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='tester')

​    joined_at = models.DateTimeField(default=timezone.now)

​    

​    class Meta:

​        unique_together = ['project', 'user']  *# 确保同一项目成员不重复*

### 2.3 项目环境模型 (ProjectEnvironment)

class ProjectEnvironment(models.Model):

​    """项目环境"""

​    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='environments')

​    name = models.CharField(max_length=100, verbose_name='环境名称')

​    base_url = models.URLField(verbose_name='基础URL')

​    description = models.TextField(blank=True, verbose_name='环境描述')

​    variables = models.JSONField(default=dict, verbose_name='环境变量')

​    is_default = models.BooleanField(default=False, verbose_name='是否默认')

​    created_at = models.DateTimeField(default=timezone.now)

### 2.4 数据模型关系图

┌─────────────────────────────────────────────────────────────────────────────┐

│                           项目管理数据模型关系                                │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────────┐

​    │      User       │

​    │   (用户)        │

​    └────────┬────────┘

​             │

​       ┌─────┴─────┐

​       │           │

​       ▼           ▼

┌─────────────┐   ┌─────────────────┐

│  owned_projects│   │ joined_projects │

│ (我创建的项目) │   │  (参与的项目)   │

└─────────────┘   └────────┬────────┘

​                             │

​                             ▼

​                    ┌─────────────────┐

​                    │    Project       │

​                    │    (项目)        │

​                    │                 │

​                    │ - name          │

​                    │ - description   │

​                    │ - status        │

​                    │ - owner (FK)    │

​                    └────────┬────────┘

​                             │

​          ┌──────────────────┼──────────────────┐

​          │                  │                  │

​          ▼                  ▼                  ▼

​    ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐

​    │ProjectMember │  │  TestCase   │  │ProjectEnvironment│

​    │ (项目成员)   │  │ (测试用例)  │  │  (项目环境)     │

​    │             │  │             │  │                 │

​    │ - user (FK)│  │ - project   │  │ - name          │

​    │ - role     │  │  (FK)       │  │ - base_url     │

​    │ - joined_at│  │             │  │ - variables     │

​    └─────────────┘  │             │  │ - is_default   │

​                      └─────────────┘  └─────────────────┘

------

## 三、关键流程

### 3.1 项目创建流程

┌─────────────────────────────────────────────────────────────────────────────┐

│                              项目创建流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐

​    │  填写项目信息  │

​    │ 名称/描述/状态│

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 前端表单验证  │ ──► 项目名称非空、长度验证

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 发送创建请求 │

​    │ POST /projects/

​    └──────┬──────┘

​           │

​           ▼

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                         后端处理                                        │

​    │                                                                        │

​    │  1. 获取当前登录用户作为 owner                                         │

​    │  2. 创建项目记录                                                       │

​    │  3. 自动将 owner 添加为成员（role='owner'）                           │

​    └────────────────────────────────────────────────────────────────────────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 返回项目详情 │

​    │ 201 Created │

​    └─────────────┘

### 3.2 项目列表查询流程

┌─────────────────────────────────────────────────────────────────────────────┐

│                            项目列表查询流程                                  │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐

​    │ 访问项目列表 │

​    │ GET /projects/

​    └──────┬──────┘

​           │

​           ▼

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                         权限过滤                                        │

​    │                                                                        │

​    │  SELECT * FROM projects                                                │

​    │  WHERE owner = current_user                                           │

​    │     OR id IN (SELECT project_id FROM project_members WHERE user_id = current_user) │

​    └────────────────────────────────────────────────────────────────────────┘

​           │

​           ▼

​    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐

​    │ 搜索过滤    │ ──► │ 状态筛选    │ ──► │ 分页处理    │

​    │ search字段  │     │ status字段  │     │ page/page_size│

​    └─────────────┘     └─────────────┘     └──────┬──────┘

​                                                      │

​                                                      ▼

​                                              ┌─────────────┐

​                                              │ 返回分页结果 │

​                                              │             │

​                                              │ count       │

​                                              │ results[]   │

​                                              │ next/prev   │

​                                              └─────────────┘

### 3.3 成员管理流程

┌─────────────────────────────────────────────────────────────────────────────┐

│                            成员管理流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                           添加成员                                      │

​    └────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐

​    │ 负责人操作  │ ──► │ 权限检查    │ ──► │ 选择用户    │

​    │ 添加成员    │     │ owner才能添加│     │ 设置角色    │

​    └─────────────┘     └─────────────┘     └──────┬──────┘

​                                                      │

​                                                      ▼

​                                              ┌─────────────┐

​                                              │ 发送请求    │

​                                              │ POST /members/add/ │

​                                              └──────┬──────┘

​                                                     │

​                                                     ▼

​                                             ┌─────────────┐

​                                             │ 创建成员记录 │

​                                             │ unique_together │

​                                             │ 检查重复    │

​                                             └──────┬──────┘

​                                                    │

​                                                    ▼

​                                            ┌─────────────┐

​                                            │ 返回成员信息 │

​                                            └─────────────┘

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                           移除成员                                      │

​    └────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐

​    │ 负责人操作  │ ──► │ 权限检查    │ ──► │ 发送请求    │

​    │ 移除成员    │     │ owner才能移除│     │ DELETE /members/<id>/ │

​    └─────────────┘     └─────────────┘     └──────┬──────┘

​                                                     │

​                                                     ▼

​                                             ┌─────────────┐

​                                             │ 删除成员记录 │

​                                             │ (不删除用户)│

​                                             └─────────────┘

### 3.4 环境配置流程

┌─────────────────────────────────────────────────────────────────────────────┐

│                            环境配置流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐

​    │ 创建环境    │

​    │ POST /environments/

​    └──────┬──────┘

​           │

​           ▼

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                         请求参数                                        │

​    │                                                                        │

​    │  {                                                                      │

​    │    "name": "测试环境",      // 环境名称                                │

​    │    "base_url": "http://test.example.com",  // 基础URL               │

​    │    "description": "测试环境描述",                                    │

​    │    "variables": {              // 环境变量 JSON                         │

​    │      "API_KEY": "xxx",                                                  │

​    │      "DB_HOST": "localhost"                                           │

​    │    },                                                                 │

​    │    "is_default": false        // 是否默认                              │

​    │  }                                                                      │

​    └────────────────────────────────────────────────────────────────────────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 环境列表查询 │

​    │ GET /environments/

​    └─────────────┘

​    ┌─────────────┐

​    │ 环境变量使用 │

​    └─────────────┘

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                         变量替换机制                                    │

​    │                                                                        │

​    │  请求发送: {{base_url}}/api/users                                      │

​    │                ↓                                                        │

​    │  变量解析: 替换为 "http://test.example.com/api/users"                 │

​    │                ↓                                                        │

​    │  实际请求: http://test.example.com/api/users                           │

​    └────────────────────────────────────────────────────────────────────────┘

------

## 四、接口设计

### 4.1 项目列表接口

基本信息

| 属性   | 值               |
| :----- | :--------------- |
| URL    | `/api/projects/` |
| Method | `GET`            |
| 认证   | 需要认证         |

Query Parameters

| 参数      | 类型   | 描述                                                  |
| :-------- | :----- | :---------------------------------------------------- |
| page      | int    | 页码 (默认 1)                                         |
| page_size | int    | 每页数量 (默认 20)                                    |
| search    | string | 搜索关键词 (可选，搜索 name/description)              |
| status    | string | 项目状态筛选 (可选: active/paused/completed/archived) |
| ordering  | string | 排序字段 (可选: -created_at/created_at/-name/name)    |

Success Response (200 OK)

{

  "count": 25,

  "next": "http://api.example.com/projects/?page=2",

  "previous": null,

  "results": [

​    {

​      "id": 1,

​      "name": "电商平台测试项目",

​      "description": "公司核心电商系统的测试项目",

​      "status": "active",

​      "owner": {

​        "id": 1,

​        "username": "zhangsan",

​        "email": "zhangsan@example.com",

​        "first_name": "张",

​        "last_name": "三"

​      },

​      "members": [

​        {

​          "id": 1,

​          "user": {

​            "id": 1,

​            "username": "zhangsan",

​            "email": "zhangsan@example.com"

​          },

​          "role": "owner",

​          "joined_at": "2026-04-01T10:00:00Z"

​        }

​      ],

​      "environments": [

​        {

​          "id": 1,

​          "name": "测试环境",

​          "base_url": "http://test.example.com",

​          "is_default": true

​        }

​      ],

​      "created_at": "2026-04-01T10:00:00Z",

​      "updated_at": "2026-04-10T10:00:00Z"

​    }

  ]

}

### 4.2 创建项目接口

基本信息

| 属性   | 值               |
| :----- | :--------------- |
| URL    | `/api/projects/` |
| Method | `POST`           |
| 认证   | 需要认证         |

Request Body

{

  "name": "电商平台测试项目",

  "description": "公司核心电商系统的测试项目",

  "status": "active"

}

Success Response (201 Created)

{

  "id": 1,

  "name": "电商平台测试项目",

  "description": "公司核心电商系统的测试项目",

  "status": "active",

  "owner": { ... },

  "members": [ ... ],

  "environments": [],

  "created_at": "2026-04-10T10:00:00Z",

  "updated_at": "2026-04-10T10:00:00Z"

}

### 4.3 项目详情接口

基本信息

| 属性   | 值                    |
| :----- | :-------------------- |
| URL    | `/api/projects/<id>/` |
| Method | `GET`                 |
| 认证   | 需要认证              |

Success Response (200 OK)

{

  "id": 1,

  "name": "电商平台测试项目",

  "description": "公司核心电商系统的测试项目",

  "status": "active",

  "owner": {

​    "id": 1,

​    "username": "zhangsan",

​    "email": "zhangsan@example.com"

  },

  "members": [

​    {

​      "id": 1,

​      "user": { ... },

​      "role": "owner",

​      "joined_at": "2026-04-01T10:00:00Z"

​    },

​    {

​      "id": 2,

​      "user": { ... },

​      "role": "tester",

​      "joined_at": "2026-04-05T10:00:00Z"

​    }

  ],

  "environments": [

​    {

​      "id": 1,

​      "name": "测试环境",

​      "base_url": "http://test.example.com",

​      "description": "测试环境描述",

​      "variables": {

​        "API_KEY": "xxx",

​        "DB_HOST": "localhost"

​      },

​      "is_default": true,

​      "created_at": "2026-04-01T10:00:00Z"

​    }

  ],

  "created_at": "2026-04-01T10:00:00Z",

  "updated_at": "2026-04-10T10:00:00Z"

}

### 4.4 更新项目接口

基本信息

| 属性   | 值                    |
| :----- | :-------------------- |
| URL    | `/api/projects/<id>/` |
| Method | `PUT/PATCH`           |
| 认证   | 需要认证              |

Request Body

{

  "name": "电商平台 V2.0 测试",

  "description": "更新后的项目描述",

  "status": "completed"

}

### 4.5 删除项目接口

基本信息

| 属性   | 值                    |
| :----- | :-------------------- |
| URL    | `/api/projects/<id>/` |
| Method | `DELETE`              |
| 认证   | 需要认证              |

Success Response (204 No Content)

### 4.6 获取项目成员接口

基本信息

| 属性   | 值                                    |
| :----- | :------------------------------------ |
| URL    | `/api/projects/<project_id>/members/` |
| Method | `GET`                                 |
| 认证   | 需要认证                              |

Success Response (200 OK)

[

  {

​    "id": 1,

​    "username": "zhangsan",

​    "email": "zhangsan@example.com",

​    "first_name": "张",

​    "last_name": "三",

​    "role": "owner"

  },

  {

​    "id": 2,

​    "username": "lisi",

​    "email": "lisi@example.com",

​    "first_name": "李",

​    "last_name": "四",

​    "role": "tester"

  }

]

### 4.7 添加项目成员接口

基本信息

| 属性   | 值                                        |
| :----- | :---------------------------------------- |
| URL    | `/api/projects/<project_id>/members/add/` |
| Method | `POST`                                    |
| 认证   | 需要认证                                  |
| 权限   | 仅项目负责人                              |

Request Body

{

  "user_id": 3,

  "role": "developer"

}

Success Response (201 Created)

{

  "id": 3,

  "user": {

​    "id": 3,

​    "username": "wangwu",

​    "email": "wangwu@example.com"

  },

  "role": "developer",

  "joined_at": "2026-04-10T10:00:00Z"

}

Error Response (403 Forbidden)

{

  "error": "无权限添加成员"

}

### 4.8 移除项目成员接口

基本信息

| 属性   | 值                                                |
| :----- | :------------------------------------------------ |
| URL    | `/api/projects/<project_id>/members/<member_id>/` |
| Method | `DELETE`                                          |
| 认证   | 需要认证                                          |
| 权限   | 仅项目负责人                                      |

Success Response (200 OK)

{

  "message": "成员删除成功"

}

### 4.9 项目环境列表接口

基本信息

| 属性   | 值                                         |
| :----- | :----------------------------------------- |
| URL    | `/api/projects/<project_id>/environments/` |
| Method | `GET`                                      |
| 认证   | 需要认证                                   |

Success Response (200 OK)

[

  {

​    "id": 1,

​    "name": "测试环境",

​    "base_url": "http://test.example.com",

​    "description": "测试环境描述",

​    "variables": {

​      "API_KEY": "xxx",

​      "DB_HOST": "localhost"

​    },

​    "is_default": true,

​    "created_at": "2026-04-01T10:00:00Z"

  }

]

### 4.10 创建项目环境接口

基本信息

| 属性   | 值                                         |
| :----- | :----------------------------------------- |
| URL    | `/api/projects/<project_id>/environments/` |
| Method | `POST`                                     |
| 认证   | 需要认证                                   |

Request Body

{

  "name": "预发布环境",

  "base_url": "http://pre.example.com",

  "description": "预发布环境",

  "variables": {

​    "API_KEY": "pre_xxx"

  },

  "is_default": false

}

### 4.11 用户项目列表接口（用于下拉选择）

基本信息

| 属性   | 值                    |
| :----- | :-------------------- |
| URL    | `/api/projects/list/` |
| Method | `GET`                 |
| 认证   | 需要认证              |

Success Response (200 OK)

{

  "results": [

​    {"id": 1, "name": "项目A", "status": "active"},

​    {"id": 2, "name": "项目B", "status": "active"}

  ]

}

------

## 五、数据库设计

### 5.1 项目表 (projects)

CREATE TABLE `projects` (

  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '项目唯一标识',

  `name` VARCHAR(200) NOT NULL COMMENT '项目名称',

  `description` TEXT COMMENT '项目描述',

  `status` VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT '项目状态',

  `owner_id` BIGINT NOT NULL COMMENT '项目负责人ID',

  `created_at` DATETIME NOT NULL COMMENT '创建时间',

  `updated_at` DATETIME NOT NULL COMMENT '更新时间',

  

  INDEX `idx_owner` (`owner_id`),

  INDEX `idx_status` (`status`),

  INDEX `idx_created_at` (`created_at`),

  FOREIGN KEY (`owner_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 

COMMENT='项目表';

### 5.2 项目成员表 (project_members)

CREATE TABLE `project_members` (

  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '成员唯一标识',

  `project_id` BIGINT NOT NULL COMMENT '项目ID',

  `user_id` BIGINT NOT NULL COMMENT '用户ID',

  `role` VARCHAR(20) NOT NULL DEFAULT 'tester' COMMENT '成员角色',

  `joined_at` DATETIME NOT NULL COMMENT '加入时间',

  

  UNIQUE KEY `uk_project_user` (`project_id`, `user_id`),

  INDEX `idx_project` (`project_id`),

  INDEX `idx_user` (`user_id`),

  FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,

  FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 

COMMENT='项目成员表';

### 5.3 项目环境表 (project_environments)

CREATE TABLE `project_environments` (

  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '环境唯一标识',

  `project_id` BIGINT NOT NULL COMMENT '项目ID',

  `name` VARCHAR(100) NOT NULL COMMENT '环境名称',

  `base_url` VARCHAR(500) NOT NULL COMMENT '基础URL',

  `description` TEXT COMMENT '环境描述',

  `variables` JSON COMMENT '环境变量',

  `is_default` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否默认环境',

  `created_at` DATETIME NOT NULL COMMENT '创建时间',

  

  INDEX `idx_project` (`project_id`),

  FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 

COMMENT='项目环境表';

------

## 六、前端实现

### 6.1 项目列表页面 (ProjectList.vue)

核心功能：

- 分页展示项目列表
- 搜索项目名称/描述
- 按状态筛选
- 创建/编辑/删除项目
- 跳转到项目详情

关键代码结构：

*// 状态管理*

const projects = ref([])

const currentPage = ref(1)

const pageSize = ref(20)

const total = ref(0)

const searchText = ref('')

const statusFilter = ref('')

*// 获取项目列表*

const fetchProjects = async () => {

  const params = {

​    page: currentPage.value,

​    search: searchText.value,

​    status: statusFilter.value

  }

  const response = await api.get('/projects/', { params })

  projects.value = response.data.results

  total.value = response.data.count

}

*// 创建/编辑项目*

const handleSubmit = async () => {

  if (isEdit.value) {

​    await api.put(`/projects/${form.id}/`, form)

  } else {

​    await api.post('/projects/', form)

  }

}

### 6.2 项目详情页面 (ProjectDetail.vue)

核心功能：

- 展示项目基本信息
- Tab 切换：项目信息 / 成员管理 / 环境管理
- 添加/移除成员
- 添加/编辑/删除环境

Tab 结构：

┌────────────────────────────────────────────────────────────┐

│  [项目信息]  [成员管理]  [环境配置]                        │

├────────────────────────────────────────────────────────────┤

│                                                            │

│  项目信息 Tab:                                             │

│  ┌─────────────────────────────────────────────────────┐ │

│  │  项目名称: 电商平台测试项目                          │ │

│  │  项目状态: [进行中]                                 │ │

│  │  负责人: zhangsan                                   │ │

│  │  创建时间: 2026-04-01                              │ │

│  │  项目描述: 公司核心电商系统的测试项目                │ │

│  └─────────────────────────────────────────────────────┘ │

│                                                            │

│  成员管理 Tab:                                             │

│  ┌─────────────────────────────────────────────────────┐ │

│  │  [+ 添加成员]                                       │ │

│  │  ┌─────────────────────────────────────────────┐  │ │

│  │  │ 用户名    │ 角色      │ 加入时间   │ 操作    │  │ │

│  │  ├─────────────────────────────────────────────┤  │ │

│  │  │ zhangsan  │ owner     │ 2026-04-01 │ [删除] │  │ │

│  │  │ lisi      │ tester    │ 2026-04-05 │ [删除] │  │ │

│  │  └─────────────────────────────────────────────┘  │ │

│  └─────────────────────────────────────────────────────┘ │

│                                                            │

│  环境配置 Tab:                                             │

│  ┌─────────────────────────────────────────────────────┐ │

│  │  [+ 添加环境]                                       │ │

│  │  ┌─────────────────────────────────────────────┐  │ │

│  │  │ 环境名称  │ 基础URL         │ 默认 │ 操作    │  │ │

│  │  ├─────────────────────────────────────────────┤  │ │

│  │  │ 测试环境  │ http://test.xxx │  是  │ [编辑]  │  │ │

│  │  └─────────────────────────────────────────────┘  │ │

│  └─────────────────────────────────────────────────────┘ │

│                                                            │

└────────────────────────────────────────────────────────────┘

------

## 七、路由汇总

| URL                                                 | Method     | 认证 | 描述                   |
| :-------------------------------------------------- | :--------- | :--- | :--------------------- |
| `/api/projects/`                                    | GET        | 是   | 项目列表               |
| `/api/projects/`                                    | POST       | 是   | 创建项目               |
| `/api/projects/all/`                                | GET        | 是   | 所有项目（下拉选择用） |
| `/api/projects/<id>/`                               | GET        | 是   | 项目详情               |
| `/api/projects/<id>/`                               | PUT/PATCH  | 是   | 更新项目               |
| `/api/projects/<id>/`                               | DELETE     | 是   | 删除项目               |
| `/api/projects/<project_id>/members/`               | GET        | 是   | 成员列表               |
| `/api/projects/<project_id>/members/add/`           | POST       | 是   | 添加成员               |
| `/api/projects/<project_id>/members/<member_id>/`   | DELETE     | 是   | 移除成员               |
| `/api/projects/<project_id>/environments/`          | GET/POST   | 是   | 环境列表/创建          |
| `/api/projects/<project_id>/environments/<env_id>/` | PUT/DELETE | 是   | 更新/删除环境          |
| `/api/projects/list/`                               | GET        | 是   | 用户项目列表           |

------

## 八、与其他模块的关系

┌─────────────────────────────────────────────────────────────────────────────┐

│                         项目模块与其他模块的关系                              │

└─────────────────────────────────────────────────────────────────────────────┘

​                           ┌─────────────────┐

​                           │     Project      │

​                           │    (项目)        │

​                           └────────┬────────┘

​                                    │

​         ┌──────────────────────────┼──────────────────────────┐

​         │                          │                          │

​         ▼                          ▼                          ▼

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐

│   手工测试       │    │   API 测试      │    │   UI 自动化     │

│                 │    │                 │    │                 │

│ TestCase        │    │ ApiProject      │    │ UiProject       │

│ TestPlan        │    │ Environment     │    │ Element         │

│ TestRun         │    │                 │    │ Script          │

└─────────────────┘    └─────────────────┘    └─────────────────┘

​         │                          │                          │

​         ▼                          ▼                          ▼

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐

│   版本管理       │    │   需求分析      │    │   APP 自动化    │

│                 │    │                 │    │                 │

│ Version         │    │ RequirementDoc   │    │ AppProject      │

│ (多项目关联)    │    │ GeneratedCase    │    │ Device          │

└─────────────────┘    └─────────────────┘    └─────────────────┘

------

## 九、权限控制

### 9.1 权限矩阵

| 操作         | Owner | Admin | Developer | Tester | Viewer |
| :----------- | :---- | :---- | :-------- | :----- | :----- |
| 查看项目     | ✅     | ✅     | ✅         | ✅      | ✅      |
| 编辑项目信息 | ✅     | ❌     | ❌         | ❌      | ❌      |
| 删除项目     | ✅     | ❌     | ❌         | ❌      | ❌      |
| 添加成员     | ✅     | ❌     | ❌         | ❌      | ❌      |
| 移除成员     | ✅     | ❌     | ❌         | ❌      | ❌      |
| 管理环境     | ✅     | ✅     | ❌         | ❌      | ❌      |
| 查看成员     | ✅     | ✅     | ✅         | ✅      | ✅      |

### 9.2 权限检查逻辑

*# views.py*

def add_project_member(request, project_id):

​    project = Project.objects.get(id=project_id)

​    

​    *# 只有项目负责人可以添加成员*

​    if project.owner != request.user:

​        return Response({'error': '无权限添加成员'}, status=403)

​    

​    serializer = ProjectMemberSerializer(data=request.data)

​    serializer.is_valid(raise_exception=True)

​    serializer.save(project=project)

​    return Response(serializer.data, status=201)

------

文档版本：V1.0
编写日期：2026-04-10
基于项目：TestHub 智能测试管理平台