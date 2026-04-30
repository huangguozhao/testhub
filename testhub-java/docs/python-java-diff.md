# Python vs Java 版本功能差异分析

## 文档信息
- 分析日期: 2026-04-29
- Python版本: Django + Vue 3
- Java版本: Spring Boot 3.2.5 + MyBatis-Plus

---

## 一、模块对比总览

| 模块 | Python (apps/) | Java (modules/) | 状态 |
|------|----------------|------------------|------|
| 用户认证 | users/ | system/ | ✅ Java已实现 |
| 项目管理 | projects/ | project/ | ✅ Java已实现 |
| 测试用例 | testcases/ | 待开发 | ❌ 缺失 |
| 测试套件 | testsuites/ | 待开发 | ❌ 缺失 |
| 测试执行 | executions/ | 待开发 | ❌ 缺失 |
| 用例评审 | reviews/ | 待开发 | ❌ 缺失 |
| 版本管理 | versions/ | 待开发 | ❌ 缺失 |
| 测试报告 | reports/ | 待开发 | ❌ 缺失 |
| API测试 | api_testing/ | 待开发 | ❌ 缺失 |
| UI自动化 | ui_automation/ | 待开发 | ❌ 缺失 |
| APP自动化 | app_automation/ | 待开发 | ❌ 缺失 |
| 需求分析AI | requirement_analysis/ | 待开发 | ❌ 缺失 |
| AI助手 | assistant/ | 待开发 | ❌ 缺失 |
| 数据工厂 | data_factory/ | 待开发 | ❌ 缺失 |

---

## 二、数据库表差异

### 2.1 系统表 (sys_)

| Python (users_user) | Java (sys_user) | 差异 |
|---------------------|------------------|------|
| username | username | ✅ 一致 |
| email | email | ✅ 一致 |
| password | password | ✅ 一致 |
| first_name/last_name | real_name | 🔄 合并 |
| - | role_name | ✨ Java新增 |
| - | is_superuser | ✨ Java新增 |
| - | is_staff | ✨ Java新增 |
| is_superuser (Django内置) | - | Django内置 |
| is_staff (Django内置) | - | Django内置 |
| is_active | status | 🔄 语义相同，名称不同 |

### 2.2 项目表对比

**Python**: `projects` → **Java**: `prj_project`

| 字段 | Python | Java | 状态 |
|------|--------|------|------|
| name | name | name | ✅ |
| description | description | description | ✅ |
| status | status | status | ✅ |
| owner | owner (FK) | owner_id | 🔄 类型不同 |
| icon | - | icon | ✨ Java新增 |
| sort_order | - | sort_order | ✨ Java新增 |
| include_test_cases | - | include_test_cases | ✨ Java新增 |
| include_automated_tests | - | include_automated_tests | ✨ Java新增 |
| created_at | created_at | created_at | ✅ |

### 2.3 项目环境表

**Python**: `project_environments` → **Java**: `prj_project_environment`

| 字段 | Python | Java | 状态 |
|------|--------|------|------|
| project | project (FK) | project_id | 🔄 |
| name | name | name | ✅ |
| base_url | base_url | base_url | ✅ |
| description | description | description | ✅ |
| variables | variables (JSON) | variables | 🔄 Python是JSON，Java是VARCHAR |
| is_default | is_default | is_default | ✅ |
| - | sort_order | ✨ Java新增 |

### 2.4 测试用例表

**Python**: `testcases` → **Java**: `tc_test_case`

| 字段 | Python | Java | 状态 |
|------|--------|------|------|
| project | project (FK) | project_id | ✅ |
| title | title | title | ✅ |
| description | description | description | ✅ |
| preconditions | preconditions | precondition | 🔄 名称简化 |
| steps | steps | - | ❌ Java缺失 |
| expected_result | expected_result | expected_result | ✅ |
| priority | priority | priority | ✅ |
| status | status | status | ✅ |
| test_type | test_type | type | 🔄 名称不同 |
| tags | tags | - | ❌ Java缺失 (用label关联表代替) |
| author | author (FK) | created_by | 🔄 |
| assignee | assignee (FK) | - | ❌ Java缺失 |
| versions | versions (M2M) | - | ❌ Java缺失 |

### 2.5 测试用例步骤表

**Python**: `testcase_steps` → **Java**: `tc_test_case_step`

| 字段 | Python | Java | 状态 |
|------|--------|------|------|
| testcase | testcase (FK) | test_case_id | ✅ |
| step_number | step_number | step_number | ✅ |
| action | action | description | 🔄 名称不同 |
| expected | expected | expected_result | 🔄 |

### 2.6 测试套件表

**Python**: `testsuites` → **Java**: `ts_test_suite`

| 字段 | Python | Java | 状态 |
|------|--------|------|------|
| project | project (FK) | project_id | ✅ |
| name | name | name | ✅ |
| description | description | description | ✅ |
| testcases | testcases (M2M) | - | ❌ 用关联表 |
| author | author (FK) | created_by | 🔄 |

