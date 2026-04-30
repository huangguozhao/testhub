# TestHub 用户与认证系统模块设计方案

## 文档概述

用户与认证系统是 TestHub 平台的基础模块，负责处理用户的注册、登录、认证、授权和用户配置功能。该模块的核心目标是：

1. 确保用户身份的安全性：通过 JWT 双 Token 机制实现无状态认证
2. 提供灵活的权限管理机制：为项目级权限控制提供基础
3. 支持用户个性化配置：主题、语言、通知设置等
4. 为其他模块提供用户信息支持：统一的用户数据结构

------

## 一、功能需求

### 1.1 功能列表

| 功能点           | 优先级 | 描述                                         |
| :--------------- | :----- | :------------------------------------------- |
| 用户注册         | P0     | 用户名、密码（确认密码）、邮箱等基本信息注册 |
| 用户登录         | P0     | 用户名+密码登录，返回 JWT Token              |
| 用户退出         | P0     | 清除 Token，会话结束                         |
| Token 刷新       | P0     | Access Token 过期后自动刷新                  |
| 获取当前用户信息 | P0     | 获取已登录用户的详细信息                     |
| 用户列表查询     | P1     | 分页查询所有用户（仅管理员）                 |
| 用户详情查看     | P1     | 查看指定用户的详细信息                       |
| 用户信息编辑     | P1     | 修改用户名、邮箱等基本信息                   |
| 用户配置管理     | P1     | 管理用户的主题、语言、时区、通知设置         |
| 密码修改         | P2     | 修改当前用户密码                             |

### 1.2 用户扩展字段

| 字段名     | 类型           | 描述     |
| :--------- | :------------- | :------- |
| avatar     | ImageField     | 用户头像 |
| phone      | CharField(11)  | 手机号   |
| department | CharField(100) | 部门     |
| position   | CharField(100) | 职位     |
| is_active  | BooleanField   | 是否激活 |
| created_at | DateTimeField  | 创建时间 |
| updated_at | DateTimeField  | 更新时间 |

### 1.3 用户配置字段

| 字段名        | 类型          | 默认值        | 描述              |
| :------------ | :------------ | :------------ | :---------------- |
| theme         | CharField(20) | light         | 主题 (light/dark) |
| language      | CharField(10) | zh-cn         | 语言 (zh-cn/en)   |
| timezone      | CharField(50) | Asia/Shanghai | 时区              |
| notifications | JSONField     | {}            | 通知设置          |

------

## 二、技术选型

| 技术选型              | 版本   | 用途说明         |
| :-------------------- | :----- | :--------------- |
| Django                | 4.2.7  | Web 框架         |
| Django REST Framework | 3.14.0 | RESTful API 开发 |
| SimpleJWT             | 5.5.1  | JWT Token 认证   |
| Django CORS Headers   | 4.3.1  | 跨域资源共享     |

### 2.1 JWT 认证机制

┌─────────────────────────────────────────────────────────────────────────────┐

│                           JWT 双 Token 认证机制                              │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                           登录流程                                      │

​    └────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐

​    │ 用户输入    │ ──► │ 后端验证    │ ──► │ 生成Token   │

​    │ 用户名/密码 │     │ 密码验证    │     │             │

​    └─────────────┘     └─────────────┘     └──────┬──────┘

​                                                     │

​                    ┌────────────────────────────────┴────────────────────────────────┐

​                    │                                                         │

​                    ▼                                                         ▼

​           ┌─────────────────┐                                     ┌─────────────────┐

​           │  Access Token   │                                     │ Refresh Token   │

​           │                 │                                     │                 │

​           │ 有效期: 60分钟  │                                     │ 有效期: 7天     │

​           │ 用于: API认证   │                                     │ 用于: 刷新Token │

​           └─────────────────┘                                     └─────────────────┘

​                    │                                                         │

​                    ▼                                                         │

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                           前端存储                                      │

​    └────────────────────────────────────────────────────────────────────────┘

​           localStorage.access_token                                    localStorage.refresh_token

​           localStorage.token_expires_at                               (可选) ROTATE_REFRESH_TOKENS

​           localStorage.user                                            后，每次刷新会轮换

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                           自动刷新机制                                  │

​    └────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐

​    │ 每2分钟检查  │ ──► │ 5分钟内过期  │ ──► │ 刷新Token  │

