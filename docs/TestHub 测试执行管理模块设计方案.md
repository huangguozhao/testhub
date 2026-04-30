# TestHub 测试执行管理模块设计方案

## 文档概述

测试执行管理模块是 TestHub 平台的核心功能模块之一，负责测试计划和测试执行的全生命周期管理。该模块的核心目标是：

1. 测试计划管理：支持创建、编辑、删除测试计划，关联项目和版本
2. 自动化执行创建：创建测试计划时自动生成对应的测试执行
3. 执行进度追踪：实时统计执行进度，支持多种状态筛选
4. 执行状态更新：记录每个用例的执行状态和结果
5. 历史追溯：记录每次状态变更，支持审计和回溯

------

## 一、功能需求

### 1.1 功能列表

| 功能点 | 优先级 | 描述 |
| :--- | :----- | :--- |
| 测试计划列表 | P0 | 分页查看测试计划，支持筛选和排序 |
| 创建测试计划 | P0 | 创建测试计划，自动生成测试执行和用例关联 |
| 测试计划详情 | P0 | 查看测试计划详情，包括关联的执行 |
| 编辑测试计划 | P0 | 修改测试计划的基本信息和关联 |
| 删除测试计划 | P0 | 删除测试计划（级联删除相关数据） |
| 测试执行列表 | P0 | 分页查看测试执行 |
| 测试执行详情 | P0 | 查看执行详情，包括用例列表和进度 |
| 更新执行状态 | P0 | 更新单个用例的执行状态 |
| 执行历史查询 | P1 | 查看用例的执行历史记录 |
| 批量更新状态 | P1 | 批量更新用例的执行状态 |
| 指派执行人 | P2 | 为测试计划或执行指派负责人 |

### 1.2 测试执行状态枚举

| 值 | 描述 | 说明 |
| :--- | :--- | :--- |
| untested | 未测试 | 用例尚未执行 |
| passed | 通过 | 用例执行通过 |
| failed | 失败 | 用例执行失败 |
| blocked | 阻塞 | 用例执行被阻塞 |
| retest | 重测 | 用例需要重新测试 |

### 1.3 测试执行运行状态枚举

| 值 | 描述 | 说明 |
| :--- | :--- | :--- |
| untested | 未测试 | 尚未开始执行 |
| in_progress | 进行中 | 执行正在进行 |
| completed | 已完成 | 全部用例已执行 |
| blocked | 阻塞 | 执行被阻塞 |

### 1.4 用例优先级枚举

| 值 | 描述 | 说明 |
| :--- | :--- | :--- |
| low | 低 | 低优先级用例 |
| medium | 中 | 中优先级用例 |
| high | 高 | 高优先级用例 |
| critical | 紧急 | 紧急优先级用例 |

------

## 二、数据模型

### 2.1 测试计划模型 (TestPlan)

```python
class TestPlan(models.Model):
    """测试计划"""
    name = models.CharField(max_length=200, verbose_name='计划名称')
    description = models.TextField(blank=True, verbose_name='计划描述')
    projects = models.ManyToManyField(Project, blank=True, related_name='test_plans', verbose_name='关联项目')
    version = models.ForeignKey(Version, on_delete=models.CASCADE, null=True, blank=True, related_name='test_plans', verbose_name='关联版本')
    creator = models.ForeignKey(User, on_delete=models.CASCADE, related_name='created_plans', verbose_name='创建者')
    assignees = models.ManyToManyField(User, blank=True, related_name='assigned_plans', verbose_name='指派给')
    is_active = models.BooleanField(default=True, verbose_name='是否激活')
    created_at = models.DateTimeField(default=timezone.now, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
```

### 2.2 测试执行模型 (TestRun)

```python
class TestRun(models.Model):
    """测试执行"""
    STATUS_CHOICES = [
        ('untested', '未测试'),
        ('in_progress', '进行中'),
        ('completed', '已完成'),
        ('blocked', '阻塞'),
    ]
    
    name = models.CharField(max_length=200, verbose_name='执行名称')
    description = models.TextField(blank=True, verbose_name='执行描述')
    test_plan = models.ForeignKey(TestPlan, on_delete=models.CASCADE, related_name='test_runs', verbose_name='测试计划')
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='test_runs', verbose_name='关联项目')
    version = models.ForeignKey(Version, on_delete=models.CASCADE, null=True, blank=True, related_name='test_runs', verbose_name='关联版本')
    testcases = models.ManyToManyField(TestCase, through='TestRunCase', related_name='test_runs', verbose_name='测试用例')
    assignee = models.ForeignKey(User, on_delete=models.CASCADE, related_name='assigned_runs', verbose_name='执行人')
    creator = models.ForeignKey(User, on_delete=models.CASCADE, related_name='created_runs', verbose_name='创建者')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='untested', verbose_name='状态')
    started_at = models.DateTimeField(null=True, blank=True, verbose_name='开始时间')
    completed_at = models.DateTimeField(null=True, blank=True, verbose_name='完成时间')
    due_date = models.DateTimeField(null=True, blank=True, verbose_name='截止日期')
    created_at = models.DateTimeField(default=timezone.now, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    
    @property
    def progress_stats(self):
        """执行进度统计"""
        total = self.run_cases.count()
        if total == 0:
            return {'total': 0, 'untested': 0, 'passed': 0, 'failed': 0, 
                    'blocked': 0, 'retest': 0, 'progress': 0}
        
        stats = {
            'total': total,
            'untested': self.run_cases.filter(status='untested').count(),
            'passed': self.run_cases.filter(status='passed').count(),
            'failed': self.run_cases.filter(status='failed').count(),
            'blocked': self.run_cases.filter(status='blocked').count(),
            'retest': self.run_cases.filter(status='retest').count(),
        }
        stats['tested'] = stats['passed'] + stats['failed'] + stats['blocked'] + stats['retest']
        stats['progress'] = round((stats['tested'] / total) * 100, 1) if total > 0 else 0
        return stats
```

### 2.3 测试执行用例模型 (TestRunCase)

