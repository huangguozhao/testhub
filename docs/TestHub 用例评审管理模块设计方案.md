# TestHub 用例评审管理模块设计方案

## 1. 模块概述

用例评审管理模块是 TestHub 智能测试管理平台的核心功能之一，用于对测试用例进行系统化的评审流程管理。该模块支持创建评审任务、分配评审人员、填写检查清单、记录评审意见、跟踪评审进度等功能，确保测试用例的质量和规范性。

### 1.1 设计目标

- **规范化评审流程**：建立标准化的用例评审流程，保证评审的完整性和一致性
- **多方协同评审**：支持多人协同评审，汇总各方意见
- **透明化进度跟踪**：实时展示评审进度，提高团队协作效率
- **模板化管理**：通过评审模板实现评审内容的标准化
- **可追溯性**：完整记录评审过程和结果，支持后续查阅和审计

### 1.2 功能范围

| 功能模块 | 功能点 |
|---------|--------|
| 评审列表 | 评审查询、筛选、创建、编辑、删除 |
| 评审详情 | 评审信息查看、进度跟踪、评审意见、提交评审 |
| 评审模板 | 模板创建、编辑、删除、使用 |
| 检查清单 | 清单项配置、逐项评审、结果记录 |

---

## 2. 数据模型设计

### 2.1 模型关系图

```
TestCaseReview (评审主表)
    ├── projects (多对多 → Project)
    ├── testcases (多对多 → TestCase)
    ├── creator (外键 → User)
    ├── reviewers (多对多 → User, through=ReviewAssignment)
    ├── template (外键 → ReviewTemplate, 可为空)
    ├── ReviewAssignment (一对多)
    │       └── reviewer (外键 → User)
    └── TestCaseReviewComment (一对多)
            ├── author (外键 → User)
            └── testcase (外键 → TestCase, 可为空)

ReviewTemplate (评审模板)
    ├── project (多对多 → Project)
    ├── creator (外键 → User)
    └── default_reviewers (多对多 → User)
```

### 2.2 评审主表 (TestCaseReview)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 评审ID |
| title | CharField(500) | 必填 | 评审标题 |
| description | TextField | 可选 | 评审描述 |
| projects | ManyToManyField | 必填 | 关联项目 |
| testcases | ManyToManyField | 必填 | 评审用例 |
| creator | ForeignKey(User) | 必填 | 创建人 |
| template | ForeignKey(ReviewTemplate) | 可为空 | 使用的模板 |
| status | CharField(20) | 默认pending | 评审状态 |
| priority | CharField(20) | 默认medium | 优先级 |
| deadline | DateTimeField | 可为空 | 截止日期 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |
| completed_at | DateTimeField | 可为空 | 完成时间 |

**状态枚举 (status)**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| pending | 待评审 | 评审刚创建，尚未开始 |
| in_progress | 评审中 | 已有评审人开始评审 |
| approved | 已通过 | 所有评审人通过 |
| rejected | 已拒绝 | 有评审人拒绝 |
| cancelled | 已取消 | 评审被取消 |

**优先级枚举 (priority)**：

| 值 | 显示名称 |
|----|---------|
| low | 低 |
| medium | 中 |
| high | 高 |
| urgent | 紧急 |

### 2.3 评审分配表 (ReviewAssignment)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 分配ID |
| review | ForeignKey(TestCaseReview) | 必填 | 关联评审 |
| reviewer | ForeignKey(User) | 必填 | 评审人 |
| status | CharField(20) | 默认pending | 评审状态 |
| comment | TextField | 可选 | 评审意见 |
| checklist_results | JSONField | 默认{} | 检查清单结果 |
| reviewed_at | DateTimeField | 可为空 | 评审时间 |
| assigned_at | DateTimeField | 自动 | 分配时间 |

**唯一约束**：`[review, reviewer]`

**分配状态枚举 (status)**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| pending | 待评审 | 尚未完成评审 |
| approved | 已通过 | 评审通过 |
| rejected | 已拒绝 | 评审拒绝 |
| abstained | 弃权 | 评审人放弃评审 |

### 2.4 评审意见表 (TestCaseReviewComment)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 意见ID |
| review | ForeignKey(TestCaseReview) | 必填 | 关联评审 |
| testcase | ForeignKey(TestCase) | 可为空 | 相关用例 |
| author | ForeignKey(User) | 必填 | 评论者 |
| comment_type | CharField(20) | 默认general | 意见类型 |
| content | TextField | 必填 | 意见内容 |
| step_number | PositiveIntegerField | 可为空 | 步骤序号 |
| is_resolved | BooleanField | 默认False | 是否已解决 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

