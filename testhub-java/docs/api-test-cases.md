# TestHub Java 后端接口测试用例

## 测试环境信息

| 项目 | 值 |
|------|-----|
| 基础URL | http://localhost:8080 |
| XXL-JOB | http://localhost:8088/xxl-job-admin |
| Redis | localhost:6379 |
| MySQL | localhost:3306 |

---

## 一、认证模块 `/api/auth`

### 1.1 用户注册
- **URL**: `POST /api/auth/register`
- **认证**: 无
- **请求体**:
```json
{
  "username": "testuser001",
  "email": "testuser001@test.com",
  "password": "password123",
  "realName": "测试用户",
  "phone": "13800138000"
}
```
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "tokenType": "Bearer",
    "expiresIn": 900,
    "user": {
      "id": 1,
      "username": "testuser001",
      "email": "testuser001@test.com",
      "realName": "测试用户",
      "phone": "13800138000",
      "avatar": null,
      "status": "enabled",
      "profile": {
        "theme": "light",
        "language": "zh-hans",
        "timezone": "Asia/Shanghai",
        "bio": null
      }
    }
  }
}
```
- **数据库表**: `sys_user`, `sys_user_profile`
- **测试场景**:
  - ✅ 正常注册成功
  - ❌ 用户名已存在
  - ❌ 邮箱已被注册
  - ❌ 用户名为空/格式错误
  - ❌ 邮箱格式错误
  - ❌ 密码长度不足6位

---

### 1.2 用户登录
- **URL**: `POST /api/auth/login`
- **认证**: 无
- **请求体**:
```json
{
  "username": "testuser001",
  "password": "password123"
}
```
- **响应** (200): 同注册响应结构
- **数据库表**: `sys_user`
- **测试场景**:
  - ✅ 正常登录成功
  - ❌ 用户名不存在
  - ❌ 密码错误
  - ❌ 用户已被禁用
  - ❌ 用户名为空

---

### 1.3 刷新Token
- **URL**: `POST /api/auth/refresh`
- **认证**: 无
- **请求体**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9..."
}
```
- **响应** (200): 同注册响应结构（新的accessToken和refreshToken）
- **数据库表**: `sys_token_blacklist`（旧refreshToken会加入黑名单）
- **测试场景**:
  - ✅ 正常刷新成功
  - ❌ refreshToken已过期
  - ❌ refreshToken格式错误
  - ❌ refreshToken已被拉黑

---

### 1.4 退出登录
- **URL**: `POST /api/auth/logout`
- **认证**: 需要（Bearer Token）
- **请求头**: `Authorization: Bearer {accessToken}`
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```
- **数据库表**: `sys_token_blacklist`
- **测试场景**:
  - ✅ 正常退出成功
  - ❌ Token无效
  - ❌ Token已过期

---

### 1.5 获取当前用户信息
- **URL**: `GET /api/auth/me`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "testuser001",
    "email": "testuser001@test.com",
    "realName": "测试用户",
    "phone": "13800138000",
    "avatar": null,
    "status": "enabled",
    "profile": {
      "theme": "light",
      "language": "zh-hans",
      "timezone": "Asia/Shanghai",
      "bio": null
    }
  }
}
```
- **数据库表**: `sys_user`, `sys_user_profile`
- **测试场景**:
  - ✅ 获取当前用户信息成功
  - ❌ 未携带Token
  - ❌ Token无效

---

### 1.6 更新个人资料
- **URL**: `PUT /api/auth/profile`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "realName": "新姓名",
  "phone": "13900139000",
  "email": "newemail@test.com",
  "avatar": "https://example.com/avatar.png"
}
```
- **响应** (200): 同1.5获取用户信息响应结构
- **数据库表**: `sys_user`
- **测试场景**:
  - ✅ 更新个人资料成功
  - ❌ 更新邮箱为已被占用的邮箱
  - ❌ 邮箱格式错误

---

### 1.7 修改密码
- **URL**: `PUT /api/auth/password`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "oldPassword": "password123",
  "newPassword": "newpassword456"
}
```
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```
- **数据库表**: `sys_user`
- **测试场景**:
  - ✅ 修改密码成功
  - ❌ 旧密码错误
  - ❌ 新密码长度不足6位

---

## 二、用户管理模块 `/api/users`

### 2.1 获取当前用户
- **URL**: `GET /api/users/me`
- **认证**: 需要（Bearer Token）
- **响应**: 同1.5
- **测试场景**:
  - ✅ 获取当前用户信息成功
  - ❌ 未携带Token

---

### 2.2 获取用户列表（管理员）
- **URL**: `GET /api/users`
- **认证**: 需要（Bearer Token + ADMIN角色）
- **参数**:
  - `keyword` (可选): 关键词搜索
  - `current` (默认1): 当前页
  - `size` (默认20): 每页大小
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "username": "testuser001",
        "email": "testuser001@test.com",
        "realName": "测试用户",
        "phone": "13800138000",
        "avatar": null,
        "status": "enabled"
      }
    ],
    "total": 1,
    "current": 1,
    "size": 20
  }
}
```
- **数据库表**: `sys_user`
- **测试场景**:
  - ✅ 管理员获取用户列表成功
  - ❌ 普通用户访问被拒绝

---

### 2.3 获取用户详情
- **URL**: `GET /api/users/{id}`
- **认证**: 需要（Bearer Token）
- **响应**: 同1.5
- **数据库表**: `sys_user`, `sys_user_profile`
- **测试场景**:
  - ✅ 获取用户详情成功
  - ❌ 用户ID不存在

---

### 2.4 更新用户（管理员）
- **URL**: `PUT /api/users/{id}`
- **认证**: 需要（Bearer Token + ADMIN角色）
- **请求体**:
```json
{
  "realName": "管理员修改的姓名",
  "email": "admin@test.com"
}
```
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "testuser001",
    "email": "admin@test.com",
    "realName": "管理员修改的姓名",
    "status": "enabled"
  }
}
```
- **数据库表**: `sys_user`
- **测试场景**:
  - ✅ 管理员更新用户成功
  - ❌ 普通用户访问被拒绝

---

### 2.5 更新头像
- **URL**: `PUT /api/users/{id}/avatar`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `avatarUrl`: 头像URL
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": "https://example.com/new-avatar.png"
}
```
- **数据库表**: `sys_user`
- **测试场景**:
  - ✅ 更新头像成功
  - ❌ 用户不存在

---

### 2.6 禁用用户（管理员）
- **URL**: `PUT /api/users/{id}/disable`
- **认证**: 需要（Bearer Token + ADMIN角色）
- **响应** (200): 空
- **数据库表**: `sys_user`
- **测试场景**:
  - ✅ 禁用用户成功
  - ❌ 普通用户访问被拒绝

---

### 2.7 启用用户（管理员）
- **URL**: `PUT /api/users/{id}/enable`
- **认证**: 需要（Bearer Token + ADMIN角色）
- **响应** (200): 空
- **数据库表**: `sys_user`
- **测试场景**:
  - ✅ 启用用户成功
  - ❌ 普通用户访问被拒绝

---

## 三、项目管理模块 `/api/projects`

### 3.1 创建项目
- **URL**: `POST /api/projects`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "name": "我的测试项目",
  "description": "这是一个测试项目",
  "status": "active"
}
```
- **响应** (201):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "name": "我的测试项目",
    "description": "这是一个测试项目",
    "status": "active",
    "ownerId": 1,
    "icon": null,
    "sortOrder": 0,
    "includeTestCases": true,
    "includeAutomatedTests": false,
    "createdAt": "2026-04-29T10:00:00",
    "updatedAt": "2026-04-29T10:00:00"
  }
}
```
- **数据库表**: `prj_project`, `prj_project_member`, `prj_project_environment`
- **测试场景**:
  - ✅ 创建项目成功（创建者自动成为owner，同时创建默认环境）
  - ❌ 项目名称为空

---

### 3.2 获取我的项目列表
- **URL**: `GET /api/projects`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "我的测试项目",
      "description": "这是一个测试项目",
      "status": "active",
      "ownerId": 1
    }
  ]
}
```
- **数据库表**: `prj_project`, `prj_project_member`
- **测试场景**:
  - ✅ 获取当前用户参与的项目列表成功
  - ❌ 未携带Token

---

### 3.3 分页查询项目
- **URL**: `GET /api/projects/page`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `keyword` (可选): 关键词搜索
  - `current` (默认1): 当前页
  - `size` (默认20): 每页大小
- **响应** (200): 包含分页信息
- **数据库表**: `prj_project`, `prj_project_member`
- **测试场景**:
  - ✅ 分页查询项目成功
  - ✅ 按关键词搜索项目

---

### 3.4 获取项目详情
- **URL**: `GET /api/projects/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 项目详情
- **数据库表**: `prj_project`
- **测试场景**:
  - ✅ 获取项目详情成功
  - ❌ 项目不存在

---