```python
class TestRunCase(models.Model):
    """测试执行用例"""
    STATUS_CHOICES = [
        ('untested', '未测试'),
        ('passed', '通过'),
        ('failed', '失败'),
        ('blocked', '阻塞'),
        ('retest', '重测'),
    ]
    
    PRIORITY_CHOICES = [
        ('low', '低'),
        ('medium', '中'),
        ('high', '高'),
        ('critical', '紧急'),
    ]
    
    test_run = models.ForeignKey(TestRun, on_delete=models.CASCADE, related_name='run_cases', verbose_name='测试执行')
    testcase = models.ForeignKey(TestCase, on_delete=models.CASCADE, verbose_name='测试用例')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='untested', verbose_name='执行状态')
    priority = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default='medium', verbose_name='优先级')
    actual_result = models.TextField(blank=True, verbose_name='实际结果')
    comments = models.TextField(blank=True, verbose_name='备注')
    defects = models.JSONField(default=list, verbose_name='关联缺陷')  # 存储缺陷ID列表
    elapsed_time = models.DurationField(null=True, blank=True, verbose_name='执行耗时')
    executed_by = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True, verbose_name='执行者')
    executed_at = models.DateTimeField(null=True, blank=True, verbose_name='执行时间')
    created_at = models.DateTimeField(default=timezone.now, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    
    class Meta:
        unique_together = ['test_run', 'testcase']  # 确保同一执行中同一用例不重复
```

### 2.4 测试执行历史模型 (TestRunCaseHistory)

```python
class TestRunCaseHistory(models.Model):
    """测试执行历史"""
    run_case = models.ForeignKey(TestRunCase, on_delete=models.CASCADE, related_name='history', verbose_name='执行用例')
    status = models.CharField(max_length=20, choices=TestRunCase.STATUS_CHOICES, verbose_name='执行状态')
    actual_result = models.TextField(blank=True, verbose_name='实际结果')
    comments = models.TextField(blank=True, verbose_name='备注')
    executed_by = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name='执行者')
    executed_at = models.DateTimeField(default=timezone.now, verbose_name='执行时间')
```

### 2.5 数据模型关系图

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                           测试执行数据模型关系                                │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌────────────────────────────────────────────────────────────────────────┐

    │                           用户 (User)                                   │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
              ┌──────────────────────────┼──────────────────────────┐
              │                          │                          │
              ▼                          ▼                          ▼
    ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
    │   creator       │      │   assignee     │      │  executed_by   │
    │  (创建者)       │      │  (执行人)      │      │  (执行者)      │
    └─────────────────┘      └─────────────────┘      └─────────────────┘
              │                          │                          │
              └──────────────────────────┼──────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                          TestPlan (测试计划)                           │

    │                                                                        │
    │  - name          : 计划名称                                            │
    │  - description   : 计划描述                                            │
    │  - is_active     : 是否激活                                            │
    │                                                                        │
    └────────────────────────────────────────────────────────────────────────┘
                     │
                     │ 1:N (级联删除)
                     ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                          TestRun (测试执行)                            │

    │                                                                        │
    │  - name          : 执行名称                                            │
    │  - status        : 执行状态 (untested/in_progress/completed/blocked)   │
    │  - started_at    : 开始时间                                            │
    │  - completed_at  : 完成时间                                            │
    │  - due_date      : 截止日期                                            │
    │  - progress_stats: 进度统计 (属性方法)                                  │
    │                                                                        │
    └────────────────────────────────────────────────────────────────────────┘
                     │
                     │ 1:N (级联删除)
                     ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                        TestRunCase (执行用例)                          │

    │                                                                        │
    │  - status        : 执行状态 (untested/passed/failed/blocked/retest)    │
    │  - priority      : 优先级                                              │
    │  - actual_result : 实际结果                                            │
    │  - comments      : 备注                                                │
    │  - defects       : 关联缺陷 (JSON数组)                                 │
    │  - elapsed_time  : 执行耗时                                            │
    │  - executed_by   : 执行者                                              │
    │  - executed_at   : 执行时间                                            │
    │                                                                        │
    └────────────────────────────────────────────────────────────────────────┘
                     │
                     │ 1:N (级联删除)
                     ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                     TestRunCaseHistory (执行历史)                       │

    │                                                                        │
    │  - status        : 状态快照                                            │
    │  - actual_result : 实际结果快照                                        │
    │  - comments      : 备注快照                                            │
    │  - executed_by   : 执行者                                              │
    │  - executed_at   : 执行时间                                            │
    │                                                                        │
    └────────────────────────────────────────────────────────────────────────┘


    ┌────────────────────────────────────────────────────────────────────────┐

    │                           关联关系                                      │

    └────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐                      ┌─────────────────┐
    │   Project       │                      │    Version      │
    │    (项目)       │                      │    (版本)       │
    └────────┬────────┘                      └────────┬────────┘
             │                                        │
             │                                        │
             ▼                                        ▼
    ┌─────────────────┐                      ┌─────────────────┐
    │   projects      │                      │    version      │
    │ (TestPlan M2M) │                      │  (FK)          │
    └─────────────────┘                      └─────────────────┘
             │                                        │
             └──────────────────┬───────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   TestCase      │
                       │  (测试用例)     │
                       └────────┬────────┘
                                │
                                │ Through: TestRunCase
                                ▼
                       ┌─────────────────┐
                       │    TestRun      │
                       │  (测试执行)     │
                       └─────────────────┘
```

### 2.6 数据模型层级结构

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                          数据模型层级结构                                    │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌────────────────────────────────────────────────────────────────────────┐

    │                          Level 1: 测试计划                               │

    │  TestPlan                                                              │

    │  - 包含多个项目 (ManyToMany)                                           │

    │  - 关联一个版本 (ForeignKey)                                            │

    │  - 包含多个测试执行 (1:N)                                              │

    │  - 由创建者创建 (ForeignKey)                                           │

    │  - 可指派多人 (ManyToMany)                                              │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                          Level 2: 测试执行                               │

    │  TestRun                                                              │

    │  - 属于一个测试计划 (ForeignKey)                                        │

    │  - 属于一个项目 (ForeignKey)                                            │

    │  - 关联一个版本 (ForeignKey)                                            │

    │  - 包含多个执行用例 (ManyToMany through TestRunCase)                     │

    │  - 由创建者创建 (ForeignKey)                                            │

    │  - 由执行人负责 (ForeignKey)                                            │

    │  - 记录执行状态 (status)                                                │

    │  - 记录执行时间 (started_at, completed_at, due_date)                     │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                        Level 3: 执行用例                                 │

    │  TestRunCase                                                          │

    │  - 属于一个测试执行 (ForeignKey)                                        │

    │  - 关联一个测试用例 (ForeignKey)                                         │

    │  - 记录执行状态 (status)                                                │

    │  - 记录优先级 (priority)                                                │

    │  - 记录实际结果 (actual_result)                                          │

    │  - 记录备注 (comments)                                                  │

    │  - 关联缺陷列表 (defects - JSON)                                        │

    │  - 记录执行耗时 (elapsed_time)                                          │

    │  - 记录执行者信息 (executed_by, executed_at)                             │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                        Level 4: 执行历史                                 │

    │  TestRunCaseHistory                                                    │

    │  - 属于一个执行用例 (ForeignKey)                                        │

    │  - 记录状态快照 (status)                                                │

    │  - 记录结果快照 (actual_result)                                          │

    │  - 记录备注快照 (comments)                                               │

    │  - 记录执行者 (executed_by)                                              │

    │  - 记录执行时间 (executed_at)                                            │

    └────────────────────────────────────────────────────────────────────────┘
```

