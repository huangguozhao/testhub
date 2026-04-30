# TestHub 测试报告与分析模块设计方案

## 1. 模块概述

测试报告与分析模块是 TestHub 智能测试管理平台的核心功能之一，提供全面的测试数据分析与可视化能力。该模块整合了手工测试、API 测试、UI 自动化测试等多种测试类型的执行数据，提供执行状态分布、缺陷分析、趋势追踪、AI 效能分析等功能，帮助团队全面掌握测试进度和质量状况。

### 1.1 设计目标

- **多维度数据整合**：整合手工测试、API 测试、UI 自动化等各类测试数据
- **可视化分析**：通过图表直观展示测试执行状态、趋势、缺陷分布
- **AI 效能分析**：追踪 AI 生成测试用例的采纳率和覆盖率
- **团队工作分析**：统计团队成员的工作量和工作质量
- **导出能力**：支持报告导出，便于存档和分享

### 1.2 功能架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        测试报告与分析模块                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │
│  │  测试概览  │  │  执行分析  │  │  缺陷分析  │  │  趋势分析  │      │
│  │ Dashboard  │  │Execution  │  │  Defect   │  │  Trend    │      │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │
│  │  AI效能  │  │  团队工作  │  │  失败用例  │  │  报告导出  │      │
│  │AI Effic. │  │Team Work  │  │Failed Cases│  │Export     │      │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     数据可视化层                                   │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │   │
│  │  │  饼图      │  │  折线图     │  │  柱状图     │            │   │
│  │  │  Pie Chart │  │ Line Chart │  │ Bar Chart  │            │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 技术选型

| 技术项 | 选型 | 说明 |
|-------|------|------|
| 后端框架 | Django 4.2 + Django REST Framework | 成熟稳定的 Python Web 框架 |
| 数据可视化 | ECharts | 百度开源图表库，功能丰富 |
| 前端框架 | Vue 3 + Element Plus | 现代化组件库 |
| 图表库 | Apache ECharts | 高性能图表渲染 |
| 数据库 | MySQL 8.0+ | 支持 utf8mb4 字符集 |

---

## 2. 数据模型设计

### 2.1 模型关系图

```
TestReport (测试报告)
    │
    └─── TestRun (执行记录)
              │
              └─── TestRunCase (执行用例)

ReportTemplate (报告模板)
```

### 2.2 模型详细定义

#### 2.2.1 TestReport (测试报告)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 报告ID |
| project | ForeignKey(Project) | 必填 | 所属项目 |
| name | CharField(200) | 必填 | 报告名称 |
| report_type | CharField(20) | 默认execution | 报告类型 |
| execution | OneToOneField(TestRun) | 可为空 | 关联执行 |
| summary | JSONField | 默认{} | 报告摘要 |
| content | JSONField | 默认{} | 报告内容 |
| generated_by | ForeignKey(User) | 必填 | 生成者 |
| created_at | DateTimeField | 自动 | 创建时间 |

**report_type 枚举**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| execution | 执行报告 | 单次执行的详细报告 |
| summary | 汇总报告 | 多维度汇总统计 |
| trend | 趋势报告 | 趋势分析报告 |

#### 2.2.2 ReportTemplate (报告模板)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 模板ID |
| name | CharField(200) | 必填 | 模板名称 |
| description | TextField | 可为空 | 模板描述 |
| template_config | JSONField | 默认{} | 模板配置 |
| is_default | BooleanField | 默认False | 是否默认 |
| created_by | ForeignKey(User) | 必填 | 创建者 |
| created_at | DateTimeField | 自动 | 创建时间 |

---

## 3. API 接口设计

### 3.1 路由总览

所有 API 接口前缀：`/api/reports/`

| 路由前缀 | ViewSet | 说明 |
|---------|---------|------|
| `reports/` | TestReportViewSet | 测试报告 |

### 3.2 测试概览 API

#### GET `/api/reports/reports/dashboard/`

获取测试概览统计数据。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| project | integer | 否 | 项目ID |

**响应示例**：

