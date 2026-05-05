# 项目管理模块测试

## 一、接口列表

### 1.1 项目基本操作

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 创建项目 | POST | /api/projects | 创建新项目 | P0 |
| 获取项目列表 | GET | /api/projects | 获取当前用户项目列表 | P0 |
| 分页查询项目 | GET | /api/projects/page | 分页查询项目 | P1 |
| 获取项目详情 | GET | /api/projects/{id} | 获取项目详情 | P0 |
| 更新项目 | PUT | /api/projects/{id} | 更新项目信息 | P0 |
| 删除项目 | DELETE | /api/projects/{id} | 删除项目 | P0 |
| 搜索项目 | GET | /api/projects/search | 搜索项目 | P1 |

### 1.2 项目成员管理

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 获取成员列表 | GET | /api/projects/{id}/members | 获取项目成员 | P0 |
| 添加成员 | POST | /api/projects/{id}/members | 添加项目成员 | P0 |
| 更新成员角色 | PUT | /api/projects/{id}/members/{memberId} | 更新成员角色 | P1 |
| 移除成员 | DELETE | /api/projects/{id}/members/{userId} | 移除项目成员 | P0 |
| 获取当前用户角色 | GET | /api/projects/{id}/members/role | 获取用户在项目中的角色 | P1 |

### 1.3 项目环境管理

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 获取环境列表 | GET | /api/projects/{id}/environments | 获取项目环境 | P0 |
| 获取默认环境 | GET | /api/projects/{id}/environments/default | 获取默认环境 | P1 |
| 创建环境 | POST | /api/projects/{id}/environments | 创建项目环境 | P0 |
| 更新环境 | PUT | /api/projects/{projectId}/environments/{envId} | 更新环境 | P0 |
| 删除环境 | DELETE | /api/projects/{projectId}/environments/{envId} | 删除环境 | P0 |
| 设置默认环境 | PUT | /api/projects/{projectId}/environments/{envId}/default | 设置默认环境 | P1 |

## 二、测试用例

### 2.1 项目CRUD测试 (PROJ-CRUD)

| 用例ID | 用例名称 | 测试步骤 | 预期结果 | 状态 |
|-------|---------|---------|---------|------|
| PROJ-CRUD-001 | 创建项目-正常 | 填写完整信息创建 | 创建成功 | |
| PROJ-CRUD-002 | 创建项目-名称为空 | 名称留空 | 返回名称不能为空 | |
| PROJ-CRUD-003 | 创建项目-名称重复 | 使用已存在名称 | 返回名称已存在 | |
| PROJ-CRUD-004 | 获取项目列表 | 无参数 | 返回当前用户项目 | |
| PROJ-CRUD-005 | 分页查询项目 | 设置分页参数 | 返回分页结果 | |
| PROJ-CRUD-006 | 获取项目详情 | 使用项目ID | 返回项目详情 | |
| PROJ-CRUD-007 | 获取不存在的项目 | 使用无效ID | 返回404 | |
| PROJ-CRUD-008 | 更新项目-正常 | 修改信息 | 更新成功 | |
| PROJ-CRUD-009 | 更新他人项目 | 无权限更新 | 返回403/404 | |
| PROJ-CRUD-010 | 删除项目-正常 | 确认删除 | 删除成功 | |
| PROJ-CRUD-011 | 删除不存在的项目 | 使用无效ID | 返回404 | |
| PROJ-CRUD-012 | 搜索项目 | 关键词搜索 | 返回匹配结果 | |

### 2.2 成员管理测试 (PROJ-MEMBER)

| 用例ID | 用例名称 | 测试步骤 | 预期结果 | 状态 |
|-------|---------|---------|---------|------|
| PROJ-MEMBER-001 | 获取成员列表 | 使用项目ID | 返回成员列表 | |
| PROJ-MEMBER-002 | 添加成员-正常 | 添加用户ID和角色 | 添加成功 | |
| PROJ-MEMBER-003 | 添加自己 | 尝试将自己添加 | 返回错误或禁止 | |
| PROJ-MEMBER-004 | 添加已存在成员 | 重复添加 | 返回已存在 | |
| PROJ-MEMBER-005 | 更新成员角色 | 修改角色 | 更新成功 | |
| PROJ-MEMBER-006 | 移除成员 | 移除用户 | 移除成功 | |
| PROJ-MEMBER-007 | 获取用户角色 | 当前用户获取自己角色 | 返回角色 | |

### 2.3 环境管理测试 (PROJ-ENV)

| 用例ID | 用例名称 | 测试步骤 | 预期结果 | 状态 |
|-------|---------|---------|---------|------|
| PROJ-ENV-001 | 创建环境-正常 | 填写环境信息 | 创建成功 | |
| PROJ-ENV-002 | 创建环境-无变量 | 不配置变量 | 创建成功 | |
| PROJ-ENV-003 | 获取环境列表 | 项目ID | 返回环境列表 | |
| PROJ-ENV-004 | 获取默认环境 | 项目ID | 返回默认环境或空 | |
| PROJ-ENV-005 | 设置默认环境 | 环境ID | 设置成功 | |
| PROJ-ENV-006 | 更新环境-正常 | 修改环境信息 | 更新成功 | |
| PROJ-ENV-007 | 更新环境-变量 | 更新变量 | 变量更新成功 | |
| PROJ-ENV-008 | 删除环境-正常 | 确认删除 | 删除成功 | |
| PROJ-ENV-009 | 删除不存在的环境 | 无效ID | 返回404 | |

## 三、curl 测试命令

### 3.1 项目操作

```bash
# 创建项目
curl -X POST http://127.0.0.1:8080/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"name":"测试项目","description":"描述"}'

# 获取项目列表
curl -X GET http://127.0.0.1:8080/api/projects \
  -H "Authorization: Bearer YOUR_TOKEN"

# 获取项目详情
curl -X GET http://127.0.0.1:8080/api/projects/1 \
  -H "Authorization: Bearer YOUR_TOKEN"

# 更新项目
curl -X PUT http://127.0.0.1:8080/api/projects/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"name":"更新后的名称","description":"更新描述"}'

# 删除项目
curl -X DELETE http://127.0.0.1:8080/api/projects/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3.2 成员操作

```bash
# 获取成员列表
curl -X GET http://127.0.0.1:8080/api/projects/1/members \
  -H "Authorization: Bearer YOUR_TOKEN"

# 添加成员
curl -X POST http://127.0.0.1:8080/api/projects/1/members?userId=2&role=tester \
  -H "Authorization: Bearer YOUR_TOKEN"

# 移除成员
curl -X DELETE http://127.0.0.1:8080/api/projects/1/members/2 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3.3 环境操作

```bash
# 创建环境
curl -X POST http://127.0.0.1:8080/api/projects/1/environments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"name":"测试环境","variables":{"baseUrl":"https://api.test.com"}}'

# 获取环境列表
curl -X GET http://127.0.0.1:8080/api/projects/1/environments \
  -H "Authorization: Bearer YOUR_TOKEN"

# 设置默认环境
curl -X PUT http://127.0.0.1:8080/api/projects/1/environments/1/default \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 四、测试结果记录

| 测试日期 | 测试人员 | 通过数 | 失败数 | 通过率 | 备注 |
|---------|---------|-------|-------|-------|------|
| 2026-04-30 | | | | | |