**意见类型枚举 (comment_type)**：

| 值 | 显示名称 | 说明 |
|----|---------|------|
| general | 整体意见 | 针对整个评审的意见 |
| testcase | 用例意见 | 针对特定用例的意见 |
| step | 步骤意见 | 针对用例特定步骤的意见 |

### 2.5 评审模板表 (ReviewTemplate)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BigAutoField | 主键 | 模板ID |
| name | CharField(200) | 必填 | 模板名称 |
| description | TextField | 可选 | 模板描述 |
| project | ManyToManyField | 必填 | 关联项目 |
| creator | ForeignKey(User) | 必填 | 创建人 |
| checklist | JSONField | 默认[] | 检查清单 |
| default_reviewers | ManyToManyField | 可选 | 默认评审人 |
| is_active | BooleanField | 默认True | 是否启用 |
| created_at | DateTimeField | 自动 | 创建时间 |
| updated_at | DateTimeField | 自动 | 更新时间 |

---

## 3. API 接口设计

### 3.1 评审相关接口 (TestCaseReviewViewSet)

| 方法 | 端点 | 说明 | 请求参数 |
|------|------|------|----------|
| GET | `/api/reviews/reviews/` | 获取评审列表 | `project`, `status`, `reviewer`, 分页参数 |
| POST | `/api/reviews/reviews/` | 创建评审 | 见创建参数 |
| GET | `/api/reviews/reviews/{id}/` | 获取评审详情 | - |
| PUT | `/api/reviews/reviews/{id}/` | 更新评审 | 见更新参数 |
| DELETE | `/api/reviews/reviews/{id}/` | 删除评审 | - |
| POST | `/api/reviews/reviews/{id}/submit_review/` | 提交评审 | `status`, `comment`, `checklist_results` |
| POST | `/api/reviews/reviews/{id}/assign_reviewers/` | 分配评审人 | `reviewer_ids` |
| GET | `/api/reviews/reviews/my_reviews/` | 获取我的评审 | - |

**创建评审请求参数 (POST /api/reviews/reviews/)**：

```json
{
    "title": "string",              // 必填，评审标题
    "description": "string",        // 可选，评审描述
    "projects": [1, 2],             // 必填，项目ID列表
    "testcases": [1, 2, 3],         // 必填，用例ID列表
    "reviewers": [4, 5],            // 必填，评审人ID列表
    "priority": "medium",           // 可选，优先级
    "deadline": "2026-04-20T18:00:00Z",  // 可选，截止时间
    "template": 1                   // 可选，模板ID
}
```

**提交评审请求参数 (POST /api/reviews/reviews/{id}/submit_review/)**：

```json
{
    "status": "approved",           // 必填，approved/rejected/abstained
    "comment": "string",            // 可选，评审意见
    "checklist_results": {           // 可选，检查清单结果
        "0": true,
        "1": false,
        "2": true
    }
}
```

**评审响应数据结构**：

```json
{
    "id": 1,
    "title": "V2.0版本用例评审",
    "description": "针对新版本的全面评审",
    "projects": [
        {"id": 1, "name": "电商系统", "description": "..."}
    ],
    "testcases": [
        {"id": 1, "title": "登录功能测试", "test_type": "functional", "priority": "high", "status": "active", "author": {"id": 1, "username": "张三", ...}}
    ],
    "creator": {"id": 1, "username": "张三", "email": "...", "first_name": "...", "last_name": "..."},
    "template": {
        "id": 1,
        "name": "功能测试评审模板",
        "checklist": ["用例描述清晰", "前置条件完整", "步骤无歧义", "预期结果明确"]
    },
    "status": "pending",
    "priority": "high",
    "deadline": "2026-04-20T18:00:00Z",
    "created_at": "2026-04-10T10:00:00Z",
    "updated_at": "2026-04-10T10:00:00Z",
    "completed_at": null,
    "assignments": [
        {
            "id": 1,
            "reviewer": {"id": 2, "username": "李四", ...},
            "status": "pending",
            "comment": "",
            "checklist_results": {},
            "reviewed_at": null,
            "assigned_at": "2026-04-10T10:00:00Z"
        }
    ],
    "comments": [
        {
            "id": 1,
            "testcase": {"id": 1, "title": "登录功能测试", ...},
            "author": {"id": 2, "username": "李四", ...},
            "comment_type": "testcase",
            "content": "建议增加边界值测试",
            "step_number": null,
            "is_resolved": false,
            "created_at": "2026-04-10T11:00:00Z",
            "updated_at": "2026-04-10T11:00:00Z"
        }
    ]
}
```

