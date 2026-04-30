# TestHub Java 版本文档

本目录用于存放 TestHub 平台 Java 版本重构的相关文档。

---

## 文档清单

### Phase 1 - 技术准备期

| 文档 | 路径 | 状态 | 说明 |
|------|------|------|------|
| README | `docs/java-version/README.md` | 完成 | 本文档 |
| 功能需求清单 | `docs/java-version/01-requirements/01-功能需求清单.md` | 完成 | 功能需求汇总 |
| PRD 概述 | `docs/java-version/02-prd/01-PRD概述.md` | 完成 | 产品需求文档 |
| 用户故事地图 | `docs/java-version/02-prd/02-用户故事地图.md` | 完成 | 用户故事 |
| **技术栈锁定** | `docs/java-version/03-technical/01-技术栈锁定.md` | 完成 | 技术选型决策 |
| **架构草案** | `docs/java-version/03-technical/02-架构草案.md` | 进行中 | 详细架构设计（草案） |
| **架构文档** | `docs/java-version/03-technical/03-架构文档.md` | 完成 | 正式架构文档 |
| **项目进度** | `docs/java-version/03-technical/04-项目进度.md` | 进行中 | 阶段进度追踪 |
| **开发规范** | `docs/java-version/03-technical/07-开发规范.md` | 完成 | 代码规范、开发流程 |
| **开发参考** | `docs/java-version/03-technical/08-开发参考.md` | 完成 | 代码模板、技术文档 |

### Phase 2-6 - 待开发

| 文档 | 路径 | 状态 |
|------|------|------|
| 数据库设计 | `docs/java-version/03-technical/05-数据库设计.md` | 待创建 |
| API 接口文档 | `docs/java-version/03-technical/06-API文档.md` | 待创建 |

---

## 核心文档说明

### 1. 架构文档 (`03-架构文档.md`)

**正式架构文档**，记录项目全局架构信息，包含：
- 技术栈清单
- 目录结构
- 模块划分
- 数据模型
- API 设计规范
- 安全设计
- 部署架构

### 2. 项目进度 (`04-项目进度.md`)

**进度追踪文档**，记录当前阶段、已知问题、后续计划，包含：
- 当前阶段和目标
- 技术可行性验证清单
- 已完成工作记录
- 已知问题列表
- 后续计划

### 3. 架构草案 (`02-架构草案.md`)

**草案性质**，允许持续迭代，每次修改需记录原因。

---

## 全局上下文说明

### 当前阶段

**Phase 1 - 技术准备期**（进行中）

### 核心技术栈

```
Java 17 LTS (Eclipse Temurin 17.0.17)
Spring Boot 3.2.x LTS
MyBatis-Plus 3.5.x
Spring Security 6.2.x + JWT
MySQL 8.0 (已安装 8.0.42)
Redis 7.x (Docker 部署)
XXL-JOB 2.4.x (Docker 部署)
MinIO (Docker 部署)
Maven 3.9.10 (已安装)
LangChain4j 1.x
Jenkins (CI/CD)
```

### 业务范围

- 15 个核心模块
- 88 张数据库表（参考 Python 版本）
- 前端保持 Vue 3 不变

---

## 文档编写规范

1. **文件名命名规范**：`序号-文档名称.md`（如 `01-技术栈锁定.md`）
2. **使用中文编写**
3. **图表优先**：能用图表表示的尽量使用 Mermaid、流程图等
4. **版本记录**：重大文档需要记录版本变更历史
5. **维护更新**：架构/进度等文档变更后需更新「最后更新」日期

---

## 参考资源

| 资源 | 路径 | 说明 |
|------|------|------|
| Python 版本代码 | `apps/` | 业务逻辑参考 |
| Python 版本数据库 | `db/testhub.sql` | 88 张表结构 |
| Python 版本前端 | `frontend/` | Vue 3 前端代码 |

---

## 更新记录

| 日期 | 更新内容 |
|------|----------|
| 2026-04-13 | 初始版本，创建文档框架 |
| 2026-04-13 | 完成技术栈锁定、架构草案、架构文档、项目进度 |
