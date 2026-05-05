# CLAUDE.md - Java版本

## 项目概述

Java版本的TestHub平台，使用Spring Boot + MyBatis-Plus构建后端API服务。

## 当前分支
`feature/minimal-ui-redesign`

## 常用命令

```bash
# 启动后端服务
mvn spring-boot:run

# 检查服务状态
curl http://127.0.0.1:8080/api/auth/login

# 数据库连接
mysql -u root -proot -h 127.0.0.1 -P 3307 testhub_java
```

## 已完成模块

| 模块 | 状态 | 说明 |
|------|------|------|
| Auth (认证) | ✓ 完成 | 登录/注册/Token/登出 |
| Project (项目) | ✓ 完成 | CRUD/成员/环境 |
| Notification (通知) | ✓ 完成 | 配置/发送/日志 |
| OperationLog (日志) | △ 基本完成 | 查询/清理 (有bug) |
| APITesting | △ 有Bug | 列表可查询，但创建/执行返回500 |

## 待修复Bug (优先级高)

1. **APITesting创建接口500错误**
   - 文件: controller/ApiProjectController.java, ApiEnvironmentController.java等
   - 原因: 数据库表可能不存在

2. **404错误处理不正确**
   - 文件: 各Controller
   - 原因: NotFound检查逻辑问题

## 测试

```bash
# 运行所有测试
bash docs/接口测试/scripts/run-all-tests.sh

# 单独测试
bash docs/接口测试/01-认证模块测试/curl/Auth-Module-Test.sh
```

## 当前进度记录

上次会话完成:
- 认证模块: 16/16 通过 ✓
- 项目管理: 17/18 通过 (94%)
- APITesting: 11/19 通过 (58%) - **有bug需修复**
- 通知系统: 18/18 通过 ✓
- 操作日志: 14/17 通过 (82%)

下一步:
1. 检查数据库表 `api_project`, `api_environment`, `api_collection`
2. 修复APITesting模块创建接口500错误
3. 修复404错误处理