### 3.2 评审意见相关接口 (TestCaseReviewCommentViewSet)

| 方法 | 端点 | 说明 | 请求参数 |
|------|------|------|----------|
| GET | `/api/reviews/review-comments/` | 获取意见列表 | `review`, `testcase` |
| POST | `/api/reviews/review-comments/` | 创建意见 | 见创建参数 |
| GET | `/api/reviews/review-comments/{id}/` | 获取意见详情 | - |
| PUT | `/api/reviews/review-comments/{id}/` | 更新意见 | - |
| DELETE | `/api/reviews/review-comments/{id}/` | 删除意见 | - |

**创建评审意见请求参数 (POST /api/reviews/review-comments/)**：

```json
{
    "review": 1,                   // 必填，评审ID
    "testcase": 1,                  // 可选，相关用例ID
    "comment_type": "testcase",     // 必填，general/testcase/step
    "content": "建议增加边界值测试",  // 必填，意见内容
    "step_number": 2                // 可选，步骤序号
}
```

### 3.3 评审模板相关接口 (ReviewTemplateViewSet)

| 方法 | 端点 | 说明 | 请求参数 |
|------|------|------|----------|
| GET | `/api/reviews/review-templates/` | 获取模板列表 | `project` |
| POST | `/api/reviews/review-templates/` | 创建模板 | 见创建参数 |
| GET | `/api/reviews/review-templates/{id}/` | 获取模板详情 | - |
| PUT | `/api/reviews/review-templates/{id}/` | 更新模板 | - |
| DELETE | `/api/reviews/review-templates/{id}/` | 删除模板 | - |

**创建模板请求参数 (POST /api/reviews/review-templates/)**：

```json
{
    "name": "功能测试评审模板",      // 必填，模板名称
    "description": "适用于功能测试用例评审",  // 可选，模板描述
    "project": [1],                  // 必填，项目ID列表
    "checklist": [                   // 可选，检查清单
        "用例描述清晰易懂",
        "前置条件完整",
        "操作步骤无歧义",
        "预期结果明确可验证",
        "用例可执行性强"
    ],
    "default_reviewers": [2, 3]      // 可选，默认评审人ID列表
}
```

---

## 4. 前端页面设计

### 4.1 页面路由

| 路由路径 | 页面组件 | 说明 |
|---------|---------|------|
| `/ai-generation/reviews` | ReviewList.vue | 评审列表页 |
| `/ai-generation/reviews/create` | ReviewForm.vue | 创建评审页 |
| `/ai-generation/reviews/:id` | ReviewDetail.vue | 评审详情页 |
| `/ai-generation/reviews/:id/edit` | ReviewForm.vue | 编辑评审页 |
| `/ai-generation/review-templates` | ReviewTemplateList.vue | 评审模板页 |

### 4.2 评审列表页 (ReviewList.vue)

**功能描述**：展示所有评审任务列表，支持筛选和快捷操作。

**页面布局**：
```
┌─────────────────────────────────────────────────────────────────┐
│  [用例评审]                                      [新建评审]按钮  │
├─────────────────────────────────────────────────────────────────┤
│ 项目: [下拉选择___]  评审状态: [下拉选择___]  评审人: [下拉选择___]│
├─────────────────────────────────────────────────────────────────┤
│ 评审标题 │ 项目 │ 状态 │ 优先级 │ 创建人 │ 用例数 │ 进度 │ ... │ 操作 │
├─────────────────────────────────────────────────────────────────┤
│ V2.0版本... │ 电商... │ [待评审]│ [高] │ 张三 │  15   │  ██░ │ ... │ 详情│评审│编辑│删除│
│ V1.5版本... │ 支付... │ [评审中]│ [中] │ 李四 │   8   │  █░░ │ ... │ 详情│评审│编辑│删除│
│ ...                                                                │
├─────────────────────────────────────────────────────────────────┤
│                         [分页: 1 2 3 ... 10]                      │
└─────────────────────────────────────────────────────────────────┘
```

**核心功能**：
1. **筛选功能**：按项目、评审状态、评审人筛选
2. **进度展示**：圆形进度条或线性进度条，显示评审完成比例
3. **快捷操作**：查看详情、提交评审、编辑、删除
4. **权限控制**：
   - 只有评审人可以看到"评审"按钮
   - 只有创建人可以编辑和删除

**状态筛选**：
- 全部
- 待评审 (pending)
- 评审中 (in_progress)
- 已通过 (approved)
- 已拒绝 (rejected)
- 已取消 (cancelled)

