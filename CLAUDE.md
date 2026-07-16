# CLAUDE.md

本文件为 AI Agent 在此仓库工作时提供指导。

## 项目概述

develop-flow 是一个 OpenCode Skill，协调多 Agent AI 团队处理纯后端开发生命周期。需求来源为飞书文档或文字描述（非 Jira）。

```
需求输入 → 6 阶段 + 6 Gate → 代码就绪（待 commit）
```

**没有构建系统、测试套件、linter 或包管理器**。整个代码库是 Markdown Agent 定义、Skill 指令、Phase 简报和安装脚本。

## 安装与使用

```bash
# 安装（符号链接 skills + agents 到 ~/.agents/）
chmod +x install.sh && ./install.sh

# 卸载
./uninstall.sh
```

安装后在 OpenCode 中使用：
```
/init-flow                    # 一次性项目设置（自动检测技术栈、生成配置）
/develop-flow <需求描述>       # 运行完整生命周期
/develop-flow learn <note>    # 记录手动笔记
/develop-flow learn --upgrade # 提炼经验
```

**前置条件**: OpenCode CLI、`superpowers` 插件（>= 5.0.0）。

## 架构: Hub-and-Spoke 多 Agent 系统

Leader（主会话）协调、决策、路由——**绝不直接执行**代码。所有 Agent 消息经 Leader 路由；无 Agent 间直接通信。

**16 个 Agent**，其中 6 个核心用于工作流，10 个辅助可独立使用：

**核心 Agent（工作流必须）**:

| Agent | 用途 |
|-------|------|
| `requirements-analyst` | 分析需求、生成 proposal.md |
| `architect` | 生成 design.md 和架构决策 |
| `planner` | 拆分为 TDD 任务 |
| `backend-developer` | 实现后端代码 |
| `code-reviewer` | 评审变更并分级 |
| `tester` | 运行测试、报告 Bug |

**辅助 Agent（独立使用或按需调用）**:

| Agent | 用途 |
|-------|------|
| `build-error-resolver` | 构建错误快速修复 |
| `code-explorer` | 代码库探索和理解 |
| `code-simplifier` | 代码简化和精炼 |
| `database-reviewer` | 数据库评审（MySQL/PostgreSQL） |
| `performance-optimizer` | 性能分析和优化 |
| `security-reviewer` | 安全漏洞检测 |
| `doc-updater` | 文档更新和维护 |
| `refactor-cleaner` | 死代码清理和重构 |
| `tdd-guide` | TDD 方法论指导 |
| `file-parser` | 附件文件解析 |

## 6 阶段生命周期

每个 Phase 结束时有 **Gate** — 用户确认产出后再继续。两种模式：**半自动**（默认）和**全自动**。

| Phase | 产出 | Gate |
|-------|------|------|
| 0 预检 | 依赖检查 + 经验注入（learn apply） | 继续 |
| 1 需求分析 | proposal.md + design.md（交互检查点 A/B/C） | 确认 → spawn 开发 Agent |
| 2 任务规划 | tasks.md | 确认任务列表 |
| 3 TDD 开发 | 实现代码 | 确认进度 |
| 4 代码评审 | 分级评审报告 | CRITICAL/HIGH → 修复 |
| 5 测试验证 | 基于证据的测试报告 | 确认测试通过 |
| 6 收尾 | 清理 + 总结 + 学习沉淀（learn capture） | 最终总结 |

Phase 指令按需加载自 `skills/develop-flow/phases/phase-N-brief.md`。

## Skills（5 个）

| Skill | 入口 | 用途 |
|-------|------|------|
| `develop-flow` | `skills/develop-flow/skill.md` | 主 6 阶段生命周期 |
| `init-flow` | `skills/init-flow/skill.md` | 一键项目初始化 |
| `create-team` | `skills/create-team/SKILL.md` | 多 Agent 团队创建 |
| `delete-team` | `skills/delete-team/SKILL.md` | 团队清理 |
| `parse-attachment` | `skills/parse-attachment/SKILL.md` | 附件文件解析 |