------

## 三、关键流程

### 3.1 创建测试计划流程

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                           创建测试计划流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │  填写计划信息  │
    │ 名称/描述/   │
    │ 项目/用例   │
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ 前端表单验证  │ ──► 计划名称非空、项目必选
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ 发送创建请求 │
    │ POST /plans/
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         后端处理                                        │

    │                                                                        │

    │  1. 创建 TestPlan 记录，设置 creator                                   │

    │  2. 设置 projects 关联 (projects.set(project_ids))                     │

    │  3. 设置 version 关联 (如果提供)                                       │

    │                                                                        │

    │  4. 遍历每个项目，创建 TestRun:                                        │

    │     for project_id in project_ids:                                     │

    │         TestRun.objects.create(                                        │

    │             name=f"{plan.name} - {project.name} Execution",            │

    │             test_plan=test_plan,                                       │

    │             project=project,                                           │

    │             version=plan.version,                                       │

    │             creator=creator,                                            │

    │             assignee=creator                                            │

    │         )                                                              │

    │                                                                        │

    │  5. 为每个 TestRun 关联测试用例:                                       │

    │     for case_id in testcase_ids:                                       │

    │         TestRunCase.objects.create(                                    │

    │             test_run=test_run,                                          │

    │             testcase=testcase                                          │

    │         )                                                              │

    │                                                                        │

    │  6. 使用 bulk_create 优化批量创建                                      │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐
    │ 返回计划详情 │
    │ 201 Created │
    └─────────────┘
```

### 3.2 执行状态更新流程

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                          执行状态更新流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │ 执行用例    │
    │ 选择状态    │
    │ 填写结果    │
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ 发送更新请求 │
    │ PATCH      │
    │ /run_cases/{id}/ │
    │ /update_status/ │
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         后端处理                                        │

    │                                                                        │

    │  1. 获取请求参数:                                                       │

    │     - status: 新状态                                                   │

    │     - actual_result: 实际结果                                         │

    │     - comments: 备注                                                   │

    │                                                                        │

    │  2. 创建历史记录 TestRunCaseHistory:                                   │

    │     TestRunCaseHistory.objects.create(                                 │

    │         run_case=run_case,                                             │

    │         status=new_status,                                             │

    │         actual_result=actual_result,                                   │

    │         comments=comments,                                             │

    │         executed_by=request.user,                                      │

    │         executed_at=timezone.now()                                      │

    │     )                                                                  │

    │                                                                        │

    │  3. 更新执行用例状态:                                                   │

    │     run_case.status = new_status                                      │

    │     run_case.actual_result = actual_result                            │

    │     run_case.comments = comments                                       │

    │     run_case.executed_by = request.user                               │

    │     run_case.executed_at = timezone.now()                              │

    │     run_case.save()                                                   │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐
    │ 返回更新结果 │
    │ 200 OK     │
    │ 包含历史记录 │
    └─────────────┘
```

### 3.3 进度统计流程

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                            进度统计流程                                      │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │ 访问执行详情 │
    │ GET /runs/{id}/
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                    TestRun.progress_stats 属性                          │

    │                                                                        │

    │  total = self.run_cases.count()                                       │

    │                                                                        │

    │  stats = {                                                             │

    │      'total': total,                                                  │

    │      'untested': run_cases.filter(status='untested').count(),          │

    │      'passed': run_cases.filter(status='passed').count(),              │

    │      'failed': run_cases.filter(status='failed').count(),              │

    │      'blocked': run_cases.filter(status='blocked').count(),             │

    │      'retest': run_cases.filter(status='retest').count(),              │

    │  }                                                                    │

    │                                                                        │

    │  stats['tested'] = passed + failed + blocked + retest                  │

    │                                                                        │

    │  stats['progress'] = round((tested / total) * 100, 1)                 │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         返回进度统计                                     │

    │                                                                        │

    │  {                                                                     │

    │      "total": 100,          // 总用例数                                │

    │      "untested": 30,         // 未测试                                  │

    │      "passed": 50,           // 通过                                    │

    │      "failed": 15,          // 失败                                    │

    │      "blocked": 2,          // 阻塞                                    │

    │      "retest": 3,           // 重测                                    │

    │      "tested": 70,          // 已测试 (passed+failed+blocked+retest)  │

    │      "progress": 70.0        // 进度百分比                              │

    │  }                                                                     │

    └────────────────────────────────────────────────────────────────────────┘
```

### 3.4 获取项目测试用例流程

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                      获取项目测试用例流程                                    │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │ 用户选择项目 │
    │ (多选)     │
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ 发送请求    │
    │ GET /plans/ │
    │ testcases_by_projects/ │
    │ ?project_ids=1&project_ids=2 │
    └──────┬──────┘
           │
           ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                         后端处理                                        │

    │                                                                        │

    │  1. 解析 project_ids 参数列表                                          │

    │                                                                        │

    │  2. 查询测试用例:                                                      │

    │     testcases = TestCase.objects.filter(                              │

    │         project_id__in=project_ids,                                    │

    │         status__in=['draft', 'active']  // 包含草稿和激活状态          │

    │     ).values('id', 'title', 'priority', 'test_type', 'project__name') │

    │                                                                        │

    │  3. 返回用例列表                                                       │

    └────────────────────────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐
    │ 返回用例列表 │
    │ 200 OK     │
    └─────────────┘
```