**提交评审对话框**：
```
┌────────────────────────────────────┐
│ 提交评审                         X │
├────────────────────────────────────┤
│ 评审结果:  [通过] [拒绝]           │
│                                    │
│ 评审意见:                          │
│ ┌────────────────────────────────┐ │
│ │                                │ │
│ │                                │ │
│ └────────────────────────────────┘ │
│                                    │
│              [取消]  [提交]        │
└────────────────────────────────────┘
```

### 4.3 评审详情页 (ReviewDetail.vue)

**功能描述**：展示评审的完整信息，包括基本信息、评审进度、评审人员状态、评审用例和评审意见。

**页面布局**：
```
┌─────────────────────────────────────────────────────────────────┐
│ [评审详情]                              [返回] [编辑] [提交评审] │
├─────────────────────────────────────────────────────────────────┤
│ ┌──────────────────────── 基本信息 ────────────────────────────┐ │
│ │ 评审标题: V2.0版本用例评审                                   │ │
│ │ 关联项目: 电商系统, 支付系统                                  │ │
│ │ 创建人: 张三    使用模板: 功能测试评审模板                    │ │
│ │ 评审状态: [评审中]  优先级: [高]   截止时间: 2026-04-20     │ │
│ │ 创建时间: 2026-04-10 10:00                                  │ │
│ │ 评审描述: 针对V2.0新功能的全面用例评审...                    │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ┌──────────────────────── 评审进度 ─────────────────────────────┐ │
│ │                                                          │   │
│ │    评审人员: 5      已完成: 3      待评审: 2              │   │
│ │   ████████████████████░░░░░░░░░░░░░░  60%               │   │
│ └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ┌────────────────────── 评审人员状态 ──────────────────────────┐ │
│ │ 评审人 │ 状态 │ 评审意见 │ 检查清单 │ 分配时间 │ 评审时间   │ │
│ │ 李四   │[待评审]│   -    │  未填写  │ 04-10   │    -      │ │
│ │ 王五   │[已通过]│  OK    │  5/5通过 │ 04-10   │  04-11    │ │
│ │ 赵六   │[已通过]│  OK    │  4/5通过 │ 04-10   │  04-11    │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ┌────────────────────── 评审用例 ──────────────────────────────┐ │
│ │ 用例标题 │ 测试类型 │ 优先级 │ 作者 │ 操作                  │ │
│ │ 登录测试 │ 功能测试 │  [高]  │ 张三 │ [查看] [评论]        │ │
│ │ 支付测试 │ 功能测试 │  [高]  │ 李四 │ [查看] [评论]        │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ┌────────────────────── 评审意见 ─────────────────────────────┐ │
│ │ [添加意见]按钮                                                 │ │
│ │ ┌─────────────────────────────────────────────────────────┐ │ │
│ │ │ [头像] 李四 [用例意见]  2026-04-11 10:30                │ │ │
│ │ │ 登录测试用例的第3步，建议增加超时场景测试                  │ │ │
│ │ │ 相关用例: 登录功能测试                                    │ │ │
│ │ └─────────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**核心功能**：
1. **基本信息展示**：评审标题、项目、创建人、模板、状态、优先级、截止时间
2. **进度统计**：总人数、已完成人数、待评审人数、进度条
3. **评审人员表格**：
   - 展示每个评审人的状态、意见、检查清单结果
   - 检查清单结果通过 Tooltip 展示详细信息
4. **评审用例表格**：展示待评审的用例列表，支持查看详情和添加评论
5. **评审意见列表**：展示所有评审意见，按类型区分
6. **提交评审对话框**：
   - 选择评审结果：通过/拒绝/弃权
   - 填写检查清单（如果有模板）
   - 填写评审意见

**提交评审对话框（带检查清单）**：
```
┌────────────────────────────────────────────────────────────────┐
│ 提交评审                                                    X   │
├────────────────────────────────────────────────────────────────┤
│ 评审结果:  [通过] [拒绝] [弃权]                                 │
│                                                                │
│ ┌──────── 功能测试评审模板 - 检查清单 ────────────────────────┐ │
│ │ [全部通过]  [全部不通过]                                    │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │ 用例描述清晰易懂                         [通过] [拒绝]      │ │
│ │ 前置条件完整                             [通过] [拒绝]      │ │
│ │ 操作步骤无歧义                           [通过] [拒绝]      │ │
│ │ 预期结果明确可验证                       [通过] [拒绝]      │ │
│ │ 用例可执行性强                           [通过] [拒绝]      │ │
│ └────────────────────────────────────────────────────────────┘ │
│                                                                │
│ 评审意见:                                                      │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │                                                            │ │
│ └────────────────────────────────────────────────────────────┘ │
│                                                                │
│                        [取消]  [提交]                           │
└────────────────────────────────────────────────────────────────┘
```

### 4.4 评审表单页 (ReviewForm.vue)

**功能描述**：创建或编辑评审任务。

**页面布局**：
```
┌─────────────────────────────────────────────────────────────────┐
│ [新建评审/编辑评审]                              [返回]  [保存]  │
├─────────────────────────────────────────────────────────────────┤
│                                                                     │
│ 评审标题:  [________________________________]                       │
│                                                                     │
│ 关联项目:  [多选下拉: 电商系统, 支付系统, ...]                       │
│                                                                     │
│ 优先级:    [下拉: 低/中/高/紧急]                                     │
│ 截止日期:  [日期时间选择器]                                           │
│                                                                     │
│ 评审描述:  [多行文本区域]                                             │
│                                                                     │
│ 选择用例:  ┌─────────────────────────────────────────────────┐      │
│           │ [搜索用例输入框]  [选择用例按钮]                   │      │
│           ├─────────────────────────────────────────────────┤      │
│           │ [登录测试 x] [支付测试 x] [注册测试 x] ...        │      │
│           │ 提示: 请选择要评审的测试用例                        │      │
│           └─────────────────────────────────────────────────┘      │
│                                                                     │
│ 评审人员:  [多选下拉: 张三, 李四, 王五, ...]                         │
│                                                                     │
│ 评审模板:  [下拉选择模板: 功能测试评审模板, 安全测试模板, ...]        │
│                                                                     │
└─────────────────────────────────────────────────────────────────┘
```

**核心功能**：
1. **用例选择器**：
   - 先选择项目，加载该项目的用例列表
   - 弹出对话框选择用例
   - 已选用例以 Tag 形式展示，可删除
2. **模板应用**：
   - 选择模板后自动填充默认评审人
   - 模板的检查清单会体现在提交评审时
3. **表单验证**：
   - 标题：必填
   - 项目：必填
   - 用例：必填，至少选择一个
   - 评审人：必填，至少选择一个

**用例选择对话框**：
```
┌─────────────────────────────────────────────────────────────┐
│ 选择测试用例                                           [X]   │
├─────────────────────────────────────────────────────────────┤
│ [搜索用例输入框]                                             │
│ ┌───────────────────────────────────────────────────────┐   │
│ │ [☑] 用例标题         │ 测试类型  │ 优先级 │ 作者       │   │
│ │ [☑] 登录功能测试     │ 功能测试  │  高    │ 张三       │   │
│ │ [☑] 支付功能测试     │ 功能测试  │  高    │ 李四       │   │
│ │ [ ] 注册功能测试     │ 功能测试  │  中    │ 王五       │   │
│ │ [ ] 找回密码测试     │ 功能测试  │  低    │ 张三       │   │
│ └───────────────────────────────────────────────────────┘   │
│                                                       [取消] [确定] │
└─────────────────────────────────────────────────────────────┘
```

### 4.5 评审模板页 (ReviewTemplateList.vue)

**功能描述**：管理评审模板，支持创建、编辑、删除和使用模板。

**页面布局**：
```
┌─────────────────────────────────────────────────────────────────┐
│ [评审模板]                                    [创建模板]按钮      │
├─────────────────────────────────────────────────────────────────┤
│ 项目: [下拉选择___]                                               │
├─────────────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 功能测试评审模板                                [使用][编辑][删除]│
│ │ 项目: 电商系统                                               │
│ │ 创建人: 张三    创建时间: 2026-04-01                         │
│ │                                                              │
│ │ 描述: 适用于功能测试用例的标准化评审                          │
│ │                                                              │
│ │ 检查清单:                                                    │
│ │ • 用例描述清晰易懂                                           │
│ │ • 前置条件完整                                               │
│ │ • 操作步骤无歧义                                             │
│ │ • 预期结果明确可验证                                          │
│ │ • 用例可执行性强                                             │
│ │ ...还有 2 项...                                              │
│ │                                                              │
│ │ 默认评审人: [张三] [李四] [王五]                              │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                  │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 安全测试评审模板                                [使用][编辑][删除]│
│ │ ...                                                          │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**创建/编辑模板对话框**：
```
┌────────────────────────────────────────────────────────────────┐
│ 创建模板                                                     [X] │
├────────────────────────────────────────────────────────────────┤
│ 模板名称: [________________________]                            │
│ 关联项目: [下拉选择________________]                            │
│ 模板描述: [多行文本区域]                                          │
│                                                                  │
│ 检查清单:                                                        │
│ ┌────────────────────────────────────────────────────────────┐  │
│ │ [用例描述清晰易懂                              ×] [删除]   │  │
│ │ [前置条件完整                                  ×] [删除]   │  │
│ │ [操作步骤无歧义                                ×] [删除]   │  │
│ │ [预期结果明确可验证                            ×] [删除]   │  │
│ │ [+ 添加检查项                                         ]    │  │
│ └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│ 默认评审人: [多选下拉: 张三, 李四, 王五, ...]                     │
│                                                                  │
│                        [取消]  [保存]                            │
└────────────────────────────────────────────────────────────────┘
```

