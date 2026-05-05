# TestHub Java版本 接口测试文档索引

## 目录结构

```
docs/接口测试/
├── README.md                           # 测试规划总览
├── index.md                            # 本文档
│
├── 00-测试环境说明.md                   # 测试环境配置
│
├── 01-认证模块测试/
│   ├── README.md                       # 模块测试说明
│   ├── curl/
│   │   └── Auth-Module-Test.sh        # curl 测试脚本 ✓
│   └── postman/
│       └── Auth-Module.postman_collection.json ✓
│
├── 02-项目管理测试/
│   ├── README.md
│   ├── curl/
│   │   └── Project-Module-Test.sh     # curl 测试脚本 ✓
│   └── postman/
│       └── Project-Module.postman_collection.json ✓
│
├── 03-APITesting模块测试/
│   ├── README.md
│   ├── curl/
│   │   └── APITesting-Module-Test.sh  # curl 测试脚本 ✓
│   └── postman/
│       └── APITesting-Module.postman_collection.json ✓
│
├── 04-通知系统测试/
│   ├── README.md
│   ├── curl/
│   │   └── Notification-Module-Test.sh # curl 测试脚本 ✓
│   └── postman/
│       └── Notification-Module.postman_collection.json ✓
│
├── 05-操作日志测试/
│   ├── README.md
│   ├── curl/
│   │   └── OperationLog-Module-Test.sh # curl 测试脚本 ✓
│   └── postman/
│       └── OperationLog-Module.postman_collection.json ✓
│
├── scripts/
│   ├── cleanup-test-data.sql           # 测试数据清理脚本 ✓
│   └── run-all-tests.sh               # 批量测试执行脚本 ✓
│
├── results/                            # 测试结果目录 (自动生成)
│
└── reports/                            # 测试报告目录
    ├── 测试报告_模板.md                # Markdown 报告模板 ✓
    ├── 测试报告_模板.html              # HTML 报告模板 ✓
    └── 测试结果汇总_模板.csv           # Excel 报告模板 ✓
```

## 快速开始

### 1. 环境准备

```bash
# 1. 确保后端服务运行中
cd D:\Project\testhub_platform\testhub-java
mvn spring-boot:run

# 2. 检查服务是否启动
curl http://127.0.0.1:8080/api/auth/login
```

### 2. 创建测试用户

```bash
# 注册测试管理员账号
curl -X POST http://127.0.0.1:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test_admin","password":"Test123456","email":"test_admin@test.com","realName":"测试管理员"}'

# 注册测试普通用户账号
curl -X POST http://127.0.0.1:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test_user","password":"Test123456","email":"test_user@test.com","realName":"测试用户"}'
```

### 3. 使用 curl 测试

```bash
# 进入测试目录
cd docs/接口测试

# 运行认证模块测试
bash 01-认证模块测试/curl/Auth-Module-Test.sh

# 运行项目管理测试
bash 02-项目管理测试/curl/Project-Module-Test.sh

# 运行APITesting模块测试
bash 03-APITesting模块测试/curl/APITesting-Module-Test.sh

# 运行通知系统测试
bash 04-通知系统测试/curl/Notification-Module-Test.sh

# 运行操作日志测试
bash 05-操作日志测试/curl/OperationLog-Module-Test.sh

# 运行所有测试
bash scripts/run-all-tests.sh
```

### 4. 使用 Postman 测试

1. 打开 Postman
2. 导入 Collection:
   - `01-认证模块测试/postman/Auth-Module.postman_collection.json`
   - `02-项目管理测试/postman/Project-Module.postman_collection.json`
   - 其他模块...
3. 配置 Environment:
   - `baseUrl`: http://127.0.0.1:8080/api
   - `accessToken`: (留空)
4. 运行 Collection

### 5. 生成测试报告

```bash
# 运行所有测试并生成报告
bash scripts/run-all-tests.sh

# 报告位置: reports/测试报告_YYYY-MM-DD.md
```

## 模块测试状态

| 模块 | curl脚本 | Postman | 测试用例 | 状态 |
|-----|---------|---------|---------|------|
| 认证模块 | ✓ | ✓ | 16 | 已测试 ✓ |
| 项目管理 | ✓ | ✓ | 18 | 已测试 94% |
| APITesting | ✓ | ✓ | 19 | 已测试 58% |
| 通知系统 | ✓ | ✓ | 18 | 已测试 ✓ |
| 操作日志 | ✓ | ✓ | 17 | 已测试 82% |

## 接口清单

### 认证模块 (7个接口)
- POST /api/auth/login
- POST /api/auth/register
- POST /api/auth/refresh
- POST /api/auth/logout
- GET /api/auth/me
- PUT /api/auth/profile
- PUT /api/auth/password

### 项目管理 (19个接口)
- POST /api/projects
- GET /api/projects
- GET /api/projects/page
- GET /api/projects/{id}
- PUT /api/projects/{id}
- DELETE /api/projects/{id}
- GET /api/projects/search
- GET /api/projects/{id}/members
- POST /api/projects/{id}/members
- PUT /api/projects/{id}/members/{memberId}
- DELETE /api/projects/{id}/members/{userId}
- GET /api/projects/{id}/members/role
- GET /api/projects/{id}/environments
- GET /api/projects/{id}/environments/default
- POST /api/projects/{id}/environments
- PUT /api/projects/{id}/environments/{envId}
- DELETE /api/projects/{id}/environments/{envId}
- PUT /api/projects/{id}/environments/{envId}/default

### API Testing (约40个接口)
- API项目: 5个接口
- API环境: 7个接口
- API集合: 6个接口
- API请求: 7个接口
- API测试套件: 6个接口
- API定时任务: 9个接口
- 请求历史: 8个接口

### 通知系统 (14个接口)
- 通知配置: 9个接口
- 通知发送: 5个接口

### 操作日志 (6个接口)
- GET /api/operation-logs
- GET /api/operation-logs/{id}
- GET /api/operation-logs/resource/{type}/{id}
- GET /api/operation-logs/user/{userId}
- DELETE /api/operation-logs/{id}
- DELETE /api/operation-logs/clean

## 数据库信息

| 项目 | 配置 |
|-----|------|
| Host | 127.0.0.1 |
| Port | 3307 |
| Database | testhub_java |
| Username | root |
| Password | root |

### 常用SQL

```sql
-- 查看所有用户
SELECT id, username, email, role_name FROM sys_user;

-- 查看所有项目
SELECT id, name, description FROM prj_project;

-- 清理测试数据
DELETE FROM prj_project WHERE name LIKE 'TEST_%';
```

## 注意事项

1. **Token 有效期**: Access Token 15分钟，过期后需刷新
2. **数据清理**: 每次测试前建议清理旧数据
3. **并发限制**: 避免同时运行多个测试脚本
4. **敏感信息**: 测试脚本使用测试账号，不使用生产密码

## 历史测试记录

| 日期 | 报告文件 | 通过率 | 测试人员 |
|-----|---------|-------|---------|
| 2026-04-30 | 测试报告_2026-04-30.md | 86% (76/88) | 自动化测试 |

## 更新日志

| 版本 | 日期 | 更新内容 |
|-----|------|---------|
| v1.0 | 2026-04-30 | 初始版本，包含所有模块的curl和Postman测试 |
| v1.1 | 2026-04-30 | 执行首次自动化测试，发现APITesting模块存在后端bug |