​    │             │     │             │     │             │

​    └─────────────┘     └─────────────┘     └──────┬──────┘

​                                                     │

​                    ┌────────────────────────────────┴────────────────────────────────┐

​                    │                                                         │

​                    ▼                                                         ▼

​           ┌─────────────────┐                                     ┌─────────────────┐

​           │  刷新成功      │                                     │   刷新失败      │

​           │ 更新本地存储    │                                     │ 清除认证状态    │

​           │ 继续请求       │                                     │ 跳转登录页     │

​           └─────────────────┘                                     └─────────────────┘

### 2.2 Token 配置参数

SIMPLE_JWT = {

​    *# Token 有效期配置*

​    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),   *# Access Token 60分钟*

​    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),       *# Refresh Token 7天*

​    

​    *# Token 轮换配置*

​    'ROTATE_REFRESH_TOKENS': True,                    *# 刷新时生成新的 Refresh Token*

​    'BLACKLIST_AFTER_ROTATION': True,                 *# 旧的 Refresh Token 加入黑名单*

​    

​    *# 其他配置*

​    'UPDATE_LAST_LOGIN': True,                        *# 更新最后登录时间*

​    'ALGORITHM': 'HS256',                            *# 加密算法*

​    'AUTH_HEADER_TYPES': ('Bearer',),                 *# 请求头格式: Bearer xxx*

}

------

## 三、关键流程

### 3.1 用户注册流程

┌─────────────────────────────────────────────────────────────────────────────┐

│                              用户注册流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐

​    │  填写注册信息  │

​    │ 用户名/密码  │

​    │ 邮箱等     │

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 前端表单验证  │ ──► 密码长度≥6、确认密码一致

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 发送注册请求 │

​    │ POST /auth/register/

​    └──────┬──────┘

​           │

​           ▼

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                         后端处理                                        │

​    │                                                                        │

​    │  1. 验证用户名唯一性                                                   │

​    │  2. 验证密码一致性                                                     │

​    │  3. BCrypt 加密密码                                                    │

​    │  4. 创建用户记录 (User.objects.create_user)                            │

​    │  5. 自动创建用户配置 (UserProfile)                                    │

​    │  6. 生成 Token (向后兼容)                                              │

​    └────────────────────────────────────────────────────────────────────────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 返回响应    │ ──► 返回用户信息和Token

​    │ 201 Created │

​    └─────────────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 注册成功    │ ──► 跳转登录页

​    └─────────────┘

### 3.2 用户登录流程

┌─────────────────────────────────────────────────────────────────────────────┐

│                              用户登录流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐

​    │  填写登录信息  │

​    │ 用户名/密码  │

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 前端表单验证  │ ──► 用户名非空、密码长度≥6

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 发送登录请求 │

​    │ POST /auth/login/

​    └──────┬──────┘

​           │

​           ▼

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                         后端处理                                        │

​    │                                                                        │

​    │  1. 接收用户名、密码                                                    │

​    │  2. authenticate(username, password) 验证                              │

​    │  3. 检查用户是否激活 (is_active)                                        │

​    │  4. Django login() 创建 Session                                         │

​    │  5. JWT: RefreshToken.for_user(user) 生成双 Token                      │

​    │  6. 返回用户信息、access_token、refresh_token                           │

​    └────────────────────────────────────────────────────────────────────────┘

​           │

​           ▼

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                         前端处理                                        │

​    │                                                                        │

​    │  1. 保存 access_token 到 localStorage                                  │

​    │  2. 保存 refresh_token 到 localStorage                                  │

​    │  3. 保存 user 信息到 localStorage                                       │

​    │  4. 计算并保存 token_expires_at (当前时间 + 60分钟)                    │

​    │  5. 启动自动刷新定时器 (每2分钟检查一次)                                │

​    └────────────────────────────────────────────────────────────────────────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 登录成功    │ ──► 跳转首页 /home

​    └─────────────┘

### 3.3 Token 刷新流程

┌─────────────────────────────────────────────────────────────────────────────┐

│                            Token 自动刷新流程                                │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐

​    │ 定时器触发   │ ──► 每2分钟执行一次

​    │ (2分钟检查) │

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 检查条件    │ ──► hasRefreshToken && isTokenExpiringSoon && hasAccessToken