------

## 四、接口设计

### 4.1 测试计划列表接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/executions/plans/` |
| Method | `GET` |
| 认证 | 需要认证 |

**Query Parameters**

| 参数 | 类型 | 描述 |
| :--- | :--- | :--- |
| page | int | 页码 (默认 1) |
| page_size | int | 每页数量 |
| search | string | 搜索关键词 (可选) |
| is_active | boolean | 是否激活 (可选) |

**Success Response (200 OK)**

```json
{
  "count": 10,
  "next": "http://api.example.com/executions/plans/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "V1.0 回归测试计划",
      "projects": ["电商平台测试"],
      "version": "V1.0",
      "creator": {
        "id": 1,
        "username": "zhangsan"
      },
      "created_at": "2026-04-01T10:00:00Z",
      "is_active": true
    }
  ]
}
```

### 4.2 创建测试计划接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/executions/plans/` |
| Method | `POST` |
| 认证 | 需要认证 |

**Request Body**

```json
{
  "name": "V1.0 回归测试计划",
  "description": "针对 V1.0 版本的回归测试",
  "projects": [1, 2],
  "version": 1,
  "testcases": [1, 2, 3, 4, 5],
  "assignees": [1, 2]
}
```

| 字段 | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| name | string | 是 | 计划名称 (最大200字符) |
| description | string | 否 | 计划描述 |
| projects | array | 是 | 项目ID列表 |
| version | int | 否 | 版本ID |
| testcases | array | 否 | 测试用例ID列表 |
| assignees | array | 否 | 指派人ID列表 |

**Success Response (201 Created)**

```json
{
  "id": 1,
  "name": "V1.0 回归测试计划",
  "description": "针对 V1.0 版本的回归测试",
  "projects": [
    {"id": 1, "name": "电商平台测试"},
    {"id": 2, "name": "支付系统测试"}
  ],
  "version": {"id": 1, "name": "V1.0"},
  "creator": {
    "id": 1,
    "username": "zhangsan"
  },
  "assignees": [
    {"id": 1, "username": "zhangsan"},
    {"id": 2, "username": "lisi"}
  ],
  "is_active": true,
  "test_runs": [
    {
      "id": 1,
      "name": "V1.0 回归测试计划 - 电商平台测试 Execution",
      "status": "untested",
      "assignee": {"id": 1, "username": "zhangsan"},
      "progress": {
        "total": 5,
        "untested": 5,
        "passed": 0,
        "failed": 0,
        "blocked": 0,
        "retest": 0,
        "tested": 0,
        "progress": 0
      },
      "run_cases": [
        {"id": 1, "testcase": "TestCase object (1)", "status": "untested"}
      ]
    }
  ],
  "created_at": "2026-04-10T10:00:00Z",
  "updated_at": "2026-04-10T10:00:00Z"
}
```

### 4.3 测试计划详情接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/executions/plans/<id>/` |
| Method | `GET` |
| 认证 | 需要认证 |

**Success Response (200 OK)**

```json
{
  "id": 1,
  "name": "V1.0 回归测试计划",
  "description": "针对 V1.0 版本的回归测试",
  "projects": [
    {"id": 1, "name": "电商平台测试"},
    {"id": 2, "name": "支付系统测试"}
  ],
  "version": {"id": 1, "name": "V1.0"},
  "creator": {
    "id": 1,
    "username": "zhangsan"
  },
  "assignees": [
    {"id": 1, "username": "zhangsan"},
    {"id": 2, "username": "lisi"}
  ],
  "is_active": true,
  "created_at": "2026-04-10T10:00:00Z",
  "updated_at": "2026-04-10T10:00:00Z",
  "test_runs": [
    {
      "id": 1,
      "name": "V1.0 回归测试计划 - 电商平台测试 Execution",
      "status": "in_progress",
      "assignee": {"id": 1, "username": "zhangsan"},
      "progress": {
        "total": 5,
        "untested": 2,
        "passed": 2,
        "failed": 1,
        "blocked": 0,
        "retest": 0,
        "tested": 3,
        "progress": 60.0
      },
      "run_cases": [
        {"id": 1, "testcase": "用户登录测试", "status": "passed"},
        {"id": 2, "testcase": "商品搜索测试", "status": "passed"},
        {"id": 3, "testcase": "购物车测试", "status": "failed"},
        {"id": 4, "testcase": "订单提交测试", "status": "untested"},
        {"id": 5, "testcase": "支付流程测试", "status": "untested"}
      ]
    },
    {
      "id": 2,
      "name": "V1.0 回归测试计划 - 支付系统测试 Execution",
      "status": "untested",
      "assignee": {"id": 2, "username": "lisi"},
      "progress": {
        "total": 3,
        "untested": 3,
        "passed": 0,
        "failed": 0,
        "blocked": 0,
        "retest": 0,
        "tested": 0,
        "progress": 0
      },
      "run_cases": [
        {"id": 6, "testcase": "支付宝支付测试", "status": "untested"},
        {"id": 7, "testcase": "微信支付测试", "status": "untested"},
        {"id": 8, "testcase": "银联支付测试", "status": "untested"}
      ]
    }
  ]
}
```

### 4.4 测试执行列表接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/executions/runs/` |
| Method | `GET` |
| 认证 | 需要认证 |

**Query Parameters**

| 参数 | 类型 | 描述 |
| :--- | :--- | :--- |
| page | int | 页码 (默认 1) |
| status | string | 执行状态筛选 (可选) |
| project | int | 项目ID筛选 (可选) |

**Success Response (200 OK)**

```json
{
  "count": 5,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "V1.0 回归测试计划 - 电商平台测试 Execution",
      "status": "in_progress",
      "assignee": 1,
      "progress": {
        "total": 5,
        "untested": 2,
        "passed": 2,
        "failed": 1,
        "blocked": 0,
        "retest": 0,
        "tested": 3,
        "progress": 60.0
      },
      "run_cases": [
        {"id": 1, "testcase": "TestCase object (1)", "status": "passed"},
        {"id": 2, "testcase": "TestCase object (2)", "status": "passed"},
        {"id": 3, "testcase": "TestCase object (3)", "status": "failed"},
        {"id": 4, "testcase": "TestCase object (4)", "status": "untested"},
        {"id": 5, "testcase": "TestCase object (5)", "status": "untested"}
      ]
    }
  ]
}
```