### 3.5 更新项目
- **URL**: `PUT /api/projects/{id}`
- **认证**: 需要（Bearer Token + 项目owner/ADMIN）
- **请求体**:
```json
{
  "name": "更新的项目名称",
  "description": "更新的描述",
  "status": "completed"
}
```
- **响应** (200): 更新后的项目信息
- **数据库表**: `prj_project`
- **测试场景**:
  - ✅ owner更新项目成功
  - ✅ ADMIN更新项目成功（不受项目成员限制）
  - ❌ 普通成员更新被拒绝（返回403）
  - ❌ 非项目成员更新被拒绝（返回403）

---

### 3.6 删除项目
- **URL**: `DELETE /api/projects/{id}`
- **认证**: 需要（Bearer Token + 项目owner/ADMIN）
- **响应** (200): 空
- **数据库表**: `prj_project`, `prj_project_member`
- **测试场景**:
  - ✅ owner删除项目成功
  - ✅ ADMIN删除项目成功
  - ❌ 普通成员删除被拒绝（返回403）

---

### 3.7 搜索项目
- **URL**: `GET /api/projects/search`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `keyword`: 关键词（必填）
- **响应** (200): 项目列表
- **数据库表**: `prj_project`
- **测试场景**:
  - ✅ 按关键词搜索项目成功

---

### 3.8 获取项目成员列表
- **URL**: `GET /api/projects/{id}/members`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "projectId": 1,
      "userId": 1,
      "role": "owner",
      "joinedAt": "2026-04-29T10:00:00"
    }
  ]
}
```
- **数据库表**: `prj_project_member`
- **测试场景**:
  - ✅ 获取项目成员列表成功
  - ❌ 项目不存在

---

### 3.9 添加项目成员
- **URL**: `POST /api/projects/{id}/members`
- **认证**: 需要（Bearer Token + 项目owner/ADMIN）
- **参数**:
  - `userId`: 用户ID（表单参数）
  - `role` (默认tester): 角色（表单参数）
- **响应** (201): 成员信息
- **数据库表**: `prj_project_member`
- **测试场景**:
  - ✅ owner添加成员成功
  - ✅ ADMIN添加成员成功
  - ❌ 普通成员添加被拒绝（返回403）
  - ❌ 非项目成员添加被拒绝（返回403）
  - ❌ 用户已存在项目中（返回业务错误）

---

### 3.10 更新成员角色
- **URL**: `PUT /api/projects/{projectId}/members/{memberId}`
- **认证**: 需要（Bearer Token + 项目owner/ADMIN）
- **参数**:
  - `role`: 新角色（表单参数）
- **响应** (200): 更新后的成员信息
- **数据库表**: `prj_project_member`
- **测试场景**:
  - ✅ owner更新成员角色成功
  - ✅ ADMIN更新成员角色成功
  - ❌ 普通成员更新被拒绝（返回403）
  - ❌ 成员不存在（返回业务错误）

---

### 3.11 移除项目成员
- **URL**: `DELETE /api/projects/{id}/members/{userId}`
- **认证**: 需要（Bearer Token + 项目owner/ADMIN）
- **响应** (200): 空
- **数据库表**: `prj_project_member`
- **测试场景**:
  - ✅ owner移除成员成功
  - ✅ ADMIN移除成员成功
  - ❌ 普通成员移除被拒绝（返回403）
  - ❌ 成员不存在（无报错，沉默成功）

---

### 3.12 获取当前用户在项目中的角色
- **URL**: `GET /api/projects/{id}/members/role`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": "owner"
}
```
- **数据库表**: `prj_project_member`
- **测试场景**:
  - ✅ 获取角色成功（返回角色字符串）
  - ❌ 用户不在项目中（返回null）

---

