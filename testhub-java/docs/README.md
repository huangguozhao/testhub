# TestHub Java 测试文档

本目录包含 API Testing 模块的测试用例、测试报告和 Postman 集合。

---

## 目录结构

### 测试用例
- `api-test-cases.md` - 后端接口测试用例，包含所有 API 端点的请求/响应示例

### 测试报告
- `API-Testing-Test-Report.md` - Markdown 格式测试报告
- `API-Testing-Test-Report.html` - HTML 格式测试报告
- `api-test-report-template.html` - 测试报告模板

### Postman 集合
- `TestHub Java API.postman_collection.json` - Java 版本 API 接口集合
- `TestHub-Permission-Tests.postman_collection.json` - 权限测试集合

### 其他
- `python-java-diff.md` - Python 与 Java 版本功能差异对比

---

## 快速开始

### 1. 导入 Postman 集合
1. 打开 Postman
2. 点击 Import
3. 选择 `TestHub Java API.postman_collection.json`
4. 配置环境变量 `baseUrl`: `http://localhost:8080`

### 2. 运行测试
1. 登录获取 Token
2. 在 Postman 中设置全局变量或 Authorization header
3. 执行各个接口测试

### 3. 查看测试报告
- Markdown: 直接打开 `API-Testing-Test-Report.md`
- HTML: 用浏览器打开 `API-Testing-Test-Report.html`

---

## 测试覆盖范围

| 模块 | 请求数 |
|------|--------|
| 认证 Auth | 8 |
| 用户管理 User | 7 |
| 项目管理 Project | 18 |
| 测试用例 TestCase | 4 |
| 测试套件 TestSuite | 3 |
| 测试计划 TestPlan | 3 |
| 测试执行 Execution | 5 |
| API集合 | 2 |
| API请求 | 3 |
| API环境 | 2 |
| API测试套件 | 4 |
| API定时任务 | 5 |
| API执行记录 | 2 |
| 权限测试 | 7 |
| API Testing 增强 | 21 |
| **总计** | **127** |

---

## 更新日志

- 2026-04-30: 初始文档，添加 API Testing 模块测试用例和报告
