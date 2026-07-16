[English](README.md) | **中文**

# Develop-Flow: 纯后端全链路 Agent Team 开发工作流

一个 [OpenCode](https://opencode.ai) skill，协调多 Agent 团队处理完整的后端开发生命周期：需求分析、架构设计、任务规划、TDD 开发、代码评审和测试验证。

需求来源为飞书文档或文字描述（非 Jira），纯后端开发，不涉及前端页面。

```
需求输入 → 6 阶段 + 6 Gate → 代码就绪（待 commit）

Phase 0: 预检       → 依赖检查 + 经验注入（learn apply）
Phase 1: 需求分析   → proposal.md + design.md
Phase 2: 任务规划   → tasks.md
Phase 3: TDD 开发   → 实现代码
Phase 4: 代码评审   → 结构化评审报告
Phase 5: 测试验证   → 基于证据的测试报告
Phase 6: 收尾       → 清理 + 总结 + 学习沉淀（learn capture）
```

每个 Phase 结束时有一个 **Gate** — Leader 汇总 Phase 产出供确认后再继续。两种模式：**半自动**（默认，你确认每个 Gate）或 **全自动**（Gate 自动通过，仅异常时暂停）。

## 学习闭环（Learn）

develop-flow 内置学习机制，**自动积累经验，跨项目复用**：

```
每次 run 结束 → 自动捕获信号 → 沉淀经验 → 下次自动注入
```

### 工作原理

| 阶段 | 自动/手动 | 说明 |
|------|----------|------|
| **capture** | ✅ 自动 | Phase 6 结束后，自动记录本次 run 的信号（Gate 失败、用户纠正等） |
| **apply** | ✅ 自动 | Phase 0 开始时，自动读取历史经验注入当前任务 |
| **distill** | ⚠️ 提醒后手动 | 累积 5 条信号后提醒，执行后聚类信号→更新知识库 |

### 知识库位置

| 文件 | 位置 | 说明 |
|------|------|------|
| `playbook.md` | `~/.agents/skills/develop-flow/` | 全局经验（跨项目通用，自动成长） |
| `knowledge.md` | `{项目}/.develop-flow/` | 项目级经验（该项目专属） |
| `lessons-*.jsonl` | `{项目}/.develop-flow/{task_id}/` | 原始信号（每次 run 一个文件） |

### 手动命令

```bash
# 记录手动笔记
/develop-flow learn 这个需求需要注意数据库索引性能

# 提炼经验（累积 5 条后执行）
/develop-flow learn --upgrade
```

## 架构

- **Leader**（主会话）协调、决策、路由——绝不直接执行
- **Hub-and-Spoke** 通信：所有 Agent 消息经 Leader 路由
- **6 个专业 Agent** 按需 spawn
- **Superpowers 方法论** 集成到每个 Phase

## 前置条件

| 依赖 | 版本 | 安装方式 |
|------|------|---------|
| **OpenCode CLI** | 最新 | [OpenCode 文档](https://opencode.ai) |
| **superpowers** 插件 | >= 5.0.0 | 已包含在 OpenCode skills 中 |

## 安装

```bash
# 1. 克隆
git clone <repo-url> develop-flow
cd develop-flow

# 2. 安装（复制 skills + agents 到 ~/.agents/）
chmod +x install.sh
./install.sh

# 3. 验证
ls ~/.agents/skills/develop-flow/      # 应显示 skill.md, phases/ 等
ls ~/.agents/agents/requirements-analyst.md  # 应存在
```

> **Windows 用户**: 脚本会自动检测 Windows 环境，使用复制代替符号链接。

### 卸载

```bash
./uninstall.sh
```

仅移除符号链接。克隆的仓库保留。

## 快速开始

### 步骤 1: 初始化项目

```
/init-flow
```

一键设置——自动检测技术栈、生成配置文件、验证依赖。

或手动：复制 `skills/develop-flow/project-config.example.md` 到 `<项目根>/.develop-flow/project-config.md` 并填入值。

### 步骤 2: 配置 MCP（可选但推荐）

MCP（Model Context Protocol）让 AI 能直接操作数据库、Redis 等服务。

#### 自动配置（推荐）

**Windows CMD：**
```cmd
cd D:\project\A--other\develop-flow
scripts\setup-mcp.bat D:\project\178-builder.env
```

**Windows PowerShell：**
```powershell
cd D:\project\A--other\develop-flow
.\scripts\setup-mcp.bat D:\project\178-builder.env
```

**Git Bash 或 Linux/Mac：**
```bash
cd /d/project/A--other/develop-flow
./scripts/setup-mcp.sh /d/project/178-builder.env
```

执行成功后会显示：
```
=== Configuration Complete ===
Environment variables are ready. You can now start opencode:
  opencode
```

然后启动 opencode：
```cmd
opencode
```

> 详细配置说明见 [docs/mcp-setup.md](docs/mcp-setup.md)

### 步骤 3: 运行 develop-flow

```bash
# 执行开发流程（会自动 git pull）
/develop-flow 用户认证模块需要支持 JWT 和 refresh token
```

或提供飞书文档内容：

```
/develop-flow 以下是飞书文档的需求内容：...
```

### 步骤 4: 审查 Gate 并迭代

Leader 在每个 Gate 展示摘要。半自动模式（默认）确认后继续。全自动模式自动通过——仅异常暂停。

## Agent 定义

### 核心 Agent（工作流必须）

| Agent | 阶段 | 用途 |
|-------|------|------|
| `requirements-analyst` | 1, 6 | 分析需求、生成 proposal、生成总结 |
| `architect` | 1 | 生成 design.md 和架构决策 |
| `planner` | 2 | 拆分为 TDD 任务 |
| `backend-developer` | 2, 3 | 实现后端代码 |
| `code-reviewer` | 4 | 评审分支变更并分级 |
| `tester` | 5 | 运行测试并报告 Bug |

### 辅助 Agent（独立使用或按需调用）

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

## 配置

```
~/.agents/skills/develop-flow/project-config.md     ← 流程配置（root_path、产出路径）
<项目根>/.develop-flow/project-config.md             ← 项目配置（技术栈、数据库、测试环境）
~/.config/opencode/opencode.json                     ← OpenCode MCP 配置
~/.config/opencode/env.bat                           ← 环境变量（Windows）
~/.config/opencode/env.sh                            ← 环境变量（Linux/Mac）
```

### project-config.md 配置项详解

**配置层次**：
- `~/.agents/skills/develop-flow/project-config.md` — 流程配置（每机一份）
- `{root_path}/.develop-flow/project-config.md` — 项目配置（每项目一份）

**配置项说明**：

| 配置项 | 必填 | Phase 用途 | 示例 |
|--------|------|-----------|------|
| `root_path` | ✅ | Phase 0 确定项目根目录 | `"D:\project\AA-SAAS\builder-labor"` |
| `tech_stack` | ✅ | Phase 1 理解技术栈、Phase 3 选择构建命令 | `{ backend: "java/spring", database: "postgresql" }` |
| `modules` | ✅ | Phase 1 理解模块结构、Phase 2 任务拆分 | 见下方示例 |
| `git.main_branch` | ✅ | Phase 6 收尾 | `"master"` |
| `openspec.changes_path` | ✅ | 所有 Phase 的产出目录 | `"openspec/changes"` |
| `openspec.baseline_path` | ⬜ | Phase 1 基线文档参考 | `"openspec/specs"` |
| `build_commands` | ⬜ | Phase 3 构建 | `{ full_build: "mvn clean install" }` |
| `migration` | ⬜ | Phase 3 数据库迁移 | `{ type: "flyway", steps: [...] }` |
| `databases` | ⬜ | Phase 1, 3 数据库操作 | `{ main: { mcp: "mcp__xxx__query" } }` |
| `test_environments` | ⬜ | Phase 5 测试 | `{ default: { url: "...", account: "..." } }` |

**自动检测**：执行 `/init-flow` 时会自动检测技术栈、仓库结构、Git 主分支等，生成初始配置。

> 详细 MCP 配置说明见 [docs/mcp-setup.md](docs/mcp-setup.md)

## 目录结构

```
develop-flow/
├── README.md                        ← 主文档（英文）
├── README.zh-CN.md                  ← 中文文档
├── CLAUDE.md                        ← 架构指南
├── AGENTS.md                        ← Agent 快速参考
├── install.sh                       ← 一键安装
├── uninstall.sh                     ← 卸载
├── docs/                            ← 文档目录
│   └── mcp-setup.md                 ← MCP 配置指南
├── scripts/                         ← 脚本目录
│   ├── setup-mcp.bat                ← Windows MCP 配置
│   ├── setup-mcp.sh                 ← Linux/Mac MCP 配置
│   └── check-install.sh             ← 安装检查
├── templates/                       ← 模板目录
│   └── opencode-mcp.json            ← MCP 配置模板
├── skills/                          ← Skills 目录
│   ├── develop-flow/                ← 主 skill（6 阶段生命周期）
│   │   ├── skill.md                 ← 工作流骨架 + 初始化
│   │   ├── gate.md                  ← Gate 机制 + 通过标准
│   │   ├── phases/                  ← Phase 指令（按需加载）
│   │   │   ├── phase-1-brief.md     ← 需求分析
│   │   │   ├── phase-2-brief.md     ← 任务规划
│   │   │   ├── phase-3-brief.md     ← TDD 开发
│   │   │   ├── phase-4-brief.md     ← 代码评审
│   │   │   ├── phase-5-brief.md     ← 测试验证
│   │   │   └── phase-6-brief.md     ← 收尾
│   │   ├── learn/                   ← 学习闭环子 skill
│   │   │   ├── SKILL.md             ← 学习闭环定义
│   │   │   ├── knowledge-format.md  ← 知识格式
│   │   │   └── distill-protocol.md  ← 提炼协议
│   │   ├── obsidian/                ← Obsidian 集成脚本
│   │   │   ├── sync-playbook-to-obsidian.sh  ← playbook → Obsidian
│   │   │   ├── sync-obsidian-to-playbook.sh  ← Obsidian → playbook
│   │   │   └── OBSIDIAN-SETUP.md    ← Obsidian 配置指南
│   │   ├── playbook.md              ← 全局经验（跨项目，自动成长）
│   │   ├── team-rules.md            ← 团队通信规则
│   │   ├── resume.md                ← 断点恢复逻辑
│   │   └── project-config.example.md ← 配置模板
│   ├── init-flow/                   ← 项目初始化 skill
│   ├── create-team/                 ← 团队创建
│   └── delete-team/                 ← 团队清理
└── agents/                          ← Agent 定义
    ├── requirements-analyst.md
    ├── architect.md
    ├── planner.md
    ├── backend-developer.md
    ├── code-reviewer.md
    └── tester.md
```

## 异常处理

| 异常 | 自动修复限制 | 升级方式 |
|------|------------|---------|
| 构建失败 | 2 次重试 | 询问用户 |
| 测试 Bug 修复 | 3 次循环 | 询问用户 |
| 需求/设计问题 | 2 次重新 Gate | 询问是否终止 |
| Agent 无响应 | 1 次重发 | 询问用户 |
| Agent 上下文耗尽 | 1 次替换 | 询问用户 |

所有异常超限升级给用户。无无限重试。

## 核心原则

- **Leader 绝不执行** — 只协调、决策和路由
- **Hub-and-Spoke 通信** — 所有 Agent 消息经 Leader
- **Gate 检查点** — 每个 Phase 结束用户确认
- **基于证据的验证** — 无证据不声称完成
- **断点恢复** — 每个 Phase 后保存状态，随时恢复

## 常见问题

### MCP 相关

**Q: MCP 服务器启动失败怎么办？**

A: 检查以下几点：
1. Node.js 和 npm 是否已安装（`node -v`, `npm -v`）
2. 网络是否能访问 npm registry
3. 环境变量是否正确设置（`echo %POSTGRES_HOST%`）

**Q: 如何禁用某个 MCP 服务器？**

A: 在 `opencode.json` 中设置 `"enabled": false`：
```json
{
  "mcp": {
    "postgresql": {
      "enabled": false
    }
  }
}
```

**Q: 如何查看 MCP 连接日志？**

A: 使用调试命令：
```bash
opencode mcp debug postgresql
```

**Q: 项目配置文件中的 `${}` 变量如何处理？**

A: opencode 使用 `{env:VAR_NAME}` 语法引用环境变量。确保：
1. 环境变量文件已正确创建
2. 启动 opencode 前已加载环境变量

### Git 相关

**Q: develop-flow 执行前 git pull 失败怎么办？**

A: 检查：
1. Git 远程仓库配置是否正确
2. SSH 密钥或 HTTPS 凭据是否有效
3. 是否有未解决的合并冲突

### 配置相关

**Q: 如何切换不同环境（172/178）？**

A: 运行对应的配置脚本：
```bash
# 切换到 172 环境
scripts\setup-mcp.bat D:\project\172-builder.env

# 切换到 178 环境
scripts\setup-mcp.bat D:\project\178-builder.env
```

切换后需重新加载环境变量。

**Q: 配置文件在哪里？**

A: 关键配置文件位置：
- OpenCode 全局配置：`~/.config/opencode/opencode.json`
- 环境变量：`~/.config/opencode/env.bat`（Windows）
- 项目配置：`{project}/.develop-flow/project-config.md`
- 流程配置：`~/.agents/skills/develop-flow/project-config.md`
- MCP 配置指南：`docs/mcp-setup.md`

## 许可证

[MIT](LICENSE)