​    │             │      (有RefreshToken && 5分钟内过期 && 有AccessToken)

​    └──────┬──────┘

​           │

​    ┌──────┴──────┐

​    │   条件满足？  │

​    └──────┬──────┘

​           │

​      ┌────┴────┐

​      │         │

​      ▼         ▼

​    ┌────┐    ┌────┐

​    │ Yes │   │ No │

​    └──┬──┘    └──┬──┘

​       │         │

​       ▼         ▼

┌─────────────┐   ┌─────────────┐

│ 发送刷新请求 │   │ 不做处理   │

│ /token/refresh│   │ 继续使用   │

└──────┬──────┘   └─────────────┘

​       │

​       ▼

┌─────────────┐

│ 刷新成功    │

│             │

│ 更新:       │

│ - access    │

│ - expires_at│

│ - refresh  │ (如果启用了ROTATE)

│             │

└──────┬──────┘

​       │

​       ▼

┌─────────────┐

│ 刷新失败    │

│ (401错误)  │

│             │

│ 调用logout()│

│ 清除本地状态│

│ 跳转登录页  │

└─────────────┘

### 3.4 用户退出流程

┌─────────────────────────────────────────────────────────────────────────────┐

│                              用户退出流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐

​    │ 用户点击退出 │

​    └──────┬──────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 停止刷新器  │

​    │ stopAutoRefresh() │

​    └──────┬──────┘

​           │

​           ▼

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                     Token 未过期时                                      │

​    └────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐

​    │ Token有效   │ ──► │ 发送退出请求 │ ──► │ RefreshToken│

​    │ isExpired=false│     │ /auth/logout/ │     │ 加入黑名单  │

​    └─────────────┘     └─────────────┘     └─────────────┘

​                                                      │

​                                                      ▼

​                                              ┌─────────────┐

​                                              │ 清除旧Token │

​                                              │ (向后兼容)  │

​                                              └─────────────┘

​           │

​           ▼

​    ┌────────────────────────────────────────────────────────────────────────┐

​    │                         清除本地状态                                    │

​    └────────────────────────────────────────────────────────────────────────┘

​    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐

​    │ 清除user   │ ──► │ 清除Tokens │ ──► │ 清除过期时间│

​    └─────────────┘     └─────────────┘     └─────────────┘

​           │

​           ▼

​    ┌─────────────┐

​    │ 跳转登录页  │

​    │ /login     │

​    └─────────────┘

------

## 四、接口设计

### 4.1 用户注册接口

基本信息

| 属性   | 值                    |
| :----- | :-------------------- |
| URL    | `/api/auth/register/` |
| Method | `POST`                |
| 认证   | 无需认证              |

Request Body

{

  "username": "testuser",           *// 用户名 (必填, 唯一)*

  "password": "password123",        *// 密码 (必填, 最小6位)*

  "password_confirm": "password123", *// 确认密码 (必填)*

  "email": "test@example.com",      *// 邮箱 (可选)*

  "first_name": "张",               *// 名 (可选)*

  "last_name": "三",                *// 姓 (可选)*

  "phone": "13800138000",           *// 手机号 (可选)*

  "department": "测试部",            *// 部门 (可选)*

  "position": "测试工程师"           *// 职位 (可选)*

}

Success Response (201 Created)

{

  "user": {

​    "id": 1,

​    "username": "testuser",

​    "email": "test@example.com",

​    "first_name": "张",

​    "last_name": "三",

​    "phone": "13800138000",

​    "department": "测试部",

​    "position": "测试工程师",

​    "is_active": true,

​    "date_joined": "2026-04-10T10:00:00Z",

​    "created_at": "2026-04-10T10:00:00Z",

​    "updated_at": "2026-04-10T10:00:00Z"

  },

  "token": "1a2b3c4d5e6f..."  *// Token (向后兼容)*

}

Error Response (400 Bad Request)

{

  "username": ["用户名已存在"],

  "password": ["密码不一致"]

}

### 4.2 用户登录接口

基本信息

| 属性   | 值                 |
| :----- | :----------------- |
| URL    | `/api/auth/login/` |
| Method | `POST`             |
| 认证   | 无需认证           |

Request Body

{

  "username": "testuser",      *// 用户名 (必填)*

  "password": "password123"   *// 密码 (必填)*

}

Success Response (200 OK)

