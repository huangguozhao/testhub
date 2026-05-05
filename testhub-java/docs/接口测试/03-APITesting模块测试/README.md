# APITesting模块测试

## 一、接口列表

### 1.1 API项目

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 创建API项目 | POST | /api/api-projects | 创建API项目 | P0 |
| 分页查询 | GET | /api/api-projects | 分页查询项目 | P0 |
| 获取详情 | GET | /api/api-projects/{id} | 获取项目详情 | P0 |
| 更新项目 | PUT | /api/api-projects/{id} | 更新项目 | P0 |
| 删除项目 | DELETE | /api/api-projects/{id} | 删除项目 | P0 |

### 1.2 API环境

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 获取环境列表 | GET | /api/api-environments | 获取项目环境 | P0 |
| 获取默认环境 | GET | /api/api-environments/default | 获取默认环境 | P1 |
| 获取环境详情 | GET | /api/api-environments/{id} | 获取环境详情 | P0 |
| 创建环境 | POST | /api/api-environments | 创建环境 | P0 |
| 更新环境 | PUT | /api/api-environments/{id} | 更新环境 | P0 |
| 删除环境 | DELETE | /api/api-environments/{id} | 删除环境 | P0 |
| 设置默认环境 | PUT | /api/api-environments/{id}/default | 设置默认 | P1 |

### 1.3 API集合

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 分页查询 | GET | /api/api-collections | 分页查询集合 | P0 |
| 获取树形结构 | GET | /api/api-collections/tree | 获取树形 | P0 |
| 获取详情 | GET | /api/api-collections/{id} | 获取详情 | P0 |
| 创建集合 | POST | /api/api-collections | 创建集合 | P0 |
| 更新集合 | PUT | /api/api-collections/{id} | 更新集合 | P0 |
| 删除集合 | DELETE | /api/api-collections/{id} | 删除集合 | P0 |

### 1.4 API请求

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 分页查询 | GET | /api/api-requests | 分页查询请求 | P0 |
| 获取详情 | GET | /api/api-requests/{id} | 获取请求详情 | P0 |
| 创建请求 | POST | /api/api-requests | 创建API请求 | P0 |
| 更新请求 | PUT | /api/api-requests/{id} | 更新请求 | P0 |
| 删除请求 | DELETE | /api/api-requests/{id} | 删除请求 | P0 |
| 执行请求 | POST | /api/api-requests/execute | 执行单个请求 | P0 |
| 获取集合请求 | GET | /api/api-requests/collection/{id} | 获取集合下请求 | P1 |

### 1.5 API测试套件

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 获取套件列表 | GET | /api/api-test-suites | 获取项目套件 | P0 |
| 获取套件详情 | GET | /api/api-test-suites/{id} | 获取详情 | P0 |
| 创建套件 | POST | /api/api-test-suites | 创建套件 | P0 |
| 更新套件 | PUT | /api/api-test-suites/{id} | 更新套件 | P0 |
| 删除套件 | DELETE | /api/api-test-suites/{id} | 删除套件 | P0 |
| 执行套件 | POST | /api/api-test-suites/{id}/execute | 执行套件 | P0 |

### 1.6 API定时任务

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 获取任务列表 | GET | /api/api-scheduled-tasks | 获取项目任务 | P1 |
| 获取套件任务 | GET | /api/api-scheduled-tasks/suite/{id} | 获取套件任务 | P2 |
| 获取任务详情 | GET | /api/api-scheduled-tasks/{id} | 获取详情 | P1 |
| 创建任务 | POST | /api/api-scheduled-tasks | 创建任务 | P1 |
| 更新任务 | PUT | /api/api-scheduled-tasks/{id} | 更新任务 | P1 |
| 删除任务 | DELETE | /api/api-scheduled-tasks/{id} | 删除任务 | P1 |
| 启用任务 | PUT | /api/api-scheduled-tasks/{id}/enable | 启用 | P1 |
| 禁用任务 | PUT | /api/api-scheduled-tasks/{id}/disable | 禁用 | P1 |
| 立即执行 | POST | /api/api-scheduled-tasks/{id}/execute | 立即执行 | P1 |

### 1.7 请求历史

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 分页查询 | GET | /api/api-request-histories | 分页查询 | P1 |
| 获取详情 | GET | /api/api-request-histories/{id} | 获取详情 | P1 |
| 按请求查询 | GET | /api/api-request-histories/request/{id} | 按请求ID | P1 |
| 按套件查询 | GET | /api/api-request-histories/suite-execution/{id} | 按套件执行 | P2 |
| 删除历史 | DELETE | /api/api-request-histories/{id} | 删除单条 | P1 |
| 批量删除 | DELETE | /api/api-request-histories/batch | 批量删除 | P2 |
| 清理请求历史 | DELETE | /api/api-request-histories/request/{id} | 清理请求 | P2 |
| 清理全部 | DELETE | /api/api-request-histories/clear | 清理全部 | P2 |