---

## 5. 业务逻辑设计

### 5.1 评审状态流转

```
                    ┌──────────────────┐
                    │                  │
                    │   创建评审        │
                    │  (pending)       │
                    │                  │
                    └────────┬─────────┘
                             │
                             │ 首个评审人开始评审
                             ▼
                    ┌──────────────────┐
                    │                  │
                    │   评审中         │
                    │ (in_progress)    │
                    │                  │
                    └────────┬─────────┘
                             │
              ┌──────────────┴──────────────┐
              │                              │
              ▼                              ▼
    ┌──────────────────┐          ┌──────────────────┐
    │                  │          │                  │
    │    已通过         │          │    已拒绝         │
    │  (approved)      │          │  (rejected)      │
    │                  │          │                  │
    └──────────────────┘          └──────────────────┘
              │                              │
              │                              │
              └──────────────┬───────────────┘
                             │
                             │ 创建者可取消
                             ▼
                   ┌──────────────────┐
                   │                  │
                   │    已取消         │
                   │  (cancelled)    │
                   │                  │
                   └──────────────────┘
```

### 5.2 评审完成判断逻辑

当调用 `submit_review` 接口时，系统自动判断评审是否完成：

```python
def submit_review(request, pk=None):
    review = self.get_object()
    assignment = ReviewAssignment.objects.get(review=review, reviewer=request.user)
    
    # 更新评审分配状态
    assignment.status = request.data.get('status', 'approved')
    assignment.comment = request.data.get('comment', '')
    assignment.checklist_results = request.data.get('checklist_results', {})
    assignment.reviewed_at = timezone.now()
    assignment.save()
    
    # 检查是否所有评审人都已完成评审
    pending_count = ReviewAssignment.objects.filter(
        review=review, 
        status='pending'
    ).count()
    
    if pending_count == 0:
        # 所有评审人都已完成
        approved_count = ReviewAssignment.objects.filter(
            review=review, 
            status='approved'
        ).count()
        total_count = ReviewAssignment.objects.filter(review=review).count()
        
        # 判断最终结果：全部通过才为通过
        if approved_count == total_count:
            review.status = 'approved'
        else:
            review.status = 'rejected'
            
        review.completed_at = timezone.now()
        review.save()
    
    return Response({'message': '评审提交成功'})
```

