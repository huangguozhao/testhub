# 操作日志模块测试

## 一、接口列表

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 分页查询 | GET | /api/operation-logs | 分页查询日志 | P1 |
| 获取详情 | GET | /api/operation-logs/{id} | 获取日志详情 | P1 |
| 按资源查询 | GET | /api/operation-logs/resource/{type}/{id} | 获取资源操作记录 | P2 |
| 按用户查询 | GET | /api/operation-logs/user/{userId} | 获取用户操作记录 | P2 |
| 删除日志 | DELETE | /api/operation-logs/{id} | 删除单条日志 | P1 |
| 清理旧日志 | DELETE | /api/operation-logs/clean | 清理旧日志 | P1 |

## 二、测试用例

### 2.1 日志查询测试 (LOG-QUERY)

| 用例ID | 用例名称 | 预期结果 | 状态 |
|-------|---------|---------|------|
| LOG-QUERY-001 | 分页查询日志 | 返回分页日志 | |
| LOG-QUERY-002 | 按操作类型筛选 | 返回筛选结果 | |
| LOG-QUERY-003 | 按资源类型筛选 | 返回筛选结果 | |
| LOG-QUERY-004 | 按用户ID筛选 | 返回用户操作 | |
| LOG-QUERY-005 | 按资源ID筛选 | 返回资源操作 | |
| LOG-QUERY-006 | 获取日志详情 | 返回完整日志 | |
| LOG-QUERY-007 | 获取不存在的日志 | 返回404 | |
| LOG-QUERY-008 | 按资源类型和ID查询 | 返回资源操作记录 | |
| LOG-QUERY-009 | 按用户ID查询 | 返回用户操作记录 | |

### 2.2 日志管理测试 (LOG-MANAGE)

| 用例ID | 用例名称 | 预期结果 | 状态 |
|-------|---------|---------|------|
| LOG-MANAGE-001 | 删除单条日志 | 删除成功 | |
| LOG-MANAGE-002 | 删除不存在的日志 | 返回404 | |
| LOG-MANAGE-003 | 清理30天前日志 | 清理成功 | |
| LOG-MANAGE-004 | 清理未来日期日志 | 提示无日志 | |

## 三、curl 测试命令

### 3.1 查询操作日志

```bash
# 分页查询日志
curl -X GET "http://127.0.0.1:8080/api/operation-logs?current=1&size=20" \
  -H "Authorization: Bearer TOKEN"

# 按操作类型筛选
curl -X GET "http://127.0.0.1:8080/api/operation-logs?operationType=create" \
  -H "Authorization: Bearer TOKEN"

# 按资源类型筛选
curl -X GET "http://127.0.0.1:8080/api/operation-logs?resourceType=project" \
  -H "Authorization: Bearer TOKEN"

# 按用户ID筛选
curl -X GET "http://127.0.0.1:8080/api/operation-logs?userId=1" \
  -H "Authorization: Bearer TOKEN"

# 获取日志详情
curl -X GET http://127.0.0.1:8080/api/operation-logs/1 \
  -H "Authorization: Bearer TOKEN"

# 按资源查询
curl -X GET http://127.0.0.1:8080/api/operation-logs/resource/project/1 \
  -H "Authorization: Bearer TOKEN"

# 按用户查询
curl -X GET http://127.0.0.1:8080/api/operation-logs/user/1?limit=20 \
  -H "Authorization: Bearer TOKEN"
```

### 3.2 管理操作日志

```bash
# 删除单条日志
curl -X DELETE http://127.0.0.1:8080/api/operation-logs/1 \
  -H "Authorization: Bearer TOKEN"

# 清理30天前日志
curl -X DELETE "http://127.0.0.1:8080/api/operation-logs/clean?days=30" \
  -H "Authorization: Bearer TOKEN"
```

## 四、测试结果记录

| 测试日期 | 测试人员 | 通过数 | 失败数 | 通过率 | 备注 |
|---------|---------|-------|-------|-------|------|
| 2026-04-30 | | | | | |