```json
{
    "active_plans": 12,
    "plan_progress": 75.5,
    "total_cases": 1250,
    "total_defects": 45,
    "pass_rate": 92.3
}
```

**响应字段说明**：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| active_plans | integer | 活跃测试计划数量 |
| plan_progress | float | 测试计划平均进度（百分比） |
| total_cases | integer | 用例总数 |
| total_defects | integer | 缺陷总数 |
| pass_rate | float | 通过率（百分比） |

### 3.3 执行状态分布 API

#### GET `/api/reports/reports/status_distribution/`

获取测试执行状态分布。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| project | integer | 否 | 项目ID |
| version | integer | 否 | 版本ID |

**响应示例**：

```json
{
    "passed": 850,
    "failed": 45,
    "blocked": 20,
    "retest": 15,
    "untested": 320
}
```

### 3.4 缺陷分布 API

#### GET `/api/reports/reports/defect_distribution/`

获取缺陷按优先级分布。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| project | integer | 否 | 项目ID |

**响应示例**：

```json
[
    {"name": "高", "value": 15},
    {"name": "中", "value": 22},
    {"name": "低", "value": 8}
]
```

### 3.5 失败用例 TOP 榜 API

#### GET `/api/reports/reports/failed_cases_top/`

获取失败次数最多的用例 TOP 10。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| project | integer | 否 | 项目ID |

**响应示例**：

```json
[
    {"testcase__id": 1, "testcase__title": "用户登录-密码错误验证", "fail_count": 5},
    {"testcase__id": 2, "testcase__title": "订单创建-库存不足验证", "fail_count": 4},
    {"testcase__id": 3, "testcase__title": "支付流程-超时处理", "fail_count": 3}
]
```

### 3.6 执行趋势 API

#### GET `/api/reports/reports/execution_trend/`

获取每日执行趋势数据。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| project | integer | 否 | 项目ID |
| days | integer | 否 | 查询天数（默认7） |

**响应示例**：

```json
[
    {"date": "2026-04-04", "count": 45},
    {"date": "2026-04-05", "count": 52},
    {"date": "2026-04-06", "count": 38},
    {"date": "2026-04-07", "count": 61},
    {"date": "2026-04-08", "count": 55},
    {"date": "2026-04-09", "count": 48},
    {"date": "2026-04-10", "count": 63}
]
```

### 3.7 AI 效能分析 API

#### GET `/api/reports/reports/ai_efficiency/`

获取 AI 效能分析数据。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| project | integer | 否 | 项目ID |

**响应示例**：

```json
{
    "ai_vs_manual": {
        "ai": 320,
        "manual": 930
    },
    "adoption_rate": 78.5,
    "requirement_coverage": 85.2,
    "saved_hours": 80.0
}
```

**响应字段说明**：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| ai_vs_manual.ai | integer | AI 生成的用例数量 |
| ai_vs_manual.manual | integer | 人工编写的用例数量 |
| adoption_rate | float | AI 用例采纳率（百分比） |
| requirement_coverage | float | 需求覆盖率（百分比） |
| saved_hours | float | 预估节省时间（小时） |

### 3.8 团队工作量 API

#### GET `/api/reports/reports/team_workload/`

获取团队成员工作量统计。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| project | integer | 否 | 项目ID |

**响应示例**：

```json
[
    {
        "username": "张三",
        "execution_count": 125,
        "defect_count": 18
    },
    {
        "username": "李四",
        "execution_count": 98,
        "defect_count": 12
    },
    {
        "username": "王五",
        "execution_count": 86,
        "defect_count": 15
    }
]
```

---

## 4. 前端页面设计

### 4.1 页面路由

| 路由路径 | 页面组件 | 说明 |
|---------|---------|------|
| `/reports` | AiTestReport.vue | 测试报告仪表盘 |
| `/report-list` | ReportList.vue | 报告列表（开发中） |