### 5.3 评审权限控制

| 操作 | 权限要求 |
|------|---------|
| 查看评审列表 | 已登录用户 |
| 查看评审详情 | 已登录用户（项目成员） |
| 创建评审 | 已登录用户 |
| 编辑评审 | 创建者，且状态为 pending 或 in_progress |
| 删除评审 | 创建者，且状态为 pending |
| 提交评审 | 分配为该评审的评审人，且分配状态为 pending |
| 添加评审意见 | 已登录用户 |
| 管理模板 | 已登录用户 |

### 5.4 模板匹配逻辑

在创建评审页面，当用户选择模板时，自动匹配并填充默认评审人：

```python
def findMatchingTemplate(review, templateList):
    """
    根据项目和评审人匹配最合适的模板
    """
    # 获取评审的项目ID列表和评审人ID列表
    reviewProjectIds = review.projects.map(p => p.id).sort()
    reviewReviewerIds = review.assignments.map(a => a.reviewer.id).sort()
    
    let bestMatch = null
    let bestScore = 0
    
    for (const template of templateList) {
        let score = 0
        
        // 检查项目匹配度
        const templateProjectIds = template.project.map(p => p.id).sort()
        const projectIntersection = reviewProjectIds.filter(
            id => templateProjectIds.includes(id)
        )
        if (projectIntersection.length > 0) {
            score += projectIntersection.length * 2  // 项目权重更高
        }
        
        // 检查默认评审人匹配度
        const templateReviewerIds = template.default_reviewers.map(r => r.id).sort()
        const reviewerIntersection = reviewReviewerIds.filter(
            id => templateReviewerIds.includes(id)
        )
        if (reviewerIntersection.length > 0) {
            score += reviewerIntersection.length
        }
        
        if (score > bestScore) {
            bestScore = score
            bestMatch = template
        }
    }
    
    return bestScore > 0 ? bestMatch : null
}
```