### 3.13 获取项目环境列表
- **URL**: `GET /api/projects/{id}/environments`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "projectId": 1,
      "name": "默认环境",
      "description": null,
      "baseUrl": "",
      "variables": "{}",
      "isDefault": true,
      "sortOrder": 0,
      "createdAt": "2026-04-29T10:00:00",
      "updatedAt": "2026-04-29T10:00:00"
    }
  ]
}
```
- **数据库表**: `prj_project_environment`
- **测试场景**:
  - ✅ 获取环境列表成功
  - ✅ 新建项目自动包含默认环境

---

### 3.14 获取项目默认环境
- **URL**: `GET /api/projects/{id}/environments/default`
- **认证**: 需要（Bearer Token）
- **响应** (200): 环境信息
- **数据库表**: `prj_project_environment`
- **测试场景**:
  - ✅ 获取默认环境成功
  - ❌ 没有默认环境（返回null）

---

### 3.15 创建项目环境
- **URL**: `POST /api/projects/{id}/environments`
- **认证**: 需要（Bearer Token + 项目owner/ADMIN）
- **请求体**:
```json
{
  "name": "测试环境",
  "description": "UAT测试环境",
  "baseUrl": "https://uat.example.com",
  "variables": "{\"API_URL\": \"https://test.example.com\"}",
  "isDefault": false,
  "sortOrder": 1
}
```
- **响应** (201): 创建的环境信息
- **数据库表**: `prj_project_environment`
- **测试场景**:
  - ✅ owner创建环境成功
  - ✅ ADMIN创建环境成功
  - ✅ variables字段可以接收空对象 {}
  - ❌ 普通成员创建被拒绝（返回403）

---

### 3.16 更新项目环境
- **URL**: `PUT /api/projects/{projectId}/environments/{envId}`
- **认证**: 需要（Bearer Token + 项目owner/ADMIN）
- **请求体**:
```json
{
  "name": "更新的环境名称",
  "description": "更新的描述",
  "baseUrl": "https://new-url.example.com",
  "variables": "{\"KEY\": \"VALUE\"}"
}
```
- **响应** (200): 更新后的环境信息
- **数据库表**: `prj_project_environment`
- **测试场景**:
  - ✅ owner更新环境成功
  - ✅ ADMIN更新环境成功
  - ❌ 普通成员更新被拒绝（返回403）
  - ❌ 环境不存在（返回业务错误）

---

### 3.17 删除项目环境
- **URL**: `DELETE /api/projects/{projectId}/environments/{envId}`
- **认证**: 需要（Bearer Token + 项目owner/ADMIN）
- **响应** (200): 空
- **数据库表**: `prj_project_environment`
- **测试场景**:
  - ✅ owner删除环境成功
  - ✅ ADMIN删除环境成功
  - ❌ 普通成员删除被拒绝（返回403）
  - ❌ 环境不存在（无报错，沉默成功）

---

### 3.18 设置默认环境
- **URL**: `PUT /api/projects/{projectId}/environments/{envId}/default`
- **认证**: 需要（Bearer Token + 项目owner/ADMIN）
- **响应** (200): 空
- **数据库表**: `prj_project_environment`
- **测试场景**:
  - ✅ owner设置默认环境成功
  - ✅ ADMIN设置默认环境成功
  - ✅ 原默认环境自动取消默认
  - ❌ 普通成员设置被拒绝（返回403）

---

## 四、角色权限说明

### 4.1 角色类型
| 角色 | 说明 |
|------|------|
| ADMIN | 系统管理员，拥有所有权限 |
| owner | 项目负责人，拥有项目完全控制权 |
| developer | 开发者 |
| tester | 测试人员 |
| viewer | 查看者 |

### 4.2 权限矩阵

| 操作 | owner | ADMIN | developer | tester | viewer |
|------|-------|-------|-----------|--------|--------|
| 更新项目 | ✅ | ✅ | ❌ | ❌ | ❌ |
| 删除项目 | ✅ | ✅ | ❌ | ❌ | ❌ |
| 添加成员 | ✅ | ✅ | ❌ | ❌ | ❌ |
| 更新成员角色 | ✅ | ✅ | ❌ | ❌ | ❌ |
| 移除成员 | ✅ | ✅ | ❌ | ❌ | ❌ |
| 创建环境 | ✅ | ✅ | ❌ | ❌ | ❌ |
| 更新环境 | ✅ | ✅ | ❌ | ❌ | ❌ |
| 删除环境 | ✅ | ✅ | ❌ | ❌ | ❌ |
| 设置默认环境 | ✅ | ✅ | ❌ | ❌ | ❌ |

### 4.3 is_superuser 和 is_staff 字段
- `is_superuser`: 是否为超级管理员（对应ADMIN角色检查）
- `is_staff`: 是否可以访问管理后台
- `role_name`: 用户角色名称

---

## 五、错误码汇总

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未认证/Token无效 |
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |
| 1001 | Token已过期 |
| 1002 | Token无效 |
| 1101 | 没有权限访问该资源 |
| 2001 | 业务逻辑错误（如用户名已存在等） |

---

## 六、业务错误信息

| 错误信息 | 说明 |
|---------|------|
| 没有权限更新该项目 | 无权更新项目 |
| 没有权限删除该项目 | 无权删除项目 |
| 没有权限添加项目成员 | 无权添加成员 |
| 没有权限更新成员角色 | 无权更新成员角色 |
| 没有权限移除项目成员 | 无权移除成员 |
| 没有权限创建项目环境 | 无权创建环境 |
| 没有权限更新项目环境 | 无权更新环境 |
| 没有权限删除项目环境 | 无权删除环境 |
| 没有权限设置默认环境 | 无权设置默认环境 |
| 用户已是项目成员 | 成员已存在 |
| 成员不存在 | 成员记录不存在 |
| 项目不存在 | 项目不存在 |
| 环境不存在 | 环境不存在 |

---

## 七、测试数据准备SQL

```sql
-- 创建测试管理员用户（密码: admin123）
INSERT INTO sys_user (username, email, password, real_name, phone, status, is_superuser, role_name)
VALUES ('testadmin', 'admin@test.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '管理员', '13700137000', 'enabled', 1, 'ADMIN');

-- 创建普通测试用户（密码: password123）
INSERT INTO sys_user (username, email, password, real_name, phone, status, is_superuser, role_name)
VALUES ('testuser001', 'user@test.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '普通用户', '13800138000', 'enabled', 0, 'USER');

-- 创建第二个普通用户（用于添加成员测试）
INSERT INTO sys_user (username, email, password, real_name, phone, status, is_superuser, role_name)
VALUES ('testuser002', 'user2@test.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '普通用户2', '13900139000', 'enabled', 0, 'USER');

-- 创建用户配置
INSERT INTO sys_user_profile (user_id, theme, language, timezone)
VALUES (1, 'light', 'zh-hans', 'Asia/Shanghai');

INSERT INTO sys_user_profile (user_id, theme, language, timezone)
VALUES (2, 'light', 'zh-hans', 'Asia/Shanghai');

INSERT INTO sys_user_profile (user_id, theme, language, timezone)
VALUES (3, 'light', 'zh-hans', 'Asia/Shanghai');

-- 创建测试项目（owner为用户1）
INSERT INTO prj_project (name, description, status, owner_id)
VALUES ('测试项目', '这是一个测试项目', 'active', 1);

-- 项目1的默认环境会自动创建（通过Service）
```

---

## 八、完整测试流程

### 8.1 权限测试流程（推荐）

1. **使用用户1（owner/管理员）登录**
   - 注册或登录获取token
   - 创建项目，获取projectId

2. **测试owner权限（应该成功）**
   - 更新项目 → 成功
   - 添加成员（用户2）→ 成功
   - 更新成员角色 → 成功
   - 创建环境 → 成功
   - 设置默认环境 → 成功
   - 删除环境 → 成功

3. **使用用户2（普通成员）登录**
   - 获取项目成员角色 → 应返回 tester
   - 尝试添加成员 → 应返回403
   - 尝试更新项目 → 应返回403
   - 尝试创建环境 → 应返回403

4. **使用管理员登录**
   - 任何项目操作都应成功（不受项目成员限制）

### 8.2 环境变量测试

测试variables字段处理：
- 发送 `"variables": {}` → 应正常处理
- 发送 `"variables": "{\"key\": \"value\"}"` → 应正常处理
- 发送 `"variables": null` → 应正常处理

---

## 九、数据库表结构

### sys_user 表关键字段
```sql
- id: BIGINT 主键
- username: VARCHAR 用户名
- email: VARCHAR 邮箱
- password: VARCHAR 密码（BCrypt加密）
- real_name: VARCHAR 真实姓名
- phone: VARCHAR 电话
- avatar: VARCHAR 头像URL
- status: VARCHAR 状态（enabled/disabled）
- is_superuser: TINYINT 是否超级管理员
- is_staff: TINYINT 是否可访问后台
- role_name: VARCHAR 角色名称
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### prj_project_member 表关键字段
```sql
- id: BIGINT 主键
- project_id: BIGINT 项目ID
- user_id: BIGINT 用户ID
- role: VARCHAR 角色（owner/admin/developer/tester/viewer）
- joined_at: DATETIME 加入时间
- is_deleted: TINYINT 逻辑删除
```

### prj_project_environment 表关键字段
```sql
- id: BIGINT 主键
- project_id: BIGINT 项目ID
- name: VARCHAR 环境名称
- base_url: VARCHAR 基础URL
- description: VARCHAR 环境描述
- variables: TEXT 环境变量（JSON格式）
- is_default: TINYINT 是否默认环境
- sort_order: INT 排序
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

---

## 十、测试用例模块 `/api/testcases`

### 10.1 分页查询用例
- **URL**: `GET /api/testcases`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `projectId` (可选): 项目ID
  - `keyword` (可选): 关键词搜索
  - `priority` (可选): 优先级 (low/medium/high/critical)
  - `status` (可选): 状态 (draft/active/deprecated)
  - `current` (默认1): 当前页
  - `size` (默认10): 每页大小
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "projectId": 1,
        "title": "登录功能测试",
        "description": "测试用户登录功能",
        "priority": "high",
        "type": "functional",
        "status": "active",
        "precondition": "用户已注册",
        "expectedResult": "登录成功",
        "stepCount": 3,
        "createdAt": "2026-04-29T10:00:00"
      }
    ],
    "total": 1,
    "current": 1,
    "size": 10
  }
}
```
- **数据库表**: `tc_test_case`, `tc_test_case_step`
- **测试场景**:
  - ✅ 分页查询用例成功
  - ✅ 按项目ID筛选
  - ✅ 按关键词搜索
  - ✅ 按优先级筛选
  - ✅ 按状态筛选

---

### 10.2 获取用例详情
- **URL**: `GET /api/testcases/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "projectId": 1,
    "title": "登录功能测试",
    "description": "测试用户登录功能",
    "priority": "high",
    "type": "functional",
    "status": "active",
    "precondition": "用户已注册",
    "expectedResult": "登录成功",
    "steps": [
      {
        "id": 1,
        "stepNumber": 1,
        "description": "输入用户名",
        "expectedResult": "用户名显示在输入框"
      },
      {
        "id": 2,
        "stepNumber": 2,
        "description": "输入密码",
        "expectedResult": "密码显示为***"
      },
      {
        "id": 3,
        "stepNumber": 3,
        "description": "点击登录按钮",
        "expectedResult": "跳转到首页"
      }
    ]
  }
}
```
- **数据库表**: `tc_test_case`, `tc_test_case_step`
- **测试场景**:
  - ✅ 获取用例详情成功（含步骤）
  - ❌ 用例不存在

---

### 10.3 创建用例
- **URL**: `POST /api/testcases`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "projectId": 1,
  "title": "注册功能测试",
  "description": "测试用户注册功能",
  "priority": "medium",
  "type": "functional",
  "status": "draft",
  "precondition": "无",
  "expectedResult": "注册成功并跳转到登录页",
  "steps": [
    {
      "stepNumber": 1,
      "description": "点击注册按钮",
      "expectedResult": "跳转到注册页"
    },
    {
      "stepNumber": 2,
      "description": "填写注册信息",
      "expectedResult": "信息正确填写"
    },
    {
      "stepNumber": 3,
      "description": "点击提交按钮",
      "expectedResult": "注册成功"
    }
  ]
}
```
- **响应** (201): 创建的用例信息
- **数据库表**: `tc_test_case`, `tc_test_case_step`
- **测试场景**:
  - ✅ 创建用例成功（自动创建关联步骤）
  - ✅ 创建用例时不传步骤（成功，步骤为空）
  - ❌ 项目ID为空
  - ❌ 用例标题为空

---

### 10.4 更新用例
- **URL**: `PUT /api/testcases/{id}`
- **认证**: 需要（Bearer Token）
- **请求体**: 同10.3
- **响应** (200): 更新后的用例信息
- **数据库表**: `tc_test_case`, `tc_test_case_step`
- **测试场景**:
  - ✅ 更新用例成功（自动替换步骤）
  - ❌ 用例不存在

---

### 10.5 删除用例
- **URL**: `DELETE /api/testcases/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 空
- **数据库表**: `tc_test_case`, `tc_test_case_step`
- **测试场景**:
  - ✅ 删除用例成功（级联删除步骤）
  - ❌ 用例不存在

---

### 10.6 获取用例步骤
- **URL**: `GET /api/testcases/{id}/steps`
- **认证**: 需要（Bearer Token）
- **响应** (200): 步骤列表
- **数据库表**: `tc_test_case_step`
- **测试场景**:
  - ✅ 获取步骤列表成功（按stepNumber排序）
  - ❌ 用例不存在

---

## 十一、测试套件模块 `/api/testsuites`

### 11.1 分页查询套件
- **URL**: `GET /api/testsuites`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `projectId` (可选): 项目ID
  - `keyword` (可选): 关键词搜索
  - `current` (默认1): 当前页
  - `size` (默认10): 每页大小
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "projectId": 1,
        "name": "登录功能套件",
        "description": "包含所有登录相关用例",
        "sortOrder": 0,
        "caseCount": 5,
        "createdAt": "2026-04-29T10:00:00"
      }
    ],
    "total": 1,
    "current": 1,
    "size": 10
  }
}
```
- **数据库表**: `ts_test_suite`, `ts_test_suite_case`
- **测试场景**:
  - ✅ 分页查询套件成功
  - ✅ 按项目ID筛选
  - ✅ 按关键词搜索

---

### 11.2 获取套件详情
- **URL**: `GET /api/testsuites/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 套件详情
- **数据库表**: `ts_test_suite`
- **测试场景**:
  - ✅ 获取套件详情成功
  - ❌ 套件不存在

