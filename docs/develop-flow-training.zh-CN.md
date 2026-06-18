**English** | [中文](develop-flow-training.md)

# Develop-Flow 培训指南（中文）

> 纯后端全链路 Agent Team 开发工作流——从需求到代码就绪

---

## 1. 概述

### 什么是 Develop-Flow？

Develop-Flow 是一个 OpenCode Skill，自动化从需求到代码的完整后端开发工作流。通过 Hub-and-Spoke 模式协调多个 AI Agent，经过 6 个 Phase + 6 个 Gate：

```
需求输入 → 需求分析 → 架构设计 → 任务规划 → TDD 开发 → 代码评审 → 测试验证 → 代码就绪
```

### 核心价值

- **全链路自动化**: 从需求到代码，无需手动切换工具
- **内置质量保证**: 6 个 Gate 检查点确保每步质量
- **TDD 驱动**: 先写测试保证代码质量
- **人机协作**: 半自动模式让用户掌控关键决策
- **可恢复**: 断点恢复机制——中断后随时继续

### 需求来源

develop-flow 的需求来源不是 Jira，而是：
- **飞书文档**: 提示用户复制内容（当前不支持直接抓取）
- **文字描述**: 直接使用
- **图片**: 提示用户转为文字（当前模型可能不支持图片输入）

---

## 2. 快速开始

### 安装

```bash
cd develop-flow
chmod +x install.sh
./install.sh
```

### 初始化项目

```
/init-flow
```

### 运行工作流

```
/develop-flow 用户认证模块需要支持 JWT 和 refresh token
```

---

## 3. Agent 一览

### 核心 Agent（6 个，工作流必须）

| Agent | 用途 |
|-------|------|
| requirements-analyst | 需求分析、生成 proposal |
| architect | 架构设计、生成 design.md |
| planner | 任务拆分、TDD 步骤规划 |
| backend-developer | 后端代码实现 |
| code-reviewer | 代码评审并分级 |
| tester | 测试验证、Bug 报告 |

### 辅助 Agent（9 个，独立使用或按需调用）

| Agent | 用途 |
|-------|------|
| build-error-resolver | 构建错误快速修复 |
| code-explorer | 代码库探索和理解 |
| code-simplifier | 代码简化和精炼 |
| database-reviewer | 数据库评审（MySQL/PostgreSQL） |
| performance-optimizer | 性能分析和优化 |
| security-reviewer | 安全漏洞检测 |
| doc-updater | 文档更新和维护 |
| refactor-cleaner | 死代码清理和重构 |
| tdd-guide | TDD 方法论指导 |

---

## 4. 配置

### 流程配置

`~/.agents/skills/develop-flow/project-config.md`

```yaml
root_path: "/path/to/project"
openspec:
  changes_path: "openspec/changes"
  baseline_path: "openspec/specs"
```

### 项目配置

`{root_path}/.develop-flow/project-config.md`

```yaml
tech_stack: { backend: "laravel", database: "mysql" }
backend: { main_repo: "." }
git: { main_branch: "master" }
databases:
  main: { mcp: "mcp__xxx__mysql_query" }
test_environments:
  default: { url: "http://..." }
build_commands:
  backend: ""
migration:
  steps: ["php artisan migrate --force"]
```

---

## 5. 常见问题

**Q: 图片需求怎么处理？**
A: 当前模型可能不支持图片输入。Leader 会提示用户将图片内容以文字形式描述。

**Q: 飞书文档怎么处理？**
A: 当前不支持直接抓取飞书文档。Leader 会提示用户将文档内容复制粘贴。

**Q: 代码会自动 commit 吗？**
A: 不会。develop-flow 只在工作目录中生成代码，不执行 commit/push。用户需要手动 commit。

**Q: 支持前端开发吗？**
A: 当前版本专注纯后端开发，不涉及前端页面。