### 1.8 执行记录

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 按项目查询 | GET | /api/api-execution-records/project/{id} | 项目执行记录 | P2 |
| 按套件查询 | GET | /api/api-execution-records/suite/{id} | 套件执行记录 | P2 |
| 获取详情 | GET | /api/api-execution-records/{id} | 执行详情 | P2 |

## 二、测试用例

### 2.1 API项目测试 (API-PROJ)

| 用例ID | 用例名称 | 预期结果 | 状态 |
|-------|---------|---------|------|
| API-PROJ-001 | 创建API项目-正常 | 创建成功 | |
| API-PROJ-002 | 创建API项目-无关联项目 | 创建成功(可选) | |
| API-PROJ-003 | 获取API项目列表 | 返回分页列表 | |
| API-PROJ-004 | 获取API项目详情 | 返回详情 | |
| API-PROJ-005 | 更新API项目 | 更新成功 | |
| API-PROJ-006 | 删除API项目 | 删除成功 | |

### 2.2 API环境测试 (API-ENV)

| 用例ID | 用例名称 | 预期结果 | 状态 |
|-------|---------|---------|------|
| API-ENV-001 | 创建环境-正常 | 创建成功 | |
| API-ENV-002 | 创建环境-带变量 | 变量保存成功 | |
| API-ENV-003 | 创建环境-设置默认 | 设置成功 | |
| API-ENV-004 | 获取环境列表 | 返回列表 | |
| API-ENV-005 | 获取默认环境 | 返回默认环境 | |
| API-ENV-006 | 更新环境变量 | 变量更新成功 | |
| API-ENV-007 | 删除环境 | 删除成功 | |

### 2.3 API请求执行测试 (API-EXEC)

| 用例ID | 用例名称 | 预期结果 | 状态 |
|-------|---------|---------|------|
| API-EXEC-001 | 执行GET请求-httpbin | 状态码200 | |
| API-EXEC-002 | 执行POST请求-带Body | 状态码200 | |
| API-EXEC-003 | 执行PUT请求 | 状态码200 | |
| API-EXEC-004 | 执行DELETE请求 | 状态码200 | |
| API-EXEC-005 | 执行WebSocket请求 | 连接成功 | |
| API-EXEC-006 | 使用环境变量 | 变量替换成功 | |
| API-EXEC-007 | 执行失败-无效URL | 返回错误 | |
| API-EXEC-008 | 执行失败-网络超时 | 返回超时错误 | |

### 2.4 变量提取测试 (API-VAR)

| 用例ID | 用例名称 | 预期结果 | 状态 |
|-------|---------|---------|------|
| API-VAR-001 | JSONPath提取 | 提取成功 | |
| API-VAR-002 | 正则提取 | 提取成功 | |
| API-VAR-003 | Header提取 | 提取成功 | |
| API-VAR-004 | 变量在后续请求中使用 | 使用成功 | |

### 2.5 断言测试 (API-ASSERT)

| 用例ID | 用例名称 | 预期结果 | 状态 |
|-------|---------|---------|------|
| API-ASSERT-001 | 状态码断言 | 断言通过/失败 | |
| API-ASSERT-002 | JSON断言 | 断言通过/失败 | |
| API-ASSERT-003 | 响应时间断言 | 断言通过/失败 | |
| API-ASSERT-004 | 包含断言 | 断言通过/失败 | |

## 三、curl 测试命令

### 3.1 API项目

```bash
# 创建API项目
curl -X POST http://127.0.0.1:8080/api/api-projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"name":"测试API项目","description":"描述","projectId":1}'

# 获取列表
curl -X GET "http://127.0.0.1:8080/api/api-projects?current=1&size=10" \
  -H "Authorization: Bearer TOKEN"
```

### 3.2 API环境

```bash
# 创建环境
curl -X POST http://127.0.0.1:8080/api/api-environments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"name":"测试环境","projectId":1,"variables":{"baseUrl":"https://httpbin.org"},"isDefault":true}'
```

### 3.3 执行API请求

```bash
# 执行请求
curl -X POST http://127.0.0.1:8080/api/api-requests/execute \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"url":"https://httpbin.org/get","method":"GET","headers":{"Content-Type":"application/json"}}'
```

### 3.4 执行测试套件

```bash
# 执行套件
curl -X POST http://127.0.0.1:8080/api/api-test-suites/1/execute \
  -H "Authorization: Bearer TOKEN"
```

## 四、测试结果记录

| 测试日期 | 测试人员 | 通过数 | 失败数 | 通过率 | 备注 |
|---------|---------|-------|-------|-------|------|
| 2026-04-30 | | | | | |