---

### 11.3 创建套件
- **URL**: `POST /api/testsuites`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "projectId": 1,
  "name": "注册功能套件",
  "description": "包含所有注册相关用例",
  "sortOrder": 1,
  "caseIds": [1, 2, 3]
}
```
- **响应** (201): 创建的套件信息
- **数据库表**: `ts_test_suite`, `ts_test_suite_case`
- **测试场景**:
  - ✅ 创建套件成功（自动创建用例关联）
  - ✅ 创建套件时不传caseIds（成功）
  - ❌ 项目ID为空
  - ❌ 套件名称为空

---

### 11.4 更新套件
- **URL**: `PUT /api/testsuites/{id}`
- **认证**: 需要（Bearer Token）
- **请求体**: 同11.3
- **响应** (200): 更新后的套件信息
- **数据库表**: `ts_test_suite`, `ts_test_suite_case`
- **测试场景**:
  - ✅ 更新套件成功（自动替换用例关联）
  - ❌ 套件不存在

---

### 11.5 删除套件
- **URL**: `DELETE /api/testsuites/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 空
- **数据库表**: `ts_test_suite`, `ts_test_suite_case`
- **测试场景**:
  - ✅ 删除套件成功（级联删除关联）
  - ❌ 套件不存在

---

### 11.6 获取套件用例ID列表
- **URL**: `GET /api/testsuites/{id}/cases`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [1, 2, 3]
}
```
- **数据库表**: `ts_test_suite_case`
- **测试场景**:
  - ✅ 获取用例ID列表成功

---

### 11.7 添加用例到套件
- **URL**: `POST /api/testsuites/{id}/cases`
- **认证**: 需要（Bearer Token）
- **请求体**: `[4, 5, 6]`
- **响应** (200): 空
- **数据库表**: `ts_test_suite_case`
- **测试场景**:
  - ✅ 添加用例成功
  - ❌ 套件不存在

---

### 11.8 从套件移除用例
- **URL**: `DELETE /api/testsuites/{id}/cases`
- **认证**: 需要（Bearer Token）
- **请求体**: `[4, 5]`
- **响应** (200): 空
- **数据库表**: `ts_test_suite_case`
- **测试场景**:
  - ✅ 移除用例成功

---

## 十二、测试计划模块 `/api/test-plans`

### 12.1 分页查询计划
- **URL**: `GET /api/test-plans`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `projectId` (可选): 项目ID
  - `keyword` (可选): 关键词搜索
  - `status` (可选): 状态 (pending/in_progress/completed)
  - `current` (默认1): 当前页
  - `size` (默认10): 每页大小
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "projectId": 1,
        "name": "V1.0回归测试",
        "description": "V1.0版本回归测试计划",
        "startDate": "2026-05-01T00:00:00",
        "endDate": "2026-05-10T00:00:00",
        "status": "pending",
        "assigneeId": 1,
        "assigneeName": "管理员",
        "totalCases": 50,
        "passedCases": 0,
        "failedCases": 0,
        "createdAt": "2026-04-29T10:00:00"
      }
    ],
    "total": 1,
    "current": 1,
    "size": 10
  }
}
```
- **数据库表**: `exec_test_plan`
- **测试场景**:
  - ✅ 分页查询计划成功
  - ✅ 按项目ID筛选
  - ✅ 按关键词搜索
  - ✅ 按状态筛选

---

### 12.2 获取计划详情
- **URL**: `GET /api/test-plans/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 计划详情
- **数据库表**: `exec_test_plan`
- **测试场景**:
  - ✅ 获取计划详情成功
  - ❌ 计划不存在

---

### 12.3 创建计划
- **URL**: `POST /api/test-plans`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "projectId": 1,
  "name": "V2.0功能测试",
  "description": "V2.0新功能测试计划",
  "startDate": "2026-06-01T00:00:00",
  "endDate": "2026-06-15T00:00:00",
  "status": "pending",
  "assigneeId": 1
}
```
- **响应** (201): 创建的计划信息
- **数据库表**: `exec_test_plan`
- **测试场景**:
  - ✅ 创建计划成功
  - ❌ 项目ID为空
  - ❌ 计划名称为空

---

### 12.4 更新计划
- **URL**: `PUT /api/test-plans/{id}`
- **认证**: 需要（Bearer Token）
- **请求体**: 同12.3
- **响应** (200): 更新后的计划信息
- **数据库表**: `exec_test_plan`
- **测试场景**:
  - ✅ 更新计划成功
  - ❌ 计划不存在

---

### 12.5 删除计划
- **URL**: `DELETE /api/test-plans/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 空
- **数据库表**: `exec_test_plan`
- **测试场景**:
  - ✅ 删除计划成功
  - ❌ 计划不存在

---

## 十三、测试执行模块 `/api/test-runs`

### 13.1 分页查询执行记录
- **URL**: `GET /api/test-runs`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `planId` (可选): 计划ID
  - `suiteId` (可选): 套件ID
  - `status` (可选): 状态 (pending/running/completed/failed)
  - `current` (默认1): 当前页
  - `size` (默认10): 每页大小
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "planId": 1,
        "suiteId": 1,
        "status": "completed",
        "executorId": 1,
        "executorName": "管理员",
        "suiteName": "登录功能套件",
        "startedAt": "2026-04-29T10:00:00",
        "completedAt": "2026-04-29T10:30:00",
        "totalCount": 5,
        "passedCount": 4,
        "failedCount": 1,
        "createdAt": "2026-04-29T10:00:00"
      }
    ],
    "total": 1,
    "current": 1,
    "size": 10
  }
}
```
- **数据库表**: `exec_test_run`, `exec_test_run_case`
- **测试场景**:
  - ✅ 分页查询执行记录成功
  - ✅ 按计划ID筛选
  - ✅ 按套件ID筛选
  - ✅ 按状态筛选

---

### 13.2 创建执行记录
- **URL**: `POST /api/test-runs`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "planId": 1,
  "suiteId": 1
}
```
- **响应** (201): 创建的执行记录
- **数据库表**: `exec_test_run`
- **测试场景**:
  - ✅ 创建执行记录成功

---

### 13.3 开始执行
- **URL**: `POST /api/test-runs/{id}/start`
- **认证**: 需要（Bearer Token）
- **响应** (200): 更新后的执行记录
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "status": "running",
    "startedAt": "2026-04-29T10:00:00"
  }
}
```
- **数据库表**: `exec_test_run`
- **测试场景**:
  - ✅ 开始执行成功（状态变为running）
  - ❌ 执行记录不存在

---

### 13.4 完成执行
- **URL**: `POST /api/test-runs/{id}/complete`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "passedCount": 4,
  "failedCount": 1
}
```
- **响应** (200): 更新后的执行记录
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "status": "failed",
    "completedAt": "2026-04-29T10:30:00",
    "passedCount": 4,
    "failedCount": 1
  }
}
```
- **数据库表**: `exec_test_run`
- **测试场景**:
  - ✅ 完成执行成功（passedCount>0时status为failed）
  - ✅ 完成执行成功（passedCount=0时status为completed）
  - ❌ 执行记录不存在

---

### 13.5 更新用例执行结果
- **URL**: `POST /api/test-runs/{runId}/cases`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "caseId": 1,
  "caseStatus": "passed",
  "result": "实际结果与预期一致",
  "bugIds": "BUG-001,BUG-002"
}
```
- **响应** (200): 空
- **数据库表**: `exec_test_run_case`
- **测试场景**:
  - ✅ 更新用例执行结果成功
  - ✅ caseStatus可选值: untested/passed/failed/blocked/retest

---

### 13.6 获取执行的用例列表
- **URL**: `GET /api/test-runs/{id}/cases`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "runId": 1,
      "testCaseId": 1,
      "status": "passed",
      "result": "实际结果与预期一致",
      "bugIds": "BUG-001",
      "executorId": 1,
      "executorName": "管理员",
      "executedAt": "2026-04-29T10:15:00",
      "testCaseTitle": "登录功能测试"
    }
  ]
}
```
- **数据库表**: `exec_test_run_case`, `tc_test_case`
- **测试场景**:
  - ✅ 获取用例列表成功

---

