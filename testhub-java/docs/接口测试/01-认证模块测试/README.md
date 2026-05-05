# 认证模块测试

## 一、接口列表

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 登录 | POST | /api/auth/login | 用户登录 | P0 |
| 注册 | POST | /api/auth/register | 用户注册 | P0 |
| 刷新Token | POST | /api/auth/refresh | 刷新访问令牌 | P0 |
| 登出 | POST | /api/auth/logout | 用户登出 | P0 |
| 当前用户 | GET | /api/auth/me | 获取当前用户信息 | P0 |
| 更新资料 | PUT | /api/auth/profile | 更新个人资料 | P1 |
| 修改密码 | PUT | /api/auth/password | 修改密码 | P1 |

## 二、测试用例

### 2.1 登录测试 (AUTH-LOGIN)

| 用例ID | 用例名称 | 测试步骤 | 预期结果 | 实际结果 | 状态 |
|-------|---------|---------|---------|---------|------|
| AUTH-LOGIN-001 | 正常登录 | 使用有效账号登录 | 返回Token和用户信息 | | |
| AUTH-LOGIN-002 | 用户名不存在 | 使用不存在的用户名 | 返回错误 | | |
| AUTH-LOGIN-003 | 密码错误 | 使用正确用户名+错误密码 | 返回错误 | | |
| AUTH-LOGIN-004 | 用户已禁用 | 使用禁用状态的用户登录 | 返回用户已禁用 | | |
| AUTH-LOGIN-005 | 用户名为空 | 用户名留空 | 返回用户名为空 | | |
| AUTH-LOGIN-006 | 密码为空 | 密码留空 | 返回密码为空 | | |
| AUTH-LOGIN-007 | JSON格式错误 | 发送非法JSON | 返回解析错误 | | |

### 2.2 注册测试 (AUTH-REGISTER)

| 用例ID | 用例名称 | 测试步骤 | 预期结果 | 实际结果 | 状态 |
|-------|---------|---------|---------|---------|------|
| AUTH-REG-001 | 正常注册 | 填写完整信息注册 | 注册成功，返回Token | | |
| AUTH-REG-002 | 用户名已存在 | 使用已存在用户名 | 返回用户名已存在 | | |
| AUTH-REG-003 | 邮箱已注册 | 使用已存在邮箱 | 返回邮箱已被注册 | | |
| AUTH-REG-004 | 用户名为空 | 用户名留空 | 返回用户名为空 | | |
| AUTH-REG-005 | 邮箱格式错误 | 填写非法邮箱格式 | 返回邮箱格式错误 | | |
| AUTH-REG-006 | 密码过短 | 密码少于6位 | 返回密码至少6位 | | |
| AUTH-REG-007 | 缺少必填字段 | 缺少realName | 注册成功(realName可选) | | |

### 2.3 Token刷新测试 (AUTH-REFRESH)

| 用例ID | 用例名称 | 测试步骤 | 预期结果 | 实际结果 | 状态 |
|-------|---------|---------|---------|---------|------|
| AUTH-REF-001 | 正常刷新 | 使用有效refreshToken | 返回新accessToken | | |
| AUTH-REF-002 | 无效Token | 使用伪造Token | 返回刷新令牌无效 | | |
| AUTH-REF-003 | 过期Token | 使用已过期Token | 返回刷新令牌已过期 | | |
| AUTH-REF-004 | 已使用Token | 重复使用同一Token | 返回刷新令牌已失效 | | |
| AUTH-REF-005 | Token为空 | refreshToken留空 | 返回刷新令牌不能为空 | | |

### 2.4 登出测试 (AUTH-LOGOUT)

| 用例ID | 用例名称 | 测试步骤 | 预期结果 | 实际结果 | 状态 |
|-------|---------|---------|---------|---------|------|
| AUTH-LOGOUT-001 | 正常登出 | 携带Token调用登出 | 登出成功，Token加入黑名单 | | |
| AUTH-LOGOUT-002 | 登出后访问 | 使用登出后的Token | 返回401 | | |
| AUTH-LOGOUT-003 | 无Token登出 | 不带Token调用登出 | 返回401 | | |

### 2.5 用户信息测试 (AUTH-USER)

| 用例ID | 用例名称 | 测试步骤 | 预期结果 | 实际结果 | 状态 |
|-------|---------|---------|---------|---------|------|
| AUTH-USER-001 | 获取当前用户 | 携带有效Token | 返回用户信息 | | |
| AUTH-USER-002 | 无Token访问 | 不带Token | 返回401 | | |
| AUTH-USER-003 | 无效Token | 使用伪造Token | 返回401 | | |

## 三、curl 测试命令

### 3.1 登录
```bash
curl -X POST http://127.0.0.1:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test_admin","password":"Test123456"}'
```

### 3.2 注册
```bash
curl -X POST http://127.0.0.1:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"new_user_001","password":"Test123456","email":"new@test.com","realName":"测试用户"}'
```

### 3.3 刷新Token
```bash
curl -X POST http://127.0.0.1:8080/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"your_refresh_token_here"}'
```

### 3.4 获取当前用户
```bash
curl -X GET http://127.0.0.1:8080/api/auth/me \
  -H "Authorization: Bearer your_access_token_here"
```

### 3.5 登出
```bash
curl -X POST http://127.0.0.1:8080/api/auth/logout \
  -H "Authorization: Bearer your_access_token_here"
```

## 四、测试结果记录

| 测试日期 | 测试人员 | 通过数 | 失败数 | 通过率 | 备注 |
|---------|---------|-------|-------|-------|------|
| 2026-04-30 | | | | | |