---

## 6. 数据库表结构

### 6.1 数据库表清单

| 表名 | 对应模型 | 说明 |
|------|---------|------|
| testcase_reviews | TestCaseReview | 评审主表 |
| review_assignments | ReviewAssignment | 评审分配表 |
| review_comments | TestCaseReviewComment | 评审意见表 |
| review_templates | ReviewTemplate | 评审模板表 |

### 6.2 表结构详情

#### testcase_reviews (评审主表)

| 字段 | 类型 | 索引 | 外键 | 说明 |
|------|------|------|------|------|
| id | bigint | PK | - | 主键ID |
| title | varchar(500) | - | - | 评审标题 |
| description | text | - | - | 评审描述 |
| template_id | bigint | FK | review_templates.id | 模板ID，可为空 |
| creator_id | bigint | FK | users.id | 创建人ID |
| status | varchar(20) | INDEX | - | 评审状态 |
| priority | varchar(20) | INDEX | - | 优先级 |
| deadline | datetime | - | - | 截止时间 |
| created_at | datetime | INDEX | - | 创建时间 |
| updated_at | datetime | - | - | 更新时间 |
| completed_at | datetime | - | - | 完成时间 |

**多对多表**：
- `testcase_reviews_projects` (review_id, project_id)
- `testcase_reviews_testcases` (review_id, testcase_id)

#### review_assignments (评审分配表)

| 字段 | 类型 | 索引 | 外键 | 说明 |
|------|------|------|------|------|
| id | bigint | PK | - | 主键ID |
| review_id | bigint | FK, INDEX | testcase_reviews.id | 评审ID |
| reviewer_id | bigint | FK, INDEX | users.id | 评审人ID |
| status | varchar(20) | INDEX | - | 分配状态 |
| comment | text | - | - | 评审意见 |
| checklist_results | json | - | - | 检查清单结果 |
| reviewed_at | datetime | - | - | 评审时间 |
| assigned_at | datetime | INDEX | - | 分配时间 |

**唯一约束**：`[review_id, reviewer_id]`

#### review_comments (评审意见表)

| 字段 | 类型 | 索引 | 外键 | 说明 |
|------|------|------|------|------|
| id | bigint | PK | - | 主键ID |
| review_id | bigint | FK, INDEX | testcase_reviews.id | 评审ID |
| testcase_id | bigint | FK, INDEX | testcases.id | 用例ID，可为空 |
| author_id | bigint | FK, INDEX | users.id | 评论者ID |
| comment_type | varchar(20) | INDEX | - | 意见类型 |
| content | text | - | - | 意见内容 |
| step_number | int | - | - | 步骤序号，可为空 |
| is_resolved | bool | - | - | 是否已解决 |
| created_at | datetime | INDEX | - | 创建时间 |
| updated_at | datetime | - | - | 更新时间 |

#### review_templates (评审模板表)

| 字段 | 类型 | 索引 | 外键 | 说明 |
|------|------|------|------|------|
| id | bigint | PK | - | 主键ID |
| name | varchar(200) | - | - | 模板名称 |
| description | text | - | - | 模板描述 |
| creator_id | bigint | FK | users.id | 创建人ID |
| checklist | json | - | - | 检查清单 |
| is_active | bool | INDEX | - | 是否启用 |
| created_at | datetime | INDEX | - | 创建时间 |
| updated_at | datetime | - | - | 更新时间 |

**多对多表**：
- `review_templates_project` (reviewtemplate_id, project_id)
- `review_templates_default_reviewers` (reviewtemplate_id, user_id)

---

## 7. 国际化支持

### 7.1 中文语言包 (zh-cn/review.js)

评审模块的完整中文国际化配置：

```javascript
export default {
  reviewList: {
    title: '用例评审',
    createReview: '新建评审',
    // ... 完整的键值对见 frontend/src/locales/lang/zh-cn/review.js
  },
  reviewDetail: {
    title: '评审详情',
    // ... 完整的键值对见 frontend/src/locales/lang/zh-cn/review.js
  },
  reviewForm: {
    createTitle: '新建评审',
    editTitle: '编辑评审',
    // ... 完整的键值对见 frontend/src/locales/lang/zh-cn/review.js
  },
  reviewTemplate: {
    title: '评审模板',
    // ... 完整的键值对见 frontend/src/locales/lang/zh-cn/review.js
  }
}
```