### 13.7 删除执行记录
- **URL**: `DELETE /api/test-runs/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 空
- **数据库表**: `exec_test_run`, `exec_test_run_case`
- **测试场景**:
  - ✅ 删除执行记录成功（级联删除用例记录）
  - ❌ 执行记录不存在

---

## 十四、数据库表结构（新增）

### tc_test_case 表
```sql
- id: BIGINT 主键
- project_id: BIGINT 项目ID
- title: VARCHAR 用例标题
- description: TEXT 用例描述
- priority: VARCHAR 优先级 (low/medium/high/critical)
- type: VARCHAR 类型 (functional/integration/api/ui/performance/security)
- status: VARCHAR 状态 (draft/active/deprecated)
- precondition: TEXT 前置条件
- expected_result: TEXT 预期结果
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### tc_test_case_step 表
```sql
- id: BIGINT 主键
- test_case_id: BIGINT 用例ID
- step_number: INT 步骤序号
- description: TEXT 步骤描述
- expected_result: TEXT 预期结果
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### ts_test_suite 表
```sql
- id: BIGINT 主键
- project_id: BIGINT 项目ID
- name: VARCHAR 套件名称
- description: TEXT 套件描述
- sort_order: INT 排序
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### ts_test_suite_case 表
```sql
- id: BIGINT 主键
- suite_id: BIGINT 套件ID
- test_case_id: BIGINT 用例ID
- sort_order: INT 排序
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
```

### exec_test_plan 表
```sql
- id: BIGINT 主键
- project_id: BIGINT 项目ID
- name: VARCHAR 计划名称
- description: TEXT 计划描述
- start_date: DATETIME 开始日期
- end_date: DATETIME 结束日期
- status: VARCHAR 状态 (pending/in_progress/completed)
- assignee_id: BIGINT 负责人ID
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### exec_test_run 表
```sql
- id: BIGINT 主键
- plan_id: BIGINT 计划ID
- suite_id: BIGINT 套件ID
- status: VARCHAR 状态 (pending/running/completed/failed)
- executor_id: BIGINT 执行人ID
- started_at: DATETIME 开始时间
- completed_at: DATETIME 完成时间
- total_count: INT 总用例数
- passed_count: INT 通过数
- failed_count: INT 失败数
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### exec_test_run_case 表
```sql
- id: BIGINT 主键
- run_id: BIGINT 执行ID
- test_case_id: BIGINT 用例ID
- status: VARCHAR 状态 (untested/passed/failed/blocked/retest)
- result: TEXT 执行结果
- bug_ids: VARCHAR 关联缺陷ID
- executor_id: BIGINT 执行人ID
- executed_at: DATETIME 执行时间
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

---

## 十五、业务错误信息（新增）

| 错误信息 | 说明 |
|---------|------|
| 用例不存在 | 测试用例不存在 |
| 套件不存在 | 测试套件不存在 |
| 计划不存在 | 测试计划不存在 |
| 执行记录不存在 | 测试执行记录不存在 |

---

## 十六、API Testing 模块 `/api/api-projects`

### 16.1 分页查询API项目
- **URL**: `GET /api/api-projects`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `projectId` (可选): 关联项目ID
  - `keyword` (可选): 关键词搜索
  - `current` (默认1): 当前页
  - `size` (默认10): 每页大小
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "projectId": 1,
        "name": "用户服务API",
        "description": "用户服务接口集合",
        "baseUrl": "https://api.example.com",
        "createdAt": "2026-04-29T10:00:00"
      }
    ],
    "total": 1,
    "current": 1,
    "size": 10
  }
}
```
- **数据库表**: `api_project`
- **测试场景**:
  - ✅ 分页查询成功
  - ✅ 按项目ID筛选

---

### 16.2 创建API项目
- **URL**: `POST /api/api-projects`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "projectId": 1,
  "name": "订单服务API",
  "description": "订单服务接口集合",
  "baseUrl": "https://api.example.com/order"
}
```
- **响应** (200): 创建的API项目信息
- **数据库表**: `api_project`
- **测试场景**:
  - ✅ 创建API项目成功
  - ❌ 项目名称为空

---

### 16.3 获取API项目详情
- **URL**: `GET /api/api-projects/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): API项目详情
- **数据库表**: `api_project`

---

### 16.4 更新API项目
- **URL**: `PUT /api/api-projects/{id}`
- **认证**: 需要（Bearer Token）
- **请求体**: 同16.2
- **响应** (200): 更新后的API项目
- **数据库表**: `api_project`

---

### 16.5 删除API项目
- **URL**: `DELETE /api/api-projects/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 空
- **数据库表**: `api_project`

---

## 十七、API集合模块 `/api/api-collections`

### 17.1 分页查询集合
- **URL**: `GET /api/api-collections`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `projectId` (可选): API项目ID
  - `parentId` (可选): 父集合ID
  - `keyword` (可选): 关键词搜索
  - `current` (默认1): 当前页
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "projectId": 1,
        "parentId": null,
        "name": "用户模块",
        "description": "用户相关接口",
        "sortOrder": 0,
        "createdAt": "2026-04-29T10:00:00"
      }
    ],
    "total": 1,
    "current": 1,
    "size": 10
  }
}
```
- **数据库表**: `api_collection`

---

### 17.2 获取集合树
- **URL**: `GET /api/api-collections/tree?projectId=1`
- **认证**: 需要（Bearer Token）
- **响应** (200): 集合树形结构
- **数据库表**: `api_collection`

---

### 17.3 创建集合
- **URL**: `POST /api/api-collections`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "projectId": 1,
  "parentId": null,
  "name": "登录模块",
  "description": "登录相关接口",
  "sortOrder": 1
}
```
- **响应** (200): 创建的集合信息

---

### 17.4 更新集合
- **URL**: `PUT /api/api-collections/{id}`
- **认证**: 需要（Bearer Token）
- **请求体**: 同17.3
- **响应** (200): 更新后的集合

---

### 17.5 删除集合
- **URL**: `DELETE /api/api-collections/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 空

---

## 十八、API请求模块 `/api/api-requests`

### 18.1 分页查询请求
- **URL**: `GET /api/api-requests`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `collectionId` (可选): 集合ID
  - `keyword` (可选): 关键词搜索
  - `current` (默认1): 当前页
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "collectionId": 1,
        "name": "用户登录",
        "method": "POST",
        "url": "{{baseUrl}}/login",
        "headers": "{\"Content-Type\": \"application/json\"}",
        "bodyType": "json",
        "bodyContent": "{\"username\": \"{{username}}\", \"password\": \"{{password}}\"}",
        "authType": "none",
        "assertions": "[{\"type\": \"status_code\", \"name\": \"状态码\", \"expected\": 200}]",
        "extractors": "[{\"type\": \"json_path\", \"path\": \"$.data.token\", \"variable\": \"token\"}]",
        "sortOrder": 0
      }
    ],
    "total": 1,
    "current": 1,
    "size": 10
  }
}
```
- **数据库表**: `api_request`

---

### 18.2 创建API请求
- **URL**: `POST /api/api-requests`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "collectionId": 1,
  "name": "获取用户信息",
  "method": "GET",
  "url": "{{baseUrl}}/users/{{userId}}",
  "headers": "{\"Authorization\": \"Bearer {{token}}\"}",
  "bodyType": "none",
  "authType": "bearer",
  "authConfig": "{\"token\": \"{{token}}\"}",
  "assertions": "[{\"type\": \"status_code\", \"name\": \"状态码验证\", \"expected\": 200}]",
  "extractors": "[{\"type\": \"json_path\", \"path\": \"$.data.userId\", \"variable\": \"userId\"}]",
  "sortOrder": 0
}
```
- **响应** (200): 创建的API请求

---

### 18.3 更新API请求
- **URL**: `PUT /api/api-requests/{id}`
- **认证**: 需要（Bearer Token）
- **请求体**: 同18.2
- **响应** (200): 更新后的API请求

---

### 18.4 删除API请求
- **URL**: `DELETE /api/api-requests/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 空

---

### 18.5 执行API请求
- **URL**: `POST /api/api-requests/execute`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "requestId": 1,
  "environmentId": 1,
  "overrideVariables": "{\"username\": \"test\", \"password\": \"123456\"}"
}
```
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true,
    "statusCode": 200,
    "headers": {
      "Content-Type": "application/json"
    },
    "body": "{\"code\": 200, \"data\": {\"token\": \"xxx\"}}",
    "responseTime": 125,
    "error": null
  }
}
```
- **测试场景**:
  - ✅ 执行成功
  - ✅ 环境变量替换成功
  - ✅ 覆盖变量生效
  - ❌ 请求不存在

---

### 18.6 获取集合下的所有请求
- **URL**: `GET /api/api-requests/collection/{collectionId}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 请求列表

---

## 十九、API环境模块 `/api/api-environments`