{

  "user": {

​    "id": 1,

​    "username": "testuser",

​    "email": "test@example.com",

​    "first_name": "张",

​    "last_name": "三",

​    "phone": "13800138000",

​    "department": "测试部",

​    "position": "测试工程师",

​    "is_active": true,

​    "date_joined": "2026-04-10T10:00:00Z",

​    "created_at": "2026-04-10T10:00:00Z",

​    "updated_at": "2026-04-10T10:00:00Z"

  },

  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",  *// JWT Access Token*

  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...", *// JWT Refresh Token*

  "message": "登录成功"

}

Error Response (400 Bad Request)

{

  "error": "用户名或密码错误"

}

Error Response (403 Forbidden)

{

  "error": "用户已被禁用"

}

### 4.3 用户退出接口

基本信息

| 属性   | 值                  |
| :----- | :------------------ |
| URL    | `/api/auth/logout/` |
| Method | `POST`              |
| 认证   | 需要认证            |

Request Headers

Authorization: Bearer <access_token>

Request Body

{

  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  *// Refresh Token (必填)*

}

Success Response (200 OK)

{

  "message": "退出成功"

}

### 4.4 Token 刷新接口

基本信息

| 属性   | 值                         |
| :----- | :------------------------- |
| URL    | `/api/auth/token/refresh/` |
| Method | `POST`                     |
| 认证   | 无需认证                   |

Request Body

{

  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  *// Refresh Token*

}

Success Response (200 OK)

{

  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",  *// 新 Access Token*

  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  *// 新 Refresh Token (如果启用了ROTATE)*

}

Error Response (401 Unauthorized)

{

  "detail": "Token is blacklisted",

  "code": "token_not_valid"

}

### 4.5 获取当前用户信息接口

基本信息

| 属性   | 值               |
| :----- | :--------------- |
| URL    | `/api/users/me/` |
| Method | `GET`            |
| 认证   | 需要认证         |

Request Headers

Authorization: Bearer <access_token>

Success Response (200 OK)

{

  "id": 1,

  "username": "testuser",

  "email": "test@example.com",

  "first_name": "张",

  "last_name": "三",

  "avatar": "/media/avatars/user1.jpg",

  "phone": "13800138000",

  "department": "测试部",

  "position": "测试工程师",

  "is_active": true,

  "date_joined": "2026-04-10T10:00:00Z",

  "created_at": "2026-04-10T10:00:00Z",

  "updated_at": "2026-04-10T10:00:00Z"

}

### 4.6 用户资料接口

基本信息

| 属性   | 值                   |
| :----- | :------------------- |
| URL    | `/api/auth/profile/` |
| Method | `GET`                |
| 认证   | 需要认证             |

Request Headers

Authorization: Bearer <access_token>

Success Response (200 OK)

{

  "id": 1,

  "username": "testuser",

  "email": "test@example.com",

  "first_name": "张",

  "last_name": "三",

  "avatar": "/media/avatars/user1.jpg",

  "phone": "13800138000",

  "department": "测试部",

  "position": "测试工程师",

  "is_active": true,

  "date_joined": "2026-04-10T10:00:00Z",

  "created_at": "2026-04-10T10:00:00Z",

  "updated_at": "2026-04-10T10:00:00Z"

}

Error Response (401 Unauthorized)

{

  "error": "未登录"

}

### 4.7 用户列表接口

基本信息

| 属性   | 值                  |
| :----- | :------------------ |
| URL    | `/api/users/users/` |
| Method | `GET`               |
| 认证   | 需要认证            |

Request Headers

Authorization: Bearer <access_token>

Query Parameters

| 参数      | 类型   | 描述               |
| :-------- | :----- | :----------------- |
| page      | int    | 页码 (默认 1)      |
| page_size | int    | 每页数量 (默认 20) |
| search    | string | 搜索关键词 (可选)  |

Success Response (200 OK)

{

  "count": 100,

  "next": "http://api.example.com/users/?page=2",

  "previous": null,

  "results": [

​    {

​      "id": 1,

​      "username": "testuser",

​      "email": "test@example.com",

​      "first_name": "张",

​      "last_name": "三",

​      "is_active": true,

​      "date_joined": "2026-04-10T10:00:00Z"

​    }

  ]

}

### 4.8 用户详情接口

基本信息

