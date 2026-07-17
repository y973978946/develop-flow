---
name: develop-flow
description: 当用户提供飞书文档链接、需求文字描述或需求图片时，执行完整的后端开发生命周期——需求分析、架构设计、任务规划、TDD 开发、代码评审、测试验证。适用于纯后端项目，不涉及前端页面开发。
version: 1.0.1
tags: [workflow, team, tdd, code-review, agent-orchestration, backend]
dependencies:
  skills:
    - create-team
    - delete-team
    - init-flow
  plugins:
    - superpowers >= 5.0.0
  agents:
    - requirements-analyst
    - architect
    - planner
    - backend-developer
    - code-reviewer
    - tester
  mcp_servers: []
  project_config: true
---

# Develop-Flow: 纯后端全链路 Agent Team 开发工作流

**输入**: `$ARGUMENTS`（飞书文档链接、需求文字描述、或需求图片路径）

---

## ⚠️ 强制执行规则（必须遵守）

### 规则 1：收到需求时必须先执行 Phase 流程

**禁止直接跳到写代码阶段！** 必须按以下顺序执行：

```
1. Phase 0: 预检 + 解析配置
2. Phase 1: 需求分析 → 产出 proposal.md + design.md
3. Phase 2: 任务规划 → 产出 tasks.md
4. Phase 3: TDD 开发 → 先写测试再实现
5. Phase 4: 代码评审
6. Phase 5: 测试验证
7. Phase 6: 收尾
```

每个 Phase 开始前必须 Read `phases/phase-N-brief.md` 获取完整指令。

### 规则 2：每个 Phase 必须产出对应文档

| Phase | 必须产出 |
|-------|----------|
| 1 | `{changes_path}/{spec_name}/proposal.md` |
| 1 | `{changes_path}/{spec_name}/design.md` |
| 2 | `{changes_path}/{spec_name}/tasks.md` |
| 3 | 代码文件 + 测试文件 |
| 4 | 评审报告（检查点形式） |
| 5 | 测试报告 |
| 6 | 总结报告 |

---

> **图片输入限制**: 当前 AI 模型可能不支持图片输入。如果用户提供了图片，Leader 应提示：
> "当前模型不支持直接读取图片。请将图片中的需求内容以文字形式描述给我，或者将图片内容粘贴为文字。"
> 然后继续处理文字形式的需求。

## Leader 约束

> Leader（主会话）绝不直接执行任何操作——只负责协调、决策和状态推进。
> 所有执行通过 SendMessage 委派。Read 允许用于理解和加载 Phase 指令。
> 严禁 Agent 间直接通信，所有通信必须经过 Leader 路由。

**允许**: Read, SendMessage, TaskCreate/TaskUpdate, AskUserQuestion, /create-team, /delete-team
**允许写入**: 仅 `{root_path}/.develop-flow/{task_id}-state.json`（断点恢复状态文件）
**禁止**: Write（业务代码）, Edit, Bash
**禁止持有**: 源代码、diff、完整设计内容、需求原文、队友执行日志

## Superpowers 集成

> 每个 Phase 引用 superpowers 方法论。Leader 用 `[superpowers:xxx]` 标注委派指令。
> 收到的 Agent 应先 Read 对应 SKILL.md 获取完整方法论。

| Phase | Superpowers 技能 |
|-------|-----------------|
| 1 需求分析 | brainstorming |
| 2 任务规划 | writing-plans |
| 3 TDD 开发 | test-driven-development + executing-plans |
| 4 代码评审 | requesting-code-review |
| 5 测试验证 | verification-before-completion |
| 6 收尾 | finishing-a-development-branch |
| 异常处理 | systematic-debugging |

## 运行模式

| 行为 | 半自动（默认） | 全自动 |
|------|---------------|--------|
| Gate | 展示摘要 + AskUserQuestion 确认 | 自动通过，记录摘要不打断 |
| Phase 1 检查点 | **交互式** — 检查点 A/B 需用户确认 | 自动通过所有检查点 |
| 异常 | 所有异常提示用户 | 仅重试耗尽时提示 |

