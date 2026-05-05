# TestHub Java版本 接口测试规划

## 一、测试目标

对 TestHub Java 版本的所有 REST API 进行全面的功能测试、异常测试、安全测试，生成可重复执行的测试脚本和详细测试报告。

---

## 二、接口清单汇总

### 2.1 接口统计

| 模块 | Controller | 接口数量 | 优先级 |
|-----|------------|---------|-------|
| 认证模块 | AuthController | 7 | P0 |
| 用户管理 | UserController | 7 | P1 |
| 项目管理 | ProjectController | 19 | P0 |
| API项目 | ApiProjectController | 5 | P0 |
| API环境 | ApiEnvironmentController | 7 | P0 |
| API集合 | ApiCollectionController | 6 | P0 |
| API请求 | ApiRequestController | 7 | P0 |
| API测试套件 | ApiTestSuiteController | 6 | P1 |
| API定时任务 | ApiScheduledTaskController | 9 | P1 |
| API执行记录 | ApiExecutionRecordController | 4 | P2 |
| API请求历史 | ApiRequestHistoryController | 8 | P1 |
| 通知配置 | NotificationConfigController | 9 | P1 |
| 通知 | NotificationController | 5 | P1 |
| 操作日志 | OperationLogController | 6 | P2 |

**总计：14个控制器，约105个接口**

### 2.2 优先级定义

| 优先级 | 定义 | 说明 |
|-------|------|------|
| P0 | 核心功能 | 必须测试，影响主流程 |
| P1 | 重要功能 | 需要测试，影响主要功能 |
| P2 | 一般功能 | 常规测试 |

---

## 三、测试维度

### 3.1 功能测试
- 正常数据提交
- CRUD 完整流程
- 关联数据处理
- 分页、筛选、排序

### 3.2 异常测试
- 必填字段为空
- 字段格式错误
- 不存在的数据 ID
- 重复数据提交
- 边界值测试

### 3.3 安全测试
- 未授权访问
- 无效 Token
- 过期 Token
- 越权操作
- SQL 注入 / XSS

### 3.4 关联测试
- 前后端数据一致性
- 表单关联关系
- 批量操作

---

## 四、测试数据管理策略

### 4.1 测试用户

| 用户名 | 角色 | 用途 |
|-------|------|------|
| test_admin | ADMIN | 管理员权限测试 |
| test_user | USER | 普通用户测试 |

### 4.2 测试数据隔离

采用**测试前缀 + 时间戳**策略：
```
测试项目名: TEST_{module}_{timestamp}
测试数据ID: 动态获取，每次测试前创建，测试后清理
```

### 4.3 数据回滚机制

每个模块测试前执行清理脚本，确保测试环境干净：
```bash
# 测试前清理
./scripts/cleanup-test-data.sh

# 测试后确认
# 检查是否所有测试数据已清理
```

---

## 五、测试输出物

### 5.1 文件结构

```
docs/接口测试/
├── README.md                          # 本文档
├── 00-测试环境说明.md                  # 测试环境配置
├── 01-认证模块测试/
│   ├── README.md                      # 模块测试说明
│   ├── curl/                          # curl 测试脚本
│   │   ├── 01-login.sh                # 登录测试
│   │   ├── 02-register.sh            # 注册测试
│   │   └── 03-token-refresh.sh        # Token刷新测试
│   └── postman/
│       └── Auth-Module.postman_collection.json
├── 02-项目管理测试/
│   ├── README.md
│   ├── curl/
│   │   └── *.sh
│   └── postman/
│       └── Project-Module.postman_collection.json
├── 03-APITesting模块测试/
│   ├── README.md
│   ├── curl/
│   │   ├── 01-api-project.sh
│   │   ├── 02-api-environment.sh
│   │   ├── 03-api-collection.sh
│   │   ├── 04-api-request.sh
│   │   ├── 05-api-suite.sh
│   │   └── 06-api-execute.sh
│   └── postman/
│       └── APITesting-Module.postman_collection.json
├── 04-通知系统测试/
│   ├── README.md
│   ├── curl/
│   └── postman/
├── 05-操作日志测试/
│   ├── README.md
│   ├── curl/
│   └── postman/
├── scripts/
│   ├── setup-test-data.sql            # 测试数据初始化
│   ├── cleanup-test-data.sql          # 测试数据清理
│   └── run-tests.sh                   # 批量执行脚本
├── results/
│   ├── 2026-04-30/
│   │   ├── 01-auth-results.md
│   │   ├── 02-project-results.md
│   │   └── summary.md
│   └── index.md                       # 测试结果索引
├── reports/
│   ├── 2026-04-30-测试报告.md
│   ├── 2026-04-30-测试报告.xlsx
│   └── 2026-04-30-测试报告.html
└── logs/
    └── test-execution.log             # 测试执行日志
```

### 5.2 报告格式

**Markdown 报告**：详细说明，每个测试用例的结果
**Excel 报告**：汇总表格，方便统计和筛选
**HTML 报告**：可在线查看，带样式

---

## 六、测试执行流程

### 6.1 执行顺序

```
1. 环境准备
   ├── 启动后端服务
   ├── 确认数据库连接
   └── 确认端口可用 (8080)

2. 认证模块测试 (P0)
   ├── 登录/注册
   ├── Token管理
   └── 获取测试 Token

3. 项目管理测试 (P0)
   ├── 创建项目
   ├── 成员管理
   └── 环境管理

4. APITesting模块测试 (P0/P1)
   ├── API项目
   ├── API环境
   ├── API集合
   ├── API请求
   ├── API执行
   └── 请求历史

5. 通知系统测试 (P1)
   ├── 通知配置
   └── 通知发送

6. 操作日志测试 (P2)
   ├── 日志查询
   └── 日志清理

7. 汇总报告
   ├── 整理测试结果
   ├── 生成报告
   └── 上传文档
```

### 6.2 每日测试记录

每次测试后更新：
- 测试时间
- 测试人员
- 通过/失败数量
- 发现的缺陷

---

## 七、后续维护

### 7.1 新增接口测试

当有新接口时：
1. 在对应模块创建 `curl/xx.sh`
2. 更新 Postman Collection
3. 更新测试用例文档
4. 执行测试并记录结果

### 7.2 回归测试

每次代码变更后：
1. 运行相关模块的 curl 脚本
2. 验证 Postman Collection
3. 更新测试报告

### 7.3 测试数据重置

如需重置测试环境：
```bash
# 执行清理脚本
mysql -u root -p testhub < scripts/cleanup-test-data.sql

# 重新初始化
mysql -u root -p testhub < scripts/setup-test-data.sql
```

---

## 八、注意事项

1. **Token 有效期**：Access Token 15分钟，测试时注意刷新
2. **并发限制**：避免同时运行多个测试脚本
3. **数据清理**：每次测试后清理测试数据
4. **敏感信息**：测试脚本中的密码使用测试密码，不使用生产密码
5. **日志记录**：所有测试操作记录到日志文件

---

## 九、版本历史

| 版本 | 日期 | 修改内容 | 修改人 |
|-----|------|---------|-------|
| v1.0 | 2026-04-30 | 初始版本 | Claude |