### 19.1 获取项目的所有环境
- **URL**: `GET /api/api-environments?projectId=1`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "projectId": 1,
      "name": "测试环境",
      "description": "UAT测试环境",
      "variables": "{\"baseUrl\": \"https://test.example.com\", \"token\": \"test-token\"}",
      "isDefault": true
    },
    {
      "id": 2,
      "projectId": 1,
      "name": "生产环境",
      "description": "生产环境",
      "variables": "{\"baseUrl\": \"https://api.example.com\", \"token\": \"\"}",
      "isDefault": false
    }
  ]
}
```
- **数据库表**: `api_environment`

---

### 19.2 获取项目默认环境
- **URL**: `GET /api/api-environments/default?projectId=1`
- **认证**: 需要（Bearer Token）
- **响应** (200): 默认环境信息

---

### 19.3 创建环境
- **URL**: `POST /api/api-environments`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "projectId": 1,
  "name": "开发环境",
  "description": "本地开发环境",
  "variables": "{\"baseUrl\": \"http://localhost:8080\", \"debug\": \"true\"}",
  "isDefault": false
}
```
- **响应** (200): 创建的环境

---

### 19.4 更新环境
- **URL**: `PUT /api/api-environments/{id}`
- **认证**: 需要（Bearer Token）
- **请求体**: 同19.3
- **响应** (200): 更新后的环境

---

### 19.5 删除环境
- **URL**: `DELETE /api/api-environments/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200): 空

---

### 19.6 设置默认环境
- **URL**: `PUT /api/api-environments/{id}/default?projectId=1`
- **认证**: 需要（Bearer Token）
- **响应** (200): 空
- **测试场景**:
  - ✅ 设置默认环境成功
  - ✅ 原默认环境自动取消

---

## 二十、环境变量说明

### 20.1 变量格式
API请求中使用 `{{variableName}}` 格式定义变量。

### 20.2 变量来源
1. **环境变量**: 从 API Environment 的 variables 字段获取
2. **覆盖变量**: 在执行请求时通过 `overrideVariables` 参数覆盖
3. **提取变量**: 从响应中通过 extractors 提取的变量

### 20.3 变量替换优先级
```
高: 提取变量 (extractedVariables) > 覆盖变量 (overrideVariables) > 环境变量 (environmentVariables)
```

### 20.4 变量替换示例
```json
// 环境变量
{
  "baseUrl": "https://api.example.com",
  "username": "admin",
  "password": "admin123"
}

// API请求
{
  "url": "{{baseUrl}}/login",
  "bodyContent": "{\"username\": \"{{username}}\", \"password\": \"{{password}}\"}"
}

// 替换后
{
  "url": "https://api.example.com/login",
  "bodyContent": "{\"username\": \"admin\", \"password\": \"admin123\"}"
}
```

---

## 二十一、API Testing 数据库表结构

### api_project 表
```sql
- id: BIGINT 主键
- project_id: BIGINT 关联项目ID
- name: VARCHAR API项目名称
- description: TEXT 项目描述
- base_url: VARCHAR 基础URL
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### api_collection 表
```sql
- id: BIGINT 主键
- project_id: BIGINT API项目ID
- parent_id: BIGINT 父集合ID
- name: VARCHAR 集合名称
- description: TEXT 集合描述
- sort_order: INT 排序
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### api_request 表
```sql
- id: BIGINT 主键
- collection_id: BIGINT 集合ID
- name: VARCHAR 请求名称
- method: VARCHAR HTTP方法
- url: VARCHAR 请求URL
- headers: TEXT 请求头(JSON)
- params: TEXT URL参数(JSON)
- body_type: VARCHAR 请求体类型
- body_content: TEXT 请求体内容
- auth_type: VARCHAR 认证类型
- auth_config: TEXT 认证配置(JSON)
- pre_script: TEXT 前置脚本
- post_script: TEXT 后置脚本
- assertions: TEXT 断言规则(JSON数组) [新增]
- extractors: TEXT 变量提取规则(JSON数组) [新增]
- sort_order: INT 排序
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### api_environment 表
```sql
- id: BIGINT 主键
- project_id: BIGINT 项目ID
- name: VARCHAR 环境名称
- description: VARCHAR 环境描述
- variables: TEXT 环境变量(JSON)
- is_default: TINYINT 是否默认
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### api_test_suite 表
```sql
- id: BIGINT 主键
- project_id: BIGINT 项目ID
- name: VARCHAR 套件名称
- description: TEXT 套件描述
- environment_id: BIGINT 环境ID
- timeout: INT 超时时间(毫秒)
- retry_count: INT 失败重试次数
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

### api_scheduled_task 表
```sql
- id: BIGINT 主键
- suite_id: BIGINT 套件ID
- name: VARCHAR 任务名称
- trigger_type: VARCHAR 触发类型 (cron/interval/once)
- cron_expression: VARCHAR Cron表达式
- interval_value: BIGINT 间隔值
- interval_unit: VARCHAR 间隔单位
- once_time: DATETIME 单次执行时间
- is_enabled: TINYINT 是否启用
- notification_config: TEXT 通知配置(JSON)
- last_run_at: DATETIME 上次执行时间
- next_run_at: DATETIME 下次执行时间
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

---

## 二十二、API Testing 业务错误信息

| 错误信息 | 说明 |
|---------|------|
| API请求不存在 | API请求记录不存在 |
| 环境不存在 | API环境不存在 |
| 集合不存在 | API集合不存在 |
| API项目不存在 | API项目不存在 |



### api_execution_record 表
```sql
- id: BIGINT 主键
- suite_id: BIGINT 测试套件ID
- executed_at: DATETIME 执行时间
- total_count: INT 总请求数
- pass_count: INT 通过数
- fail_count: INT 失败数
- result_data: TEXT 执行结果(JSON)
- status: TINYINT 执行状态(0=失败,1=成功)
- duration: BIGINT 执行时长(毫秒)
- environment_id: BIGINT 执行环境ID
- trigger_type: VARCHAR 触发类型 (manual/scheduled)
- trigger_id: BIGINT 触发来源ID
- is_deleted: TINYINT 逻辑删除
- created_at: DATETIME 创建时间
- updated_at: DATETIME 更新时间
```

---

## 二十三、API测试套件模块 `/api/api-test-suites`

### 23.1 获取项目的所有测试套件
- **URL**: `GET /api/api-test-suites`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `projectId` (必填): 项目ID
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "projectId": 1,
      "name": "登录测试套件",
      "description": "测试所有登录相关API",
      "environmentId": 1,
      "timeout": 30000,
      "retryCount": 0,
      "createdAt": "2026-04-29T10:00:00"
    }
  ]
}
```
- **数据库表**: `api_test_suite`
- **测试场景**:
  - ✅ 获取项目的测试套件列表

### 23.2 获取套件详情
- **URL**: `GET /api/api-test-suites/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "projectId": 1,
    "name": "登录测试套件",
    "description": "测试所有登录相关API",
    "environmentId": 1,
    "timeout": 30000,
    "retryCount": 0
  }
}
```
- **测试场景**:
  - ✅ 获取套件详情成功
  - ✅ 套件不存在返回404

### 23.3 创建测试套件
- **URL**: `POST /api/api-test-suites`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "projectId": 1,
  "name": "登录测试套件",
  "description": "测试所有登录相关API",
  "environmentId": 1,
  "timeout": 30000,
  "retryCount": 0
}
```
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "projectId": 1,
    "name": "登录测试套件",
    "description": "测试所有登录相关API",
    "environmentId": 1,
    "timeout": 30000,
    "retryCount": 0
  }
}
```
- **测试场景**:
  - ✅ 创建测试套件成功
  - ❌ 缺少必填字段返回400

### 23.4 更新测试套件
- **URL**: `PUT /api/api-test-suites/{id}`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "name": "更新后的套件名称",
  "description": "更新后的描述",
  "environmentId": 2,
  "timeout": 60000,
  "retryCount": 1
}
```
- **测试场景**:
  - ✅ 更新测试套件成功
  - ❌ 套件不存在返回404

### 23.5 删除测试套件
- **URL**: `DELETE /api/api-test-suites/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success"
}
```
- **测试场景**:
  - ✅ 删除测试套件成功
  - ❌ 套件不存在返回404

### 23.6 执行测试套件
- **URL**: `POST /api/api-test-suites/{id}/execute`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "suiteId": 1,
    "startTime": "2026-04-29T10:00:00",
    "endTime": "2026-04-29T10:00:30",
    "success": true,
    "totalCount": 10,
    "passCount": 9,
    "failCount": 1,
    "requestResults": [
      {
        "requestId": 1,
        "requestName": "用户登录",
        "success": true,
        "statusCode": 200,
        "responseTime": 150
      },
      {
        "requestId": 2,
        "requestName": "获取用户信息",
        "success": false,
        "statusCode": null,
        "responseTime": 0,
        "error": "Connection refused"
      }
    ]
  }
}
```
- **测试场景**:
  - ✅ 执行测试套件成功
  - ✅ 返回所有请求的执行结果
  - ❌ 套件不存在返回错误

---

## 二十四、API定时任务模块 `/api/api-scheduled-tasks`