| 属性   | 值                       |
| :----- | :----------------------- |
| URL    | `/api/users/users/<id>/` |
| Method | `GET/PUT/PATCH/DELETE`   |
| 认证   | 需要认证                 |

Success Response (200 OK)

{

  "id": 1,

  "username": "testuser",

  "email": "test@example.com",

  "first_name": "张",

  "last_name": "三",

  "avatar": "/media/avatars/user1.jpg",

  "phone": "13800138000",

  "department": "测试部",

  "position": "测试工程师",

  "is_active": true,

  "date_joined": "2026-04-10T10:00:00Z",

  "created_at": "2026-04-10T10:00:00Z",

  "updated_at": "2026-04-10T10:00:00Z"

}

------

## 五、数据库设计

### 5.1 用户表 (users_user)

CREATE TABLE `users_user` (

  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户唯一标识',

  `password` VARCHAR(128) NOT NULL COMMENT '加密后的密码',

  `last_login` DATETIME NULL COMMENT '最后登录时间',

  `is_superuser` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否为超级用户',

  `username` VARCHAR(150) NOT NULL UNIQUE COMMENT '用户名，唯一',

  `first_name` VARCHAR(150) NOT NULL DEFAULT '' COMMENT '名',

  `last_name` VARCHAR(150) NOT NULL DEFAULT '' COMMENT '姓',

  `email` VARCHAR(254) NOT NULL DEFAULT '' COMMENT '邮箱',

  `is_staff` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否可以访问管理后台',

  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否激活',

  `date_joined` DATETIME NOT NULL COMMENT '注册时间',

  

  *-- 扩展字段 --*

  `avatar` VARCHAR(500) NULL COMMENT '头像URL',

  `phone` VARCHAR(11) NULL COMMENT '手机号',

  `department` VARCHAR(100) NULL COMMENT '部门',

  `position` VARCHAR(100) NULL COMMENT '职位',

  `created_at` DATETIME NOT NULL COMMENT '创建时间',

  `updated_at` DATETIME NOT NULL COMMENT '更新时间',

  

  INDEX `idx_username` (`username`),

  INDEX `idx_email` (`email`),

  INDEX `idx_department` (`department`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 

COMMENT='用户表';

### 5.2 用户配置表 (user_profiles)

CREATE TABLE `user_profiles` (

  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置唯一标识',

  `user_id` BIGINT NOT NULL UNIQUE COMMENT '用户ID，外键',

  `theme` VARCHAR(20) NOT NULL DEFAULT 'light' COMMENT '主题 (light/dark)',

  `language` VARCHAR(10) NOT NULL DEFAULT 'zh-cn' COMMENT '语言 (zh-cn/en)',

  `timezone` VARCHAR(50) NOT NULL DEFAULT 'Asia/Shanghai' COMMENT '时区',

  `notifications` JSON NOT NULL DEFAULT ('{}') COMMENT '通知设置',

  

  FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 

COMMENT='用户配置表';

### 5.3 Django 内置表

系统还需要以下 Django 内置表：

| 表名                          | 描述                      |
| :---------------------------- | :------------------------ |
| `auth_group`                  | 权限组                    |
| `auth_permission`             | 权限表                    |
| `auth_group_permissions`      | 组权限关联                |
| `users_user_groups`           | 用户组关联                |
| `users_user_user_permissions` | 用户权限关联              |
| `authtoken_token`             | DRF Token 认证 (向后兼容) |
| `refresh_token`               | SimpleJWT Refresh Token   |
| `blacklisted_token`           | JWT 黑名单 Token          |

------

## 六、前端实现

### 6.1 Pinia Store 结构

*// stores/user.js*

export const useUserStore = defineStore('user', () => {

  *// 状态*

  const user = ref(null)

  const accessToken = ref(localStorage.getItem('access_token') || '')

  const refreshToken = ref(localStorage.getItem('refresh_token') || '')

  const tokenExpiresAt = ref(parseInt(localStorage.getItem('token_expires_at') || '0'))

  *// 计算属性*

  const isAuthenticated = computed(() => !!accessToken.value && !!user.value)

  const isTokenExpiringSoon = computed(() => {

​    if (!tokenExpiresAt.value) return false

​    return (tokenExpiresAt.value - Date.now()) < 5 * 60 * 1000 *// 5分钟*

  })

  const isTokenExpired = computed(() => {

​    if (!tokenExpiresAt.value) return false

​    return Date.now() > tokenExpiresAt.value

  })

  *// 方法*

  const login = async (credentials) => { */\* ... \*/* }

  const register = async (userData) => { */\* ... \*/* }

  const logout = async () => { */\* ... \*/* }

  const refreshAccessToken = async () => { */\* ... \*/* }

  const fetchProfile = async () => { */\* ... \*/* }

  const initAuth = async () => { */\* ... \*/* }

  const startAutoRefresh = () => { */\* ... \*/* }

  const stopAutoRefresh = () => { */\* ... \*/* }

  return { */\* ... \*/* }

})

### 6.2 路由守卫实现

*// router/index.js*

router.beforeEach(async (to, from, next) => {

  const userStore = useUserStore()

  *// 初始化认证状态*

  if (!userStore.user && userStore.accessToken) {

​    await userStore.initAuth()

  }

  *// 路由守卫判断*

  if (to.meta.requiresAuth && !userStore.isAuthenticated) {

​    next('/login')  *// 需要认证但未认证 → 跳转登录*

  } else if (to.meta.requiresGuest && userStore.isAuthenticated) {

​    next('/home')   *// 访客页面但已认证 → 跳转首页*

  } else {

​    next()          *// 其他情况放行*

  }

})

### 6.3 API 封装

*// utils/api.js*

const api = axios.create({

  baseURL: '/api',

  timeout: 30000

})

*// 请求拦截器：添加 Token*

api.interceptors.request.use(config => {

  const token = localStorage.getItem('access_token')

  if (token) {

​    config.headers.Authorization = `Bearer ${token}`

  }

  return config

})

*// 响应拦截器：处理 401*

api.interceptors.response.use(

  response => response,

  async error => {

​    if (error.response?.status === 401) {

​      *// Token 过期，尝试刷新*

​      const userStore = useUserStore()

​      try {

​        await userStore.refreshAccessToken()

​        *// 重试原请求*

​        error.config.headers.Authorization = `Bearer ${userStore.accessToken}`

​        return api.request(error.config)

​      } catch (e) {

​        *// 刷新失败，跳转登录*

​        userStore.logout()

​      }

​    }

​    return Promise.reject(error)

  }

)

------

## 七、路由汇总

| URL                        | Method               | 认证 | 描述         |
| :------------------------- | :------------------- | :--- | :----------- |
| `/api/auth/register/`      | POST                 | 否   | 用户注册     |
| `/api/auth/login/`         | POST                 | 否   | 用户登录     |
| `/api/auth/logout/`        | POST                 | 是   | 用户退出     |
| `/api/auth/token/refresh/` | POST                 | 否   | 刷新 Token   |
| `/api/auth/profile/`       | GET                  | 是   | 获取用户资料 |
| `/api/users/me/`           | GET                  | 是   | 获取当前用户 |
| `/api/users/users/`        | GET                  | 是   | 用户列表     |
| `/api/users/users/<id>/`   | GET/PUT/PATCH/DELETE | 是   | 用户详情     |

------

## 八、与其他模块的关系

┌─────────────────────────────────────────────────────────────────────────────┐

│                         用户模块与其他模块的关系                              │

└─────────────────────────────────────────────────────────────────────────────┘

​                           ┌─────────────────┐

​                           │   用户认证模块   │

​                           │   users        │

​                           └────────┬────────┘

​                                    │

​         ┌──────────────────────────┼──────────────────────────┐

​         │                          │                          │

​         ▼                          ▼                          ▼

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐

│   项目管理       │    │   项目成员      │    │   执行记录      │

│   projects      │    │ ProjectMember  │    │ executions     │

│                 │    │                │    │                │

│ - owner 字段    │    │ - user 外键    │    │ - executed_by  │

│ - created_by   │    │ - role 角色    │    │ - assignees    │

└─────────────────┘    └─────────────────┘    └─────────────────┘

​                                    │

​                                    ▼

​                           ┌─────────────────┐

​                           │   所有业务模块   │

​                           │                 │

​                           │ - created_by   │

​                           │ - updated_by   │

​                           │ - 执行人/负责人 │

​                           └─────────────────┘

------

文档版本：V1.0
编写日期：2026-04-10
基于项目：TestHub 智能测试管理平台