### 4.2 报告仪表盘页面 (AiTestReport.vue)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  测试报告与分析                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  项目: [全部▼]   时间范围: [最近7天▼]                        [导出报告]    │
│                                                                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐         │
│  │ 📋 活跃计划  │ │ 📝 总用例数  │ │ ✅ 通过率   │ │ ⚠️ 发现缺陷  │         │
│  │     12     │ │    1250    │ │   92.3%   │ │     45     │         │
│  │ ████░░ 75% │ │            │ │            │ │            │         │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘         │
│                                                                            │
│  ┌───────────────────────────┐  ┌─────────────────────────────────────┐  │
│  │ 执行状态分布 (饼图)        │  │ 每日执行趋势 (折线图)                │  │
│  │ ┌─────────────────────┐  │  │  ▲                                    │  │
│  │ │    🟢 通过   850     │  │  │  │        ╱╲                          │  │
│  │ │    🔴 失败    45     │  │  │  │     ╱╲ ╱  ╲                        │  │
│  │ │    🟡 阻塞    20     │  │  │  │  ╱╲ ╱    ╲                       │  │
│  │ │    🔵 待测   320     │  │  │  │╱                ╲                   │  │
│  │ │    🔷 重测    15     │  │  │  └────────────────────────▶           │  │
│  │ └─────────────────────┘  │  │      04-04  04-06  04-08  04-10     │  │
│  └───────────────────────────┘  └─────────────────────────────────────┘  │
│                                                                            │
│  ┌───────────────────────────┐  ┌─────────────────────────────────────┐  │
│  │ 缺陷优先级分布 (饼图)     │  │ 失败用例 TOP 10 (表格)               │  │
│  │ ┌─────────────────────┐  │  │ ┌─────────────────────────────────┐  │  │
│  │ │    优先级分布       │  │  │ │ 用例标题            │ 失败次数  │  │  │
│  │ │   高 ████████ 15   │  │  │ ├─────────────────────────────────┤  │  │
│  │ │   中 ████████████ 22│  │  │ │ 用户登录-密码错误验证  │   5     │  │  │
│  │ │   低 ██████ 8      │  │  │ │ 订单创建-库存不足验证  │   4     │  │  │
│  │ └─────────────────────┘  │  │ │ 支付流程-超时处理     │   3     │  │  │
│  └───────────────────────────┘  │ └─────────────────────────────────┘  │  │
│                                                                            │
│  ┌───────────────────────────┐  ┌─────────────────────────────────────┐  │
│  │ AI 效能分析                │  │ 团队工作量分布 (堆叠柱状图)            │  │
│  │ ┌─────────────────────┐  │  │                                     │  │
│  │ │ 采纳率    78.5%    │  │  │  张三 ████████████░░ 125           │  │
│  │ │ ████████████████░░ │  │  │  李四 ██████████░░░░  98            │  │
│  │ │                      │  │  │  王五 █████████░░░░░  86            │  │
│  │ │ 需求覆盖率 85.2%     │  │  │                                     │  │
│  │ │ █████████████████░░ │  │  │  深色: 执行数  浅色: 缺陷数          │  │
│  │ │                      │  │  │                                     │  │
│  │ │ 节省时间    80h      │  │  │                                     │  │
│  │ └─────────────────────┘  │  │                                     │  │
│  │ ┌─────────────────────┐  │  │                                     │  │
│  │ │ AI生成 ████████    │  │  │                                     │  │
│  │ │ 人工  █████████████│  │  │                                     │  │
│  │ └─────────────────────┘  │  │                                     │  │
│  └───────────────────────────┘  └─────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 页面布局说明

**顶部筛选栏**：
- 项目选择器：支持按项目筛选数据
- 时间范围选择器：最近7天/14天/30天
- 导出按钮：导出报告功能

**统计卡片区**：
- 活跃测试计划数（含进度环形图）
- 用例总数
- 通过率
- 发现缺陷数

**图表区域**：

| 图表 | 类型 | 数据来源 |
|------|------|---------|
| 执行状态分布 | 饼图 | status_distribution API |
| 每日执行趋势 | 折线图 | execution_trend API |
| 缺陷优先级分布 | 饼图 | defect_distribution API |
| 失败用例 TOP 10 | 表格 | failed_cases_top API |
| AI 效能分析 | 指标卡+柱状图 | ai_efficiency API |
| 团队工作量 | 堆叠柱状图 | team_workload API |