### 7.2 英文语言包 (en/review.js)

评审模块的完整英文国际化配置：

```javascript
export default {
  reviewList: {
    title: 'Test Case Review',
    createReview: 'Create Review',
    // ... 完整的键值对见 frontend/src/locales/lang/en/review.js
  },
  reviewDetail: {
    title: 'Review Detail',
    // ... 完整的键值对见 frontend/src/locales/lang/en/review.js
  },
  reviewForm: {
    createTitle: 'New Review',
    editTitle: 'Edit Review',
    // ... 完整的键值对见 frontend/src/locales/lang/en/review.js
  },
  reviewTemplate: {
    title: 'Review Templates',
    // ... 完整的键值对见 frontend/src/locales/lang/en/review.js
  }
}
```

---

## 8. 依赖关系

### 8.1 系统依赖

- **后端依赖**：
  - Django 4.2+
  - Django REST Framework
  - django-filter
  - drf-spectacular

- **前端依赖**：
  - Vue 3
  - Element Plus
  - Vue Router
  - Pinia
  - Vue I18n
  - Axios
  - dayjs

### 8.2 模块间依赖

| 被依赖模块 | 依赖关系 | 说明 |
|-----------|---------|------|
| users | 外键 | User 模型用于 creator, reviewer, author |
| projects | 外键/多对多 | Project 模型用于关联项目 |
| testcases | 外键/多对多 | TestCase 模型用于评审用例 |

---

## 9. 已实现代码清单

### 9.1 后端代码

| 文件路径 | 说明 |
|---------|------|
| `apps/reviews/__init__.py` | 应用初始化 |
| `apps/reviews/apps.py` | Django 应用配置 |
| `apps/reviews/models.py` | 数据模型定义 |
| `apps/reviews/serializers.py` | 序列化器 |
| `apps/reviews/views.py` | 视图集 |
| `apps/reviews/urls.py` | 路由配置 |
| `apps/reviews/admin.py` | Admin 配置 |
| `apps/reviews/migrations/0001_initial.py` | 初始迁移 |
| `apps/reviews/migrations/0002_initial.py` | 外键迁移 |

### 9.2 前端代码

| 文件路径 | 说明 |
|---------|------|
| `frontend/src/views/reviews/ReviewList.vue` | 评审列表页 |
| `frontend/src/views/reviews/ReviewForm.vue` | 评审表单页 |
| `frontend/src/views/reviews/ReviewDetail.vue` | 评审详情页 |
| `frontend/src/views/reviews/ReviewTemplateList.vue` | 评审模板页 |
| `frontend/src/locales/lang/zh-cn/review.js` | 中文国际化 |
| `frontend/src/locales/lang/en/review.js` | 英文国际化 |

### 9.3 路由配置

**后端路由**：
- `backend/urls.py` - 包含 `path('api/reviews/', include('apps.reviews.urls'))`

**前端路由**：
- `frontend/src/router/index.js` - 评审相关路由定义

**Django Admin 注册**：
- `apps/reviews/admin.py` - 四个模型的 Admin 配置

---

## 10. 后续优化建议

### 10.1 功能增强

1. **评审通知**：集成通知系统，在评审分配、完成时发送通知
2. **评审历史**：记录评审的变更历史，支持版本回溯
3. **批量操作**：支持批量分配评审人、批量提交评审
4. **评审报告**：生成评审汇总报告，包括通过率、常见问题等
5. **AI 辅助评审**：结合 AI 能力，自动检查用例质量问题

### 10.2 性能优化

1. **查询优化**：对列表接口添加适当的索引和预加载
2. **缓存机制**：对常用模板进行缓存
3. **分页优化**：支持更大的数据量分页

### 10.3 用户体验优化

1. **评审引导**：对新人提供评审流程引导
2. **快捷键支持**：添加常用操作的快捷键
3. **导出功能**：支持导出评审结果为 Excel/PDF

---

## 11. 附录

### 11.1 术语表

| 术语 | 说明 |
|------|------|
| 评审 (Review) | 对测试用例进行的质量检查活动 |
| 评审人 (Reviewer) | 参与评审的人员 |
| 检查清单 (Checklist) | 评审时需要逐项检查的内容列表 |
| 评审模板 (Template) | 预定义的评审配置，包括检查清单和默认评审人 |
| 评审意见 (Comment) | 评审过程中提出的具体意见或建议 |

### 11.2 变更记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-04-10 | 初始版本 | TestHub Team |