## 学习闭环（Learn）

`skills/develop-flow/learn/` 实现学习闭环，让 develop-flow 在使用中持续成长：

| 阶段 | 自动/手动 | 说明 |
|------|----------|------|
| **capture** | ✅ 自动 | Phase 6 结束后，自动记录本次 run 的信号 |
| **apply** | ✅ 自动 | Phase 0 开始时，自动读取历史经验注入当前任务 |
| **distill** | ⚠️ 提醒后手动 | 累积 5 条信号后提醒，执行后聚类信号→更新知识库 |

**知识库位置**：
- `skills/develop-flow/playbook.md` — 全局经验（跨项目通用，自动成长）
- `{project}/.develop-flow/knowledge.md` — 项目级经验（该项目专属）
- `{project}/.develop-flow/{task_id}/lessons-*.jsonl` — 原始信号

## Obsidian 集成

`skills/develop-flow/obsidian/` 提供 Obsidian 集成，支持长期知识库：

```bash
# 设置 Obsidian 路径
export OBSIDIAN_VAULT="D:/your-obsidian-vault"

# 同步 playbook 到 Obsidian
bash ~/.agents/skills/develop-flow/obsidian/sync-playbook-to-obsidian.sh

# 从 Obsidian 同步回 playbook
bash ~/.agents/skills/develop-flow/obsidian/sync-obsidian-to-playbook.sh
```

详见 `skills/develop-flow/obsidian/OBSIDIAN-SETUP.md`。

## 配置架构（2 层）

```
Layer 1: 流程配置    ~/.agents/skills/develop-flow/project-config.md
Layer 2: 项目配置    {root_path}/.develop-flow/project-config.md
```

**project-config.md 配置项**：

| 配置项 | 必填 | Phase 用途 |
|--------|------|-----------|
| `root_path` | ✅ | Phase 0 确定项目根目录 |
| `tech_stack` | ✅ | Phase 1 理解技术栈、Phase 3 选择构建命令 |
| `modules` | ✅ | Phase 1 理解模块结构、Phase 2 任务拆分 |
| `git.main_branch` | ✅ | Phase 6 收尾 |
| `openspec.changes_path` | ✅ | 所有 Phase 的产出目录 |
| `build_commands` | ⬜ | Phase 3 构建 |
| `migration` | ⬜ | Phase 3 数据库迁移 |
| `databases` | ⬜ | Phase 1, 3 数据库操作 |
| `test_environments` | ⬜ | Phase 5 测试 |

## 异常处理

统一重试限制——无无限重试：

| 异常 | 限制 | 升级方式 |
|------|------|---------|
| 构建失败 | 2 次重试 | 询问用户 |
| 测试 Bug 修复 | 3 次循环 | 询问用户 |
| Agent 上下文耗尽 | 1 次替换 | 询问用户 |

## 关键约束

- **Leader 绝不写业务代码** — 只 `Read`、`SendMessage`、`TaskCreate/Update`、`AskUserQuestion`
- **Leader 唯一允许写入**: `{root_path}/.develop-flow/{task_id}-state.json`（断点恢复）
- **Agent 无状态** — 所有上下文来自任务描述或 Leader 消息
- **基于证据的验证** — 无证据不声称完成
- **纯后端** — 不涉及前端页面开发
- **需求来源**: 飞书文档或文字描述（非 Jira）

## 贡献

- Skills 在 `skills/<name>/` 中，`skill.md`（或 `SKILL.md`）为入口
- 使用 frontmatter 元数据（`name`、`description`、`version`、`tags`）
- Agent 定义在 `agents/<role>.md` — 包含角色描述、工具、约束、输出格式
- 保持指令清晰无歧义——Agent 按字面理解
- 无硬编码路径、凭证或公司特定引用
- 提交前用真实需求端到端测试