## 文件结构

```
~/.agents/skills/develop-flow/
├── skill.md                    ← 本文件（工作流骨架）
├── gate.md                     ← Gate 机制 + 通过标准 + 摘要格式
├── phases/                     ← Phase 指令（按需加载）
│   ├── phase-1-brief.md
│   ├── phase-2-brief.md
│   ├── phase-3-brief.md
│   ├── phase-4-brief.md
│   ├── phase-5-brief.md
│   └── phase-6-brief.md
├── project-config.md           ← develop-flow 流程配置
├── project-config.example.md   ← 项目配置示例
├── team-rules.md               ← 团队通信规则 + 项目上下文
└── resume.md                   ← 断点恢复逻辑

~/.agents/agents/               ← Agent 定义文件
├── requirements-analyst.md
├── architect.md
├── planner.md
├── backend-developer.md
├── code-reviewer.md
└── tester.md

<project-root>/
├── .develop-flow/              ← 工作状态目录
│   └── {task_id}-state.json    ← 断点恢复状态
└── openspec/                   ← 工作产出目录
    └── changes/                ← 需求变更产出
```

## 配置架构

```
查找链: develop-flow/project-config.md → root_path → {root_path}/.develop-flow/project-config.md

流程配置（~/.agents/skills/develop-flow/project-config.md）
  └── develop-flow 工作流设置：root_path、需求产出路径

项目配置（{root_path}/.develop-flow/project-config.md）
  └── 完整项目信息：技术栈、数据库、构建命令、测试环境等
  └── 含敏感信息——应加入 .gitignore
```

---

## 初始化

### 0. 预检

验证以下依赖就绪。汇总缺失项并提示用户安装/配置——不自动安装：

1. 必需技能：`create-team`、`delete-team`、`learn` 存在于 `~/.agents/skills/`
2. Superpowers 插件已安装（≥5.0.0）
3. Agent 定义存在于 `~/.agents/agents/`：
   - requirements-analyst, architect, planner（核心团队）
   - backend-developer（开发团队）
   - code-reviewer, tester（评审/测试团队）
4. **ripgrep 检测**：检查 `rg` 命令是否可用
   - 如果不可用，运行 `python ~/.agents/skills/develop-flow/scripts/install_ripgrep.py` 自动安装
   - 如果自动安装失败，提示用户手动安装
5. 清理：`{changes_path}` 下的空目录。委派给首个可执行 Bash 的 Agent 运行 `find {changes_path} -type d -empty -delete`。
→ 全部就绪 → 继续

### 1. 解析 + 配置

1. 从 `$ARGUMENTS` 解析需求来源：
   - 飞书文档链接 → 提示用户提供文档内容（当前不支持直接抓取飞书）
   - 文字描述 → 直接使用
   - 图片 → 提示用户转为文字（见上方图片输入限制）
2. Read `develop-flow/project-config.md` → 获取 `root_path`
   - `root_path` 非空 → 使用
   - `root_path` 为空 → 提示用户先运行 `/init-flow`
3. Read `{root_path}/.develop-flow/project-config.md` → 获取完整项目配置
   - 存在：使用
   - 不存在：提示用户运行 `/init-flow` 初始化项目配置
4. 断点检测：检查 `{root_path}/.develop-flow/{task_id}-state.json`
   - 存在：Read `resume.md` 执行断点恢复
   - 不存在：继续
5. AskUserQuestion：半自动（推荐）/ 全自动

### 1.5 Phase 变量替换

Leader 进入每个 Phase 时 Read phase-N-brief.md。任何 `{variable}` 占位符在构造委派消息前替换：