### 24.1 获取项目的所有定时任务
- **URL**: `GET /api/api-scheduled-tasks`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `projectId` (必填): 项目ID
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "suiteId": 1,
      "name": "每日回归测试",
      "triggerType": "cron",
      "cronExpression": "0 0 2 * * ?",
      "isEnabled": true,
      "lastRunAt": "2026-04-28T02:00:00",
      "nextRunAt": "2026-04-29T02:00:00"
    }
  ]
}
```
- **测试场景**:
  - ✅ 获取项目的定时任务列表

### 24.2 获取套件的所有定时任务
- **URL**: `GET /api/api-scheduled-tasks/suite/{suiteId}`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "suiteId": 1,
      "name": "每日回归测试",
      "triggerType": "cron",
      "cronExpression": "0 0 2 * * ?"
    }
  ]
}
```
- **测试场景**:
  - ✅ 获取套件的定时任务列表

### 24.3 获取任务详情
- **URL**: `GET /api/api-scheduled-tasks/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "suiteId": 1,
    "name": "每日回归测试",
    "triggerType": "cron",
    "cronExpression": "0 0 2 * * ?",
    "isEnabled": true,
    "notificationConfig": "{\"onFailure\": true, \"recipients\": [\"admin@test.com\"]}"
  }
}
```
- **测试场景**:
  - ✅ 获取任务详情成功

### 24.4 创建定时任务
- **URL**: `POST /api/api-scheduled-tasks`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "suiteId": 1,
  "name": "每日回归测试",
  "triggerType": "cron",
  "cronExpression": "0 0 2 * * ?",
  "isEnabled": true,
  "notificationConfig": "{\"onFailure\": true, \"recipients\": [\"admin@test.com\"]}"
}
```
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "suiteId": 1,
    "name": "每日回归测试",
    "triggerType": "cron",
    "cronExpression": "0 0 2 * * ?",
    "isEnabled": true
  }
}
```
- **测试场景**:
  - ✅ 创建定时任务成功
  - ❌ 缺少必填字段返回400

### 24.5 更新定时任务
- **URL**: `PUT /api/api-scheduled-tasks/{id}`
- **认证**: 需要（Bearer Token）
- **请求体**:
```json
{
  "name": "更新后的任务名称",
  "cronExpression": "0 30 2 * * ?",
  "isEnabled": false
}
```
- **测试场景**:
  - ✅ 更新定时任务成功

### 24.6 删除定时任务
- **URL**: `DELETE /api/api-scheduled-tasks/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success"
}
```
- **测试场景**:
  - ✅ 删除定时任务成功

### 24.7 启用任务
- **URL**: `PUT /api/api-scheduled-tasks/{id}/enable`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success"
}
```
- **测试场景**:
  - ✅ 启用定时任务成功

### 24.8 禁用任务
- **URL**: `PUT /api/api-scheduled-tasks/{id}/disable`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success"
}
```
- **测试场景**:
  - ✅ 禁用定时任务成功

### 24.9 立即执行任务
- **URL**: `POST /api/api-scheduled-tasks/{id}/execute`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success"
}
```
- **测试场景**:
  - ✅ 立即执行定时任务
  - ❌ 任务不存在返回错误

---

## 二十五、API执行记录模块 `/api/api-execution-records`

### 25.1 获取项目的执行记录
- **URL**: `GET /api/api-execution-records/project/{projectId}`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `limit` (可选, 默认50): 返回记录数
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "suiteId": 1,
      "executedAt": "2026-04-29T02:00:00",
      "totalCount": 10,
      "passCount": 9,
      "failCount": 1,
      "status": true,
      "duration": 30000,
      "environmentId": 1,
      "triggerType": "scheduled"
    }
  ]
}
```
- **测试场景**:
  - ✅ 获取项目的执行记录列表

### 25.2 获取套件的执行记录
- **URL**: `GET /api/api-execution-records/suite/{suiteId}`
- **认证**: 需要（Bearer Token）
- **参数**:
  - `limit` (可选, 默认50): 返回记录数
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "suiteId": 1,
      "executedAt": "2026-04-29T02:00:00",
      "totalCount": 10,
      "passCount": 9,
      "failCount": 1,
      "status": true,
      "duration": 30000
    }
  ]
}
```
- **测试场景**:
  - ✅ 获取套件的执行记录列表

### 25.3 获取记录详情
- **URL**: `GET /api/api-execution-records/{id}`
- **认证**: 需要（Bearer Token）
- **响应** (200):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "suiteId": 1,
    "executedAt": "2026-04-29T02:00:00",
    "totalCount": 10,
    "passCount": 9,
    "failCount": 1,
    "resultData": "[{\"requestId\":1,\"success\":true,...}]",
    "status": true,
    "duration": 30000,
    "environmentId": 1,
    "triggerType": "scheduled"
  }
}
```
- **测试场景**:
  - ✅ 获取执行记录详情成功
  - ❌ 记录不存在返回404

---

## 二十六、API Testing 定时任务错误信息

| 错误信息 | 说明 |
|---------|------|
| 定时任务不存在 | 定时任务记录不存在 |
| 测试套件不存在 | 测试套件不存在 |
| Cron表达式格式错误 | Cron表达式不合法 |
| 执行超时 | 测试套件执行超时 |
| 环境变量解析失败 | 环境变量格式错误 |

---

## 二十七、响应断言功能 (Assertions)

### 27.1 断言字段
API请求支持 `assertions` 字段，用于验证响应是否符合预期。

**数据库字段**: `api_request.assertions` (TEXT, JSON数组)

### 27.2 断言类型

| 类型 | 说明 | 必需参数 |
|------|------|----------|
| `status_code` | 验证HTTP状态码 | `expected`: 期望状态码 |
| `response_time` | 验证响应时间 | `expected`: 期望时间(毫秒), `operator`: 比较操作符 |
| `contains` | 验证响应包含文本 | `expected`: 期望包含的文本 |
| `json_path` | JSONPath取值验证 | `path`: JSONPath路径, `expected`: 期望值, `operator`: 比较操作符 |
| `equals` | 完全相等验证 | `path`: JSONPath路径, `expected`: 期望值 |
| `regex` | 正则表达式匹配 | `pattern`: 正则表达式 |
| `header` | 验证响应头 | `name`: 响应头名称, `expected`: 期望值 |

### 27.3 操作符说明

| 操作符 | 说明 |
|--------|------|
| `==` | 等于 (默认) |
| `!=` | 不等于 |
| `<` | 小于 |
| `<=` | 小于等于 |
| `>` | 大于 |
| `>=` | 大于等于 |
| `contains` | 字符串包含 |
| `startsWith` | 字符串开头匹配 |
| `endsWith` | 字符串结尾匹配 |

### 27.4 断言配置示例

```json
// status_code 断言
[
  {"type": "status_code", "name": "状态码验证", "expected": 200}
]

// response_time 断言
[
  {"type": "response_time", "name": "响应时间", "operator": "<=", "expected": 2000}
]

// contains 断言
[
  {"type": "contains", "name": "包含内容", "expected": "success"}
]

// json_path 断言
[
  {"type": "json_path", "name": "验证返回码", "path": "$.code", "expected": 200},
  {"type": "json_path", "name": "验证token存在", "path": "$.data.token", "operator": "contains", "expected": "abc"}
]

// regex 断言
[
  {"type": "regex", "name": "token格式", "pattern": "token:\\w+"}
]

// header 断言
[
  {"type": "header", "name": "Content-Type", "name": "Content-Type", "expected": "application/json"}
]
```

### 27.5 执行断言的API请求

```json
// 创建带断言的API请求
{
  "collectionId": 1,
  "name": "健康检查",
  "method": "GET",
  "url": "{{baseUrl}}/health",
  "assertions": "[{\"type\": \"status_code\", \"name\": \"状态码\", \"expected\": 200}]"
}
```

### 27.6 断言执行响应

```json
// 执行响应 (断言结果在 requestResults 中)
{
  "code": 200,
  "message": "success",
  "data": {
    "suiteId": 1,
    "success": true,
    "totalCount": 1,
    "passCount": 1,
    "failCount": 0,
    "requestResults": [
      {
        "requestId": 1,
        "requestName": "健康检查",
        "success": true,
        "statusCode": 200,
        "responseTime": 50,
        "assertions": [
          {"name": "状态码", "passed": true, "expected": "200", "actual": "200"}
        ]
      }
    ]
  }
}
```

### 27.7 断言失败示例

```json
// 断言失败的响应
{
  "requestId": 2,
  "requestName": "获取用户信息",
  "success": false,
  "statusCode": 401,
  "responseTime": 80,
  "assertions": [
    {"name": "状态码", "passed": false, "expected": "200", "actual": "401"},
    {"name": "包含内容", "passed": false, "expected": "包含: success", "actual": "不包含", "error": null}
  ],
  "error": null
}
```

---

## 二十八、响应变量提取功能 (Extractors)

### 28.1 变量提取字段
API请求支持 `extractors` 字段，用于从响应中提取值供后续请求使用。