### 2.7 测试计划表

**Python**: `test_plans` → **Java**: `exec_test_plan`

| 字段 | Python | Java | 状态 |
|------|--------|------|------|
| name | name | name | ✅ |
| description | description | description | ✅ |
| projects | projects (M2M) | project_id | 🔄 Python是多对多 |
| version | version (FK) | - | ❌ Java缺失 |
| creator | creator (FK) | created_by | 🔄 |
| assignees | assignees (M2M) | assignee_id | 🔄 |
| is_active | is_active | - | ❌ Java缺失 |
| start_date | - | start_date | ✨ Java新增 |
| end_date | - | end_date | ✨ Java新增 |
| status | - | status | ✨ Java新增 |

### 2.8 测试执行表

**Python**: `test_runs` → **Java**: `exec_test_run`

| 字段 | Python | Java | 状态 |
|------|--------|------|------|
| name | name | - | ❌ |
| test_plan | test_plan (FK) | plan_id | ✅ |
| project | project (FK) | - | ❌ |
| version | version (FK) | - | ❌ |
| assignee | assignee (FK) | - | ❌ |
| creator | creator (FK) | executor_id | 🔄 |
| status | status | status | ✅ |
| started_at | started_at | started_at | ✅ |
| completed_at | completed_at | completed_at | ✅ |
| due_date | due_date | - | ❌ |

### 2.9 执行用例表

**Python**: `test_run_cases` → **Java**: `exec_test_run_case`

| 字段 | Python | Java | 状态 |
|------|--------|------|------|
| test_run | test_run (FK) | run_id | ✅ |
| testcase | testcase (FK) | test_case_id | ✅ |
| status | status | status | ✅ |
| priority | priority | - | ❌ Java缺失 |
| actual_result | actual_result | result | 🔄 |
| comments | comments | - | 🔄 |
| defects | defects (JSON) | bug_ids | 🔄 |
| elapsed_time | elapsed_time | - | ❌ |
| executed_by | executed_by (FK) | executor_id | 🔄 |
| executed_at | executed_at | executed_at | ✅ |

---

## 三、功能差异汇总

### 3.1 已实现功能 (Java)

| 功能 | Python | Java | 说明 |
|------|--------|------|------|
| 用户注册 | ✅ | ✅ | |
| 用户登录 | ✅ | ✅ | |
| JWT双Token | ✅ | ✅ | |
| Token刷新 | ✅ | ✅ | |
| 退出登录 | ✅ | ✅ | |
| 项目CRUD | ✅ | ✅ | |
| 项目成员管理 | ✅ | ✅ | |
| 项目环境管理 | ✅ | ✅ | |

### 3.2 Java缺失功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 测试用例管理 | 完整的用例CRUD、步骤、附件、评论 | P0 |
| 测试套件管理 | 套件CRUD、用例关联 | P0 |
| 测试执行 | 计划管理、执行记录 | P0 |
| 用例评审 | 评审流程、模板、分配 | P1 |
| 版本管理 | 版本CRUD | P1 |
| 测试报告 | 报告生成、导出 | P1 |
| 标签管理 | 用例标签 | P1 |

### 3.3 数据库差异

| 问题 | 位置 | 说明 |
|------|------|------|
| Java多字段 | sys_user | role_name, is_superuser, is_staff 是Java扩展字段 |
| 字段名不同 | 多处 | precondition vs preconditions, type vs test_type |
| JSON vs VARCHAR | prj_project_environment.variables | Python用JSONField，Java用VARCHAR |
| 外键类型 | 多处 | Python用FK对象，Java用bigint ID |
| 多对多关系 | projects, testcases | Java用关联表实现 |

---

## 四、修复建议

### 4.1 紧急修复

1. **数据库字段补全**:
   - `prj_project_environment.base_url` - ✅ 已修复
   - 其他缺失字段待补充

2. **TestCase实体补全**:
   - 添加 `steps` 字段 (或使用TestCaseStep表)
   - 添加 `tags` 字段
   - 添加 `assignee_id` 字段

### 4.2 下一步开发重点

1. **TestCase模块** - 最核心的测试用例管理
2. **TestSuite模块** - 测试套件管理
3. **Execution模块** - 测试执行管理

---

## 五、数据类型对照

| Python Django | Java MyBatis-Plus |
|---------------|-------------------|
| CharField | VARCHAR |
| TextField | TEXT |
| IntegerField | INT/BIGINT |
| BooleanField | TINYINT(1) |
| DateTimeField | DATETIME |
| JSONField | VARCHAR (JSON格式存储) |
| ForeignKey | BIGINT (外键ID) |
| ManyToManyField | 中间关联表 |
| AutoField | BIGINT AUTO_INCREMENT |
| UUIDField | VARCHAR(36) |
| URLField | VARCHAR(500) |
| EmailField | VARCHAR(100) |
| ImageField | VARCHAR(500) (存储URL) |
| FileField | VARCHAR(500) (存储URL) |

---

*最后更新: 2026-04-29*