| 变量 | 来源 | 说明 |
|------|------|------|
| `{task_id}` | 自动生成 | 任务标识，基于时间戳或需求简称 |
| `{changes_path}` | develop-flow/project-config.md → openspec.changes_path | 工作产出目录 |
| `{baseline_path}` | develop-flow/project-config.md → openspec.baseline_path | 系统基线目录（可选） |
| `{spec_name}` | Phase 1 产出 | 需求目录名 |
| `{repo_path}` | project-config.md → backend.main_repo | 后端仓库路径 |
| `{root_path}` | develop-flow/project-config.md → root_path | 项目根目录 |

**配置引用约定**：phase brief 中"参考 project-config.md → xxx"始终指 `{root_path}/.develop-flow/project-config.md`（项目配置）。

### 2. 创建核心团队

调用 `/create-team` 编程式模式，传入以下 JSON：

```json
{
  "team_name": "develop-flow-{task_id}",
  "roles": [
    {"name": "requirements-analyst", "agent": "requirements-analyst"},
    {"name": "architect", "agent": "architect"},
    {"name": "planner", "agent": "planner"}
  ],
  "custom_prompt": "<team-rules.md 内容（变量已替换）>"
}
```

按需扩容（Gate 1 后 / Phase 4 前 / Phase 5 前）：

| 时机 | 创建的角色 | 决策依据 |
|------|-----------|---------|
| Phase 0 | requirements-analyst, architect, planner | 固定核心团队 |
| Gate 1 后 | backend-developer | 设计涉及后端开发 |
| Phase 4 前 | code-reviewer | 固定新增 |
| Phase 5 前 | tester | 固定新增 |

---

## Phase 概要

> 进入 Phase 时 Read `phases/phase-N-brief.md` 获取完整指令。
> 执行 Gate 时 Read `gate.md` 获取通过标准和摘要格式。

| Phase | 产出 | Gate |
|-------|------|------|
| 1 需求分析（交互式） | proposal.md + design.md（4 步骤 + 检查点 A/B/C） | 确认 → spawn 开发 Agent |
| 2 任务规划 | tasks.md | 确认任务列表 |
| 3 TDD 开发 | 实现代码 | 确认进度 |
| 4 代码评审 | 评审报告 | CRITICAL/HIGH → 修复 |
| 5 测试验证 | 测试报告 | 确认测试通过 |
| 6 收尾 | 清理 + 总结 | 最终总结 |

---

## 异常处理

所有异常流：队友 → Leader → Leader 评估 → Leader 转发给合适角色。

### 统一重试限制

| 异常类型 | 自修复尝试 | 超限动作 |
|---------|-----------|---------|
| 构建失败 | 开发自修 ≤2 次 | Leader 询问用户 |
| 测试 Bug 修复 | tester→dev 循环 ≤3 次 | Leader 询问用户 |
| 需求/设计问题 | 修改并重新 Gate ≤2 次 | Leader 询问是否终止 |
| 任务冲突 | Planner 重新排序 ≤1 次 | Leader 决定串行化 |
| Agent 无响应 | 重发消息 1 次 | Leader 询问用户 |
| Agent 上下文耗尽 | 替换 Agent ≤1 次 | Leader 询问用户 |

任何异常超限 → Leader 必须升级给用户；不继续自动重试。

### 等待与超时

Leader 等待 Agent 回复时的行为：
- **正常等待**：Agent 执行任务期间，Leader 待命（无硬超时）
- **无响应检测（Level 1）**：Agent 在预期时间内未回复（Phase 1-2: 5 分钟；Phase 3-5: 10 分钟），Leader 发送 ping
- **上下文耗尽检测（Level 2）**：ping 未回复且 Agent 最后消息 >15 分钟 → 判定 context_exhausted
- **Agent 主动报告阻塞**：非超时——走正常异常路径

### Leader 上下文保护

每个 Gate 通过后：
1. 持久化 Gate 摘要到 state.json
2. 执行 `/compact` 压缩 Leader 自身上下文
3. 若 `/compact` 导致近期上下文丢失 → Read state.json 恢复