**数据库字段**: `api_request.extractors` (TEXT, JSON数组)

### 28.2 提取类型

| 类型 | 说明 | 必需参数 |
|------|------|----------|
| `json_path` | 从JSON响应中提取值 | `path`: JSONPath路径, `variable`: 变量名 |
| `regex` | 正则表达式提取 | `pattern`: 正则表达式, `variable`: 变量名, `group`: 捕获组索引 |
| `header` | 从响应头提取 | `name`: 响应头名称, `variable`: 变量名 |
| `cookie` | 从Cookie提取 | `name`: Cookie名称, `variable`: 变量名 |
| `body_text` | 提取纯文本 | `variable`: 变量名 (移除HTML标签) |

### 28.3 提取配置示例

```json
// json_path 提取
[
  {"type": "json_path", "from": "body", "path": "$.data.token", "variable": "authToken"}
]

// 从响应头提取
[
  {"type": "header", "name": "X-Request-Id", "variable": "requestId"}
]

// 正则提取
[
  {"type": "regex", "source": "body", "pattern": "token=([^&]+)", "group": 1, "variable": "sessionToken"}
]

// 从Cookie提取
[
  {"type": "cookie", "name": "session_id", "variable": "sessionId"}
]
```

### 28.4 变量使用方式

提取的变量在整个测试套件执行过程中共享，后续请求可以通过 `{{variableName}}` 语法使用：

```json
// 请求1: 登录并提取token
{
  "collectionId": 1,
  "name": "用户登录",
  "method": "POST",
  "url": "{{baseUrl}}/login",
  "bodyContent": "{\"username\": \"admin\", \"password\": \"admin123\"}",
  "extractors": "[{\"type\": \"json_path\", \"path\": \"$.data.token\", \"variable\": \"authToken\"}]"
}

// 请求2: 使用提取的token
{
  "collectionId": 1,
  "name": "获取用户信息",
  "method": "GET",
  "url": "{{baseUrl}}/users/me",
  "headers": "{\"Authorization\": \"Bearer {{authToken}}\"}"
}
```

### 28.5 变量提取响应

```json
// 执行响应 (提取的变量在 extractedVariables 中)
{
  "code": 200,
  "message": "success",
  "data": {
    "suiteId": 1,
    "success": true,
    "totalCount": 2,
    "passCount": 2,
    "failCount": 0,
    "extractedVariables": {
      "authToken": "eyJhbGciOiJIUzI1NiJ9...",
      "requestId": "abc123"
    },
    "requestResults": [
      {
        "requestId": 1,
        "requestName": "用户登录",
        "success": true,
        "extractedVariables": {
          "authToken": "eyJhbGciOiJIUzI1NiJ9..."
        }
      },
      {
        "requestId": 2,
        "requestName": "获取用户信息",
        "success": true
      }
    ]
  }
}
```

---

## 二十九、XXL-JOB 定时调度集成

### 29.1 XXL-JOB 配置

API Testing 模块与 XXL-JOB 集成，支持定时执行测试套件。

**XXL-JOB 地址**: `http://localhost:8088/xxl-job-admin`

### 29.2 任务处理器

| 任务名 | 说明 |
|--------|------|
| `apiScheduledTaskJob` | 执行定时任务 |
| `apiScheduledTaskUpdateNextRunJob` | 更新下次执行时间 |

### 29.3 触发方式

**cron 表达式**: 使用标准 cron 表达式，如 `0 0 2 * * ?` 表示每天凌晨2点执行

**参数格式**: `taskId` (任务ID)

### 29.4 XXL-JOB Admin 配置步骤

1. 登录 XXL-JOB Admin 控制台 (`http://localhost:8088/xxl-job-admin`)
2. 进入"任务管理"页面
3. 添加任务:
   - **任务名称**: `API定时任务执行器`
   - **任务描述**: `执行API Testing定时任务`
   - **cron表达式**: `0 */5 * * * ?` (每5分钟检查一次)
   - **JobHandler**: `apiScheduledTaskJob`
   - **执行器**: 选择对应的执行器
4. 启动任务

### 29.5 定时任务触发流程

```
1. XXL-JOB 按照 cron 表达式触发 apiScheduledTaskJob
2. ApiScheduledJobHandler.execute() 接收任务参数 (taskId)
3. 根据 taskId 查询定时任务配置
4. 检查任务是否启用 (isEnabled = true)
5. 调用 ApiScheduledTaskService.executeTaskNow() 执行测试套件
6. 更新任务的 lastRunAt 和 nextRunAt
7. 发送通知 (如果配置了)
```

### 29.6 本地测试定时任务

通过 API 手动触发定时任务:

```bash
# 启用任务
curl -X PUT http://localhost:8080/api/api-scheduled-tasks/1/enable

# 立即执行任务
curl -X POST http://localhost:8080/api/api-scheduled-tasks/1/execute
```

### 29.7 触发类型说明

| 触发类型 | 说明 |
|----------|------|
| `manual` | 手动执行 (通过API) |
| `scheduled` | 定时执行 (通过XXL-JOB) |
| `api` | API触发 (通过API) |

---

## 三十、断言与变量提取综合示例

### 30.1 完整的测试套件配置

```json
// 测试套件
{
  "projectId": 1,
  "name": "用户服务集成测试",
  "environmentId": 1,
  "timeout": 30000,
  "retryCount": 1
}

// 请求1: 用户登录
{
  "collectionId": 1,
  "name": "用户登录",
  "method": "POST",
  "url": "{{baseUrl}}/auth/login",
  "headers": "{\"Content-Type\": \"application/json\"}",
  "bodyType": "json",
  "bodyContent": "{\"username\": \"{{username}}\", \"password\": \"{{password}}\"}",
  "assertions": "[{\"type\": \"status_code\", \"name\": \"登录成功\", \"expected\": 200}]",
  "extractors": "[{\"type\": \"json_path\", \"path\": \"$.data.accessToken\", \"variable\": \"accessToken\"}]"
}

// 请求2: 获取用户信息 (使用提取的token)
{
  "collectionId": 1,
  "name": "获取用户信息",
  "method": "GET",
  "url": "{{baseUrl}}/users/me",
  "headers": "{\"Authorization\": \"Bearer {{accessToken}}\"}",
  "assertions": "[{\"type\": \"status_code\", \"name\": \"获取成功\", \"expected\": 200}, {\"type\": \"json_path\", \"name\": \"验证用户名\", \"path\": \"$.data.username\", \"expected\": \"{{username}}\"}]"
}

// 环境变量
{
  "projectId": 1,
  "name": "测试环境",
  "variables": "{\"baseUrl\": \"https://api.example.com\", \"username\": \"testuser\", \"password\": \"test123\"}"
}
```

### 30.2 执行流程

1. 从环境变量加载 `baseUrl`, `username`, `password`
2. 执行请求1 (用户登录)
   - 断言: status_code == 200
   - 提取: `accessToken` from `$.data.accessToken`
3. 执行请求2 (获取用户信息)
   - 使用: `{{accessToken}}` 替换 Authorization 头
   - 断言: status_code == 200, username == "testuser"
4. 返回完整执行结果

### 30.3 数据库表变更

```sql
-- api_request 表添加断言和变量提取字段
ALTER TABLE api_request ADD COLUMN assertions TEXT COMMENT '断言规则(JSON数组)';
ALTER TABLE api_request ADD COLUMN extractors TEXT COMMENT '变量提取规则(JSON数组)';
```

---

## 三十一、API Testing 功能完成清单

### 已实现功能

| 功能 | 状态 | 说明 |
|------|------|------|
| API项目管理 | ✅ | CRUD操作 |
| API集合管理 | ✅ | 树形结构，支持嵌套 |
| API请求管理 | ✅ | 支持多种HTTP方法和认证 |
| 环境变量 | ✅ | 支持变量替换 |
| 测试套件 | ✅ | 支持批量执行 |
| 定时任务 | ✅ | 支持cron/interval/once |
| 执行记录 | ✅ | 完整执行历史 |
| 响应断言 | ✅ | 7种断言类型 |
| 变量提取 | ✅ | 5种提取类型 |
| XXL-JOB集成 | ✅ | 定时调度执行 |

### 断言类型支持

| 类型 | 状态 | 说明 |
|------|------|------|
| status_code | ✅ | HTTP状态码验证 |
| response_time | ✅ | 响应时间验证 |
| contains | ✅ | 响应内容包含验证 |
| json_path | ✅ | JSON响应取值验证 |
| equals | ✅ | 完全相等验证 |
| regex | ✅ | 正则表达式匹配 |
| header | ✅ | 响应头验证 |

### 变量提取类型支持

| 类型 | 状态 | 说明 |
|------|------|------|
| json_path | ✅ | JSON响应提取 |
| regex | ✅ | 正则表达式提取 |
| header | ✅ | 响应头提取 |
| cookie | ✅ | Cookie提取 |
| body_text | ✅ | 纯文本提取 |