### 4.4 图表配置

**执行状态分布饼图**：

```javascript
{
    series: [{
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['50%', '45%'],
        data: [
            { value: 850, name: '通过', itemStyle: { color: '#67C23A' } },
            { value: 45, name: '失败', itemStyle: { color: '#F56C6C' } },
            { value: 20, name: '阻塞', itemStyle: { color: '#E6A23C' } },
            { value: 15, name: '重测', itemStyle: { color: '#409EFF' } },
            { value: 320, name: '待测', itemStyle: { color: '#909399' } }
        ]
    }]
}
```

**每日执行趋势折线图**：

```javascript
{
    xAxis: {
        type: 'category',
        boundaryGap: false,
        data: dates
    },
    yAxis: {
        type: 'value'
    },
    series: [{
        type: 'line',
        smooth: true,
        areaStyle: {
            opacity: 0.3,
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: '#409EFF' },
                { offset: 1, color: '#fff' }
            ])
        },
        data: counts
    }]
}
```

**团队工作量堆叠柱状图**：

```javascript
{
    series: [
        {
            name: '执行用例数',
            type: 'bar',
            stack: 'total',
            data: execCounts,
            itemStyle: { color: '#409EFF' }
        },
        {
            name: '发现缺陷数',
            type: 'bar',
            stack: 'total',
            data: defectCounts,
            itemStyle: { color: '#F56C6C' }
        }
    ]
}
```

---

## 5. 数据统计逻辑

### 5.1 测试计划进度计算

```python
def calculate_plan_progress():
    """计算测试计划平均进度"""
    total_progress = 0
    plan_count = 0
    
    for plan in TestPlan.objects.filter(is_active=True):
        runs = plan.test_runs.all()
        if runs.exists():
            # 计算该计划下所有Run的进度平均值
            run_progresses = [run.progress_stats['progress'] for run in runs]
            plan_progress = sum(run_progresses) / len(run_progresses)
            total_progress += plan_progress
            plan_count += 1
    
    return round(total_progress / plan_count, 1) if plan_count > 0 else 0
```

### 5.2 通过率计算

```python
def calculate_pass_rate():
    """计算整体通过率"""
    recent_runs = TestRun.objects.order_by('-created_at')[:10]
    total_executed = 0
    total_passed = 0
    
    for run in recent_runs:
        stats = run.progress_stats
        total_executed += stats['tested']
        total_passed += stats['passed']
    
    if total_executed == 0:
        return 0
    
    return round((total_passed / total_executed * 100), 1)
```

### 5.3 缺陷统计

```python
def count_defects():
    """统计缺陷总数"""
    defects_count = 0
    
    for run in TestRun.objects.all():
        run_cases_with_defects = run.run_cases.exclude(defects=[])
        for rc in run_cases_with_defects:
            if isinstance(rc.defects, list):
                defects_count += len(rc.defects)
    
    return defects_count
```

### 5.4 AI 效能分析

```python
def calculate_ai_efficiency():
    """计算AI效能指标"""
    # 1. AI生成 vs 人工创建
    ai_count = GeneratedTestCase.objects.count()
    adopted_ai_count = GeneratedTestCase.objects.filter(status='adopted').count()
    total_cases = TestCase.objects.count()
    manual_count = max(0, total_cases - adopted_ai_count)
    
    # 2. 生成采纳率
    adoption_rate = round((adopted_ai_count / ai_count * 100), 1) if ai_count > 0 else 0
    
    # 3. 需求覆盖率
    total_reqs = BusinessRequirement.objects.count()
    covered_reqs = GeneratedTestCase.objects.filter(
        status='adopted'
    ).values('requirement').distinct().count()
    coverage_rate = round((covered_reqs / total_reqs * 100), 1) if total_reqs > 0 else 0
    
    # 4. 节省时间估算 (假设每个AI用例平均节省15分钟)
    saved_hours = round(ai_count * 15 / 60, 1)
    
    return {
        'ai_vs_manual': {'ai': ai_count, 'manual': manual_count},
        'adoption_rate': adoption_rate,
        'requirement_coverage': coverage_rate,
        'saved_hours': saved_hours
    }
```