### 4.5 测试执行详情接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/executions/runs/<id>/` |
| Method | `GET` |
| 认证 | 需要认证 |

**Success Response (200 OK)**

```json
{
  "id": 1,
  "name": "V1.0 回归测试计划 - 电商平台测试 Execution",
  "description": "",
  "test_plan": 1,
  "project": 1,
  "version": 1,
  "assignee": 1,
  "creator": 1,
  "status": "in_progress",
  "started_at": "2026-04-10T10:00:00Z",
  "completed_at": null,
  "due_date": "2026-04-15T18:00:00Z",
  "created_at": "2026-04-10T10:00:00Z",
  "updated_at": "2026-04-10T14:00:00Z"
}
```

### 4.6 更新执行状态接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/executions/run_cases/<id>/update_status/` |
| Method | `PATCH` |
| 认证 | 需要认证 |

**Request Body**

```json
{
  "status": "passed",
  "actual_result": "登录成功，页面正常跳转",
  "comments": "在 Chrome 浏览器下测试通过"
}
```

| 字段 | 类型 | 必填 | 描述 |
| :--- | :--- | :--- | :--- |
| status | string | 是 | 执行状态 |
| actual_result | string | 否 | 实际结果 |
| comments | string | 否 | 备注 |

**Success Response (200 OK)**

```json
{
  "id": 1,
  "testcase": "TestCase object (1)",
  "status": "passed",
  "priority": "high",
  "actual_result": "登录成功，页面正常跳转",
  "comments": "在 Chrome 浏览器下测试通过",
  "defects": [],
  "elapsed_time": null,
  "executed_by": {
    "id": 1,
    "username": "zhangsan"
  },
  "executed_at": "2026-04-10T14:00:00Z",
  "created_at": "2026-04-10T10:00:00Z",
  "updated_at": "2026-04-10T14:00:00Z",
  "history": [
    {
      "id": 1,
      "status": "untested",
      "actual_result": "",
      "comments": "",
      "executed_by": {
        "id": 1,
        "username": "zhangsan"
      },
      "executed_at": "2026-04-10T10:00:00Z"
    },
    {
      "id": 2,
      "status": "passed",
      "actual_result": "登录成功，页面正常跳转",
      "comments": "在 Chrome 浏览器下测试通过",
      "executed_by": {
        "id": 1,
        "username": "zhangsan"
      },
      "executed_at": "2026-04-10T14:00:00Z"
    }
  ]
}
```

### 4.7 执行历史查询接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/executions/run_cases/<id>/history/` |
| Method | `GET` |
| 认证 | 需要认证 |

**Success Response (200 OK)**

```json
[
  {
    "id": 1,
    "status": "untested",
    "actual_result": "",
    "comments": "",
    "executed_by": {
      "id": 1,
      "username": "zhangsan"
    },
    "executed_at": "2026-04-10T10:00:00Z"
  },
  {
    "id": 2,
    "status": "failed",
    "actual_result": "页面报错 500",
    "comments": "密码为空时返回服务器错误",
    "executed_by": {
      "id": 1,
      "username": "zhangsan"
    },
    "executed_at": "2026-04-10T12:00:00Z"
  },
  {
    "id": 3,
    "status": "passed",
    "actual_result": "登录成功",
    "comments": "修复后重新测试通过",
    "executed_by": {
      "id": 2,
      "username": "lisi"
    },
    "executed_at": "2026-04-10T14:00:00Z"
  }
]
```

### 4.8 获取项目测试用例接口

**基本信息**

| 属性 | 值 |
| :--- | :--- |
| URL | `/api/executions/plans/testcases_by_projects/` |
| Method | `GET` |
| 认证 | 需要认证 |

**Query Parameters**

| 参数 | 类型 | 描述 |
| :--- | :--- | :--- |
| project_ids | array | 项目ID列表 (必填) |

**Success Response (200 OK)**

```json
{
  "results": [
    {
      "id": 1,
      "title": "用户登录测试",
      "priority": "high",
      "test_type": "functional",
      "project__name": "电商平台测试"
    },
    {
      "id": 2,
      "title": "商品搜索测试",
      "priority": "medium",
      "test_type": "functional",
      "project__name": "电商平台测试"
    }
  ]
}
```

**Error Response (400 Bad Request)**

```json
{
  "error": "请先选择项目",
  "detail": "请先选择项目后再选择测试用例"
}
```

------

## 五、数据库设计

### 5.1 测试计划表 (test_plans)

```sql
CREATE TABLE `test_plans` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '计划唯一标识',
  `name` VARCHAR(200) NOT NULL COMMENT '计划名称',
  `description` TEXT COMMENT '计划描述',
  `version_id` BIGINT COMMENT '关联版本ID',
  `creator_id` BIGINT NOT NULL COMMENT '创建者ID',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否激活',
  `created_at` DATETIME NOT NULL COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL COMMENT '更新时间',

  INDEX `idx_creator` (`creator_id`),
  INDEX `idx_version` (`version_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_created_at` (`created_at`),
  FOREIGN KEY (`version_id`) REFERENCES `versions` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`creator_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试计划表';

-- 中间表：测试计划-项目关联
CREATE TABLE `test_plans_projects` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
  `testplan_id` BIGINT NOT NULL COMMENT '测试计划ID',
  `project_id` BIGINT NOT NULL COMMENT '项目ID',

  UNIQUE KEY `uk_plan_project` (`testplan_id`, `project_id`),
  INDEX `idx_plan` (`testplan_id`),
  INDEX `idx_project` (`project_id`),
  FOREIGN KEY (`testplan_id`) REFERENCES `test_plans` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试计划-项目关联表';

-- 中间表：测试计划-指派人关联
CREATE TABLE `test_plans_assignees` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
  `testplan_id` BIGINT NOT NULL COMMENT '测试计划ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',

  UNIQUE KEY `uk_plan_assignee` (`testplan_id`, `user_id`),
  INDEX `idx_plan` (`testplan_id`),
  INDEX `idx_user` (`user_id`),
  FOREIGN KEY (`testplan_id`) REFERENCES `test_plans` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试计划-指派人关联表';