---

## 6. 数据库表结构

### 6.1 数据库表清单

| 表名 | 对应模型 | 说明 |
|------|---------|------|
| test_reports | TestReport | 测试报告表 |
| report_templates | ReportTemplate | 报告模板表 |

### 6.2 数据来源表

测试报告模块数据来源涉及以下表：

| 表名 | 所属模块 | 说明 |
|------|---------|------|
| test_plans | executions | 测试计划表 |
| test_runs | executions | 测试执行表 |
| test_run_cases | executions | 执行用例关联表 |
| test_cases | testcases | 用例表 |
| business_requirements | requirement_analysis | 业务需求表 |
| generated_test_cases | requirement_analysis | AI生成用例表 |

---

## 7. 依赖关系

### 7.1 系统依赖

**前端包**：
- vue 3.x
- element-plus
- echarts (图表库)

### 7.2 模块间依赖

| 被依赖模块 | 依赖关系 | 说明 |
|-----------|---------|------|
| executions | 跨模块查询 | TestPlan, TestRun, TestRunCase |
| testcases | 跨模块查询 | TestCase |
| requirement_analysis | 跨模块查询 | GeneratedTestCase, BusinessRequirement |

---

## 8. 已实现代码清单

### 8.1 后端代码

| 文件路径 | 说明 |
|---------|------|
| `apps/reports/__init__.py` | 应用初始化 |
| `apps/reports/apps.py` | Django 应用配置 |
| `apps/reports/models.py` | 数据模型定义 |
| `apps/reports/views.py` | 视图实现（约270行） |
| `apps/reports/urls.py` | 路由配置 |
| `apps/reports/admin.py` | Admin 配置 |

### 8.2 前端代码

| 文件路径 | 说明 |
|---------|------|
| `frontend/src/views/reports/ReportList.vue` | 报告列表（占位组件） |
| `frontend/src/views/reports/AiTestReport.vue` | 测试报告仪表盘（约550行） |

---

## 9. 后续优化建议

### 9.1 功能增强

1. **报告导出**：支持导出为 PDF、Excel、Word 格式
2. **自定义报告模板**：支持用户自定义报告模板和样式
3. **定时推送**：支持定时推送报告到邮箱或企业微信
4. **对比分析**：支持多版本、多周期的测试数据对比
5. **详细报告**：支持查看单个执行或测试计划的详细报告

### 9.2 可视化优化

1. **地图可视化**：支持缺陷地理分布
2. **桑基图**：展示测试流程和缺陷流向
3. **热力图**：展示测试覆盖热点
4. **仪表盘自定义**：支持拖拽自定义仪表盘布局

### 9.3 集成扩展

1. **CI/CD 集成**：集成 CI/CD 流水线测试结果
2. **缺陷管理系统集成**：对接 JIRA、禅道等缺陷系统
3. **测试工具集成**：对接 Postman、JMeter 等测试工具

---

## 10. 附录

### 10.1 术语表

| 术语 | 说明 |
|------|------|
| Test Report | 测试报告，记录测试执行结果的文档 |
| Pass Rate | 通过率，通过的测试用例占总用例的百分比 |
| Defect | 缺陷，测试中发现的问题或错误 |
| AI Efficiency | AI效能，评估AI辅助测试的效果指标 |
| Adoption Rate | 采纳率，AI生成的用例被实际使用的比例 |
| Requirement Coverage | 需求覆盖率，已覆盖需求的用例占总需求的百分比 |

### 10.2 图表类型说明

| 图表类型 | 适用场景 | 说明 |
|---------|---------|------|
| 饼图 | 占比分析 | 展示各部分占总体的比例 |
| 折线图 | 趋势分析 | 展示数据随时间变化的趋势 |
| 柱状图 | 对比分析 | 展示不同类别数据的对比 |
| 堆叠柱状图 | 构成分析 | 展示整体和各部分的变化 |
| 环形图 | 占比分析 | 与饼图类似，中间可显示汇总数据 |

### 10.3 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