```

### 5.2 测试执行表 (test_runs)

```sql
CREATE TABLE `test_runs` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行唯一标识',
  `name` VARCHAR(200) NOT NULL COMMENT '执行名称',
  `description` TEXT COMMENT '执行描述',
  `test_plan_id` BIGINT NOT NULL COMMENT '测试计划ID',
  `project_id` BIGINT NOT NULL COMMENT '项目ID',
  `version_id` BIGINT COMMENT '关联版本ID',
  `assignee_id` BIGINT NOT NULL COMMENT '执行人ID',
  `creator_id` BIGINT NOT NULL COMMENT '创建者ID',
  `status` VARCHAR(20) NOT NULL DEFAULT 'untested' COMMENT '状态',
  `started_at` DATETIME COMMENT '开始时间',
  `completed_at` DATETIME COMMENT '完成时间',
  `due_date` DATETIME COMMENT '截止日期',
  `created_at` DATETIME NOT NULL COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL COMMENT '更新时间',

  INDEX `idx_test_plan` (`test_plan_id`),
  INDEX `idx_project` (`project_id`),
  INDEX `idx_version` (`version_id`),
  INDEX `idx_assignee` (`assignee_id`),
  INDEX `idx_creator` (`creator_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`),
  FOREIGN KEY (`test_plan_id`) REFERENCES `test_plans` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`version_id`) REFERENCES `versions` (`id`) ON DELETE SET NULL,
  FOREIGN KEY (`assignee_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`creator_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试执行表';

-- 中间表：测试执行-测试用例关联
CREATE TABLE `test_runs_testcases` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
  `testrun_id` BIGINT NOT NULL COMMENT '测试执行ID',
  `testcase_id` BIGINT NOT NULL COMMENT '测试用例ID',

  UNIQUE KEY `uk_run_case` (`testrun_id`, `testcase_id`),
  INDEX `idx_run` (`testrun_id`),
  INDEX `idx_case` (`testcase_id`),
  FOREIGN KEY (`testrun_id`) REFERENCES `test_runs` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试执行-测试用例关联表';
```

### 5.3 测试执行用例表 (test_run_cases)

```sql
CREATE TABLE `test_run_cases` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行用例唯一标识',
  `test_run_id` BIGINT NOT NULL COMMENT '测试执行ID',
  `testcase_id` BIGINT NOT NULL COMMENT '测试用例ID',
  `status` VARCHAR(20) NOT NULL DEFAULT 'untested' COMMENT '执行状态',
  `priority` VARCHAR(20) NOT NULL DEFAULT 'medium' COMMENT '优先级',
  `actual_result` TEXT COMMENT '实际结果',
  `comments` TEXT COMMENT '备注',
  `defects` JSON COMMENT '关联缺陷列表',
  `elapsed_time` TIME COMMENT '执行耗时',
  `executed_by_id` BIGINT COMMENT '执行者ID',
  `executed_at` DATETIME COMMENT '执行时间',
  `created_at` DATETIME NOT NULL COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL COMMENT '更新时间',

  UNIQUE KEY `uk_run_case` (`test_run_id`, `testcase_id`),
  INDEX `idx_test_run` (`test_run_id`),
  INDEX `idx_testcase` (`testcase_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_executed_by` (`executed_by_id`),
  INDEX `idx_executed_at` (`executed_at`),
  FOREIGN KEY (`test_run_id`) REFERENCES `test_runs` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试执行用例表';
```

### 5.4 测试执行历史表 (test_run_case_history)

```sql
CREATE TABLE `test_run_case_history` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '历史唯一标识',
  `run_case_id` BIGINT NOT NULL COMMENT '执行用例ID',
  `status` VARCHAR(20) NOT NULL COMMENT '执行状态快照',
  `actual_result` TEXT COMMENT '实际结果快照',
  `comments` TEXT COMMENT '备注快照',
  `executed_by_id` BIGINT NOT NULL COMMENT '执行者ID',
  `executed_at` DATETIME NOT NULL COMMENT '执行时间',

  INDEX `idx_run_case` (`run_case_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_executed_by` (`executed_by_id`),
  INDEX `idx_executed_at` (`executed_at`),
  FOREIGN KEY (`run_case_id`) REFERENCES `test_run_cases` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='测试执行历史表';
```

------

## 六、序列化器设计

### 6.1 序列化器层次结构

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                          序列化器层次结构                                    │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌────────────────────────────────────────────────────────────────────────┐

    │                 TestPlanDetailSerializer (测试计划详情)                  │

    │                                                                        │

    │  用于: GET /plans/{id}/                                                │

    │                                                                        │

    │  嵌套序列化:                                                           │

    │    - creator: UserSimpleSerializer                                     │

    │    - projects: StringRelatedField (多对多)                             │

    │    - version: StringRelatedField                                       │

    │    - test_runs: TestRunSerializer[] (1:N)                              │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                   TestRunSerializer (测试执行)                          │

    │                                                                        │

    │  用于: GET /plans/{id}/ (嵌套) / GET /runs/{id}/                      │

    │                                                                        │

    │  字段:                                                                │

    │    - run_cases: TestRunCaseSimpleSerializer[]                          │

    │    - progress: SerializerMethodField (计算属性)                        │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                TestRunCaseDetailSerializer (执行用例详情)                │

    │                                                                        │

    │  用于: GET /run_cases/{id}/                                            │

    │                                                                        │

    │  嵌套序列化:                                                           │

    │    - testcase: StringRelatedField                                      │

    │    - executed_by: UserSimpleSerializer                                  │

    │    - history: TestRunCaseHistorySerializer[]                            │

    └────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
    ┌────────────────────────────────────────────────────────────────────────┐

    │                   TestRunCaseHistorySerializer                          │

    │                                                                        │

    │  用于: 历史记录列表                                                     │

    │                                                                        │

    │  字段:                                                                │

    │    - executed_by: UserSimpleSerializer                                 │

    │                                                                        │

    │  特点: 只读快照数据                                                     │

    └────────────────────────────────────────────────────────────────────────┘
```

### 6.2 序列化器详细设计

**TestPlanSerializer (列表视图)**

```python
class TestPlanSerializer(serializers.ModelSerializer):
    creator = UserSimpleSerializer(read_only=True)
    projects = serializers.StringRelatedField(many=True, read_only=True)
    version = serializers.StringRelatedField()
    
    class Meta:
        model = TestPlan
        fields = ('id', 'name', 'projects', 'version', 'creator', 'created_at', 'is_active')
```

**TestPlanDetailSerializer (详情视图)**

```python
class TestPlanDetailSerializer(serializers.ModelSerializer):
    test_runs = TestRunSerializer(many=True, read_only=True)
    creator = UserSimpleSerializer(read_only=True)
    projects = serializers.StringRelatedField(many=True, read_only=True)
    version = serializers.StringRelatedField()
    
    class Meta:
        model = TestPlan
        fields = '__all__'
```

**TestRunSerializer (测试执行)**

```python
class TestRunSerializer(serializers.ModelSerializer):
    run_cases = TestRunCaseSimpleSerializer(many=True, read_only=True)
    progress = serializers.SerializerMethodField()
    
    class Meta:
        model = TestRun
        fields = ('id', 'name', 'status', 'assignee', 'progress', 'run_cases')
    
    def get_progress(self, obj):
        return obj.progress_stats
```

**TestRunCaseDetailSerializer (执行用例详情)**

```python
class TestRunCaseDetailSerializer(serializers.ModelSerializer):
    testcase = serializers.StringRelatedField()
    executed_by = UserSimpleSerializer(read_only=True)
    history = TestRunCaseHistorySerializer(many=True, read_only=True)
    
    class Meta:
        model = TestRunCase
        fields = ('id', 'testcase', 'status', 'priority', 'actual_result', 
                 'comments', 'defects', 'elapsed_time', 'executed_by', 
                 'executed_at', 'created_at', 'updated_at', 'history')
```

**TestRunCaseHistorySerializer (执行历史)**

```python
class TestRunCaseHistorySerializer(serializers.ModelSerializer):
    executed_by = UserSimpleSerializer(read_only=True)
    
    class Meta:
        model = TestRunCaseHistory
        fields = ('id', 'status', 'actual_result', 'comments', 'executed_by', 'executed_at')
```

------

## 七、视图集设计

### 7.1 视图集概览

| ViewSet | 路由前缀 | 功能 | 自定义动作 |
| :--- | :--- | :--- | :--- |
| TestPlanViewSet | /plans/ | 测试计划 CRUD | testcases_by_projects |
| TestRunViewSet | /runs/ | 测试执行 CRUD | - |
| TestRunCaseViewSet | /run_cases/ | 执行用例 CRUD | update_status, history |
| TestRunCaseHistoryViewSet | /history/ | 历史记录只读 | - |

### 7.2 TestPlanViewSet 核心逻辑

**perform_create() - 创建测试计划时自动创建执行**

```python
def perform_create(self, serializer):
    # 1. 创建 TestPlan
    test_plan = serializer.save(creator=self.request.user, version=version)
    
    # 2. 设置项目关联
    test_plan.projects.set(project_ids)
    
    # 3. 为每个项目创建 TestRun
    for project_id in project_ids:
        test_run = TestRun.objects.create(
            name=f"{test_plan.name} - {project.name} Execution",
            test_plan=test_plan,
            project=project,
            version=test_plan.version,
            creator=test_plan.creator,
            assignee=test_plan.creator
        )
        
        # 4. 为 TestRun 关联测试用例
        if testcase_ids:
            test_run_cases = []
            for case_id in testcase_ids:
                testcase = TestCase.objects.get(id=case_id)
                test_run_cases.append(
                    TestRunCase(test_run=test_run, testcase=testcase)
                )
            TestRunCase.objects.bulk_create(test_run_cases)
            test_run.testcases.set(testcase_ids)
```

### 7.3 TestRunCaseViewSet 核心逻辑

**update_status() - 更新执行状态并记录历史**

```python
@action(detail=True, methods=['patch'])
def update_status(self, request, pk=None):
    run_case = self.get_object()
    new_status = request.data.get('status')
    actual_result = request.data.get('actual_result', '')
    comments = request.data.get('comments', '')
    
    # 1. 创建历史记录
    TestRunCaseHistory.objects.create(
        run_case=run_case,
        status=new_status,
        actual_result=actual_result,
        comments=comments,
        executed_by=request.user,
        executed_at=timezone.now()
    )
    
    # 2. 更新执行用例
    run_case.status = new_status
    run_case.actual_result = actual_result
    run_case.comments = comments
    run_case.executed_by = request.user
    run_case.executed_at = timezone.now()
    run_case.save()
    
    return Response(TestRunCaseDetailSerializer(run_case).data)
```

### 7.4 testcases_by_projects 自定义动作

```python
@action(detail=False, methods=['get'])
def testcases_by_projects(self, request):
    project_ids = request.query_params.getlist('project_ids')
    
    # 查询指定项目的测试用例
    testcases = TestCase.objects.filter(
        project_id__in=project_ids,
        status__in=['draft', 'active']
    ).values('id', 'title', 'priority', 'test_type', 'project__name')
    
    return Response({'results': list(testcases)})
```

------

## 八、路由汇总

| URL | Method | 认证 | 描述 |
| :--- | :--- | :--- | :--- |
| `/api/executions/plans/` | GET | 是 | 测试计划列表 |
| `/api/executions/plans/` | POST | 是 | 创建测试计划 (自动创建执行) |
| `/api/executions/plans/<id>/` | GET | 是 | 测试计划详情 |
| `/api/executions/plans/<id>/` | PUT/PATCH | 是 | 更新测试计划 |
| `/api/executions/plans/<id>/` | DELETE | 是 | 删除测试计划 |
| `/api/executions/plans/testcases_by_projects/` | GET | 是 | 按项目获取用例 |
| `/api/executions/runs/` | GET | 是 | 测试执行列表 |
| `/api/executions/runs/` | POST | 是 | 创建测试执行 |
| `/api/executions/runs/<id>/` | GET | 是 | 测试执行详情 |
| `/api/executions/runs/<id>/` | PUT/PATCH | 是 | 更新测试执行 |
| `/api/executions/runs/<id>/` | DELETE | 是 | 删除测试执行 |
| `/api/executions/run_cases/` | GET | 是 | 执行用例列表 |
| `/api/executions/run_cases/` | POST | 是 | 创建执行用例 |
| `/api/executions/run_cases/<id>/` | GET | 是 | 执行用例详情 |
| `/api/executions/run_cases/<id>/` | PUT/PATCH | 是 | 更新执行用例 |
| `/api/executions/run_cases/<id>/` | DELETE | 是 | 删除执行用例 |
| `/api/executions/run_cases/<id>/update_status/` | PATCH | 是 | 更新执行状态 |
| `/api/executions/run_cases/<id>/history/` | GET | 是 | 获取执行历史 |
| `/api/executions/history/` | GET | 是 | 历史记录列表 (只读) |

------

## 九、与其他模块的关系

```
┌─────────────────────────────────────────────────────────────────────────────┐

│                       测试执行模块与其他模块的关系                            │

└─────────────────────────────────────────────────────────────────────────────┘

    ┌────────────────────────────────────────────────────────────────────────┐

    │                           核心模块依赖                                   │

    └────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
    │   Users     │      │  Projects   │      │  Versions   │
    │   (用户)    │◄─────│   (项目)    │◄─────│   (版本)    │
    └─────────────┘      └──────┬──────┘      └─────────────┘
                                │
                                │
                                ▼
                       ┌─────────────┐
                       │  TestCases  │
                       │ (测试用例)  │
                       └──────┬──────┘
                              │
                              │ Through: TestRunCase
                              ▼
                       ┌─────────────┐      ┌─────────────┐
                       │ Executions │      │   Reports   │
                       │  (执行)    │─────►│   (报告)    │
                       └─────────────┘      └─────────────┘

    ┌────────────────────────────────────────────────────────────────────────┐

    │                           数据流向                                      │

    └────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
    │ TestPlan    │────►│  TestRun   │────►│TestRunCase  │
    │             │     │            │     │             │
    │ - projects  │     │ - cases    │     │ - history   │
    │ - version   │     │ - version  │     │             │
    │ - testcases │     │            │     │             │
    └─────────────┘     └─────────────┘     └─────────────┘
         │                                       │
         │                                       │
         ▼                                       ▼
    ┌─────────────┐                       ┌─────────────┐
    │ TestCase    │◄──────────────────────│  User       │
    │             │                       │             │
    │ - steps     │                       │ - creator   │
    │ - expected  │                       │ - assignee  │
    └─────────────┘                       │ - executed_by│
                                          └─────────────┘
```

------

## 十、权限控制

### 10.1 权限检查机制

当前实现基于项目权限进行访问控制：

```python
# 获取用户有权限的项目
accessible_projects = Project.objects.filter(
    Q(owner=user) | Q(members=user)
).distinct()

# 查询属于这些项目的执行
TestRun.objects.filter(project__in=accessible_projects)
```

### 10.2 权限矩阵

| 操作 | Owner | Admin | Developer | Tester | Viewer |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 查看计划/执行 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 创建计划 | ✅ | ✅ | ✅ | ✅ | ❌ |
| 编辑计划 | ✅ | ✅ | ✅ | ✅ | ❌ |
| 删除计划 | ✅ | ❌ | ❌ | ❌ | ❌ |
| 更新执行状态 | ✅ | ✅ | ✅ | ✅ | ❌ |
| 查看执行历史 | ✅ | ✅ | ✅ | ✅ | ✅ |

### 10.3 建议的权限检查增强

```python
def check_execution_permission(user, test_run, action='read'):
    """检查用户对测试执行的权限"""
    project = test_run.project
    
    # 项目负责人拥有所有权限
    if project.owner == user:
        return True
    
    # 获取用户在项目中的角色
    try:
        member = ProjectMember.objects.get(project=project, user=user)
    except ProjectMember.DoesNotExist:
        return False
    
    # 根据操作和角色判断权限
    permission_map = {
        'read': ['owner', 'admin', 'developer', 'tester', 'viewer'],
        'update_status': ['owner', 'admin', 'developer', 'tester'],
        'delete': ['owner'],
    }
    
    return member.role in permission_map.get(action, [])
```

------

## 十一、性能优化

### 11.1 数据库查询优化

| 优化点 | 实现位置 | 说明 |
| :--- | :--- | :--- |
| select_related | 视图集 | 预加载 ForeignKey 关联 |
| prefetch_related | 视图集 | 预加载 ManyToMany 和反向关联 |
| bulk_create | perform_create | 批量创建执行用例 |
| 唯一约束 | Meta.unique_together | 防止重复创建 |

### 11.2 进度统计优化

当前 `progress_stats` 属性使用多次数据库查询，建议优化：

```python
# 当前实现 (N+1 查询问题)
@property
def progress_stats(self):
    total = self.run_cases.count()
    stats = {
        'total': total,
        'untested': self.run_cases.filter(status='untested').count(),
        'passed': self.run_cases.filter(status='passed').count(),
        # ... 更多查询
    }

# 优化建议: 使用聚合查询
from django.db.models import Count

@property
def progress_stats(self):
    from django.db.models import Count, Q
    aggregates = self.run_cases.aggregate(
        total=Count('id'),
        passed=Count('id', filter=Q(status='passed')),
        failed=Count('id', filter=Q(status='failed')),
        # ...
    )
```

### 11.3 索引优化

| 索引类型 | 字段 | 用途 |
| :--- | :--- | :--- |
| 普通索引 | test_run_id | 按执行筛选 |
| 普通索引 | status | 按状态筛选 |
| 普通索引 | executed_at | 按时间排序 |
| 唯一约束 | (test_run, testcase) | 防止重复 |

------

## 十二、后续扩展建议

### 12.1 功能扩展

1. **批量状态更新**：支持批量更新多个用例的执行状态
2. **执行报告生成**：基于执行结果生成测试报告
3. **缺陷关联**：与缺陷管理系统集成
4. **执行通知**：执行完成或失败时发送通知
5. **执行分配**：支持更灵活的用例分配策略
6. **定时执行**：支持定时自动执行测试计划

### 12.2 代码完善

1. **权限控制增强**：基于项目角色的细粒度权限控制
2. **性能优化**：进度统计使用聚合查询
3. **数据校验**：增强输入数据的校验逻辑
4. **单元测试**：编写完整的测试用例

### 12.3 性能优化

1. **缓存**：引入 Redis 缓存热门执行计划
2. **异步任务**：批量操作异步处理
3. **分页优化**：大结果集分页处理

------

文档版本：V1.0
编写日期：2026-04-10
基于项目：TestHub 智能测试管理平台
