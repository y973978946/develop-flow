**English** | [中文](develop-flow-training.zh-CN.md)

# Develop-Flow 培训指南

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

### 两种运行模式

| 特性 | 半自动（默认） | 全自动 |
|------|---------------|--------|
| Gate | 展示摘要 + 用户确认 | 自动通过，记录摘要 |
| 异常 | 所有异常询问用户 | 仅超限询问用户 |
| 适用场景 | 复杂需求、首次使用 | 简单需求、有经验用户 |

---

## 2. 架构深入

### Hub-and-Spoke 模式

```
                    ┌──────────┐
                    │   用户   │
                    └────┬─────┘
                         │ /develop-flow <需求>
                    ┌────▼─────┐
                    │  Leader  │ ← 协调器（绝不执行操作）
                    └────┬─────┘
                         │ SendMessage
              ┌──────────┼──────────┐
         ┌────▼────┐ ┌──▼────┐ ┌──▼──────┐
         │核心团队 │ │开发   │ │评审     │
         │         │ │团队   │ │团队     │
         └─────────┘ └───────┘ └─────────┘
```

**关键原则**:
- Leader **绝不直接执行**任何操作
- Leader 只负责协调、决策和状态管理
- 所有 Agent 间通信**必须经 Leader 路由**
- Agent **严禁直接通信**

### 6 个 Agent 角色（核心）

| Agent | 模型 | 创建时机 | 职责 |
|-------|------|---------|------|
| requirements-analyst | Opus | Phase 0 | 分析需求、生成 proposal |
| architect | Opus | Phase 0 | 架构设计、生成 design.md |
| planner | Opus | Phase 0 | 任务拆分、TDD 步骤规划 |
| backend-developer | Sonnet | Gate 1 后 | 后端代码实现 |
| code-reviewer | Sonnet | Phase 4 前 | 代码评审并分级 |
| tester | Sonnet | Phase 5 前 | 测试验证、Bug 报告 |

### 按需扩展策略

并非所有 Agent 一开始就创建：

```
Phase 0: 核心团队 (requirements-analyst + architect + planner)
  ↓
Gate 1: 确认设计涉及后端
  ↓
Gate 1 后: 创建 backend-developer
  ↓
Phase 4 前: 创建 code-reviewer
  ↓
Phase 5 前: 创建 tester
```

**为什么？** 资源效率——按需创建，每个 Agent 有明确生命周期。

---

## 3. Phase 详情

### Phase 0: 初始化

**发生什么**:
1. 前置检查（依赖 skills、superpowers 插件、agent 定义）
2. 解析需求来源（飞书文档/文字/图片）
3. 加载配置
4. 断点检测（检查未完成工作流）
5. 选择运行模式（半自动/全自动）
6. 创建核心团队

**产出**: 配置就绪 + 核心团队创建

---

### Phase 1: 需求分析

**参与者**: requirements-analyst → architect

**流程**:
```
requirements-analyst:
  1. 分析需求内容（飞书文档/文字描述）
  2. 提出 2-3 个实现方案（含权衡分析）
  3. 提供推荐方案及理由
  4. 基线关联检查（如有 baseline_path）
  5. Spec 自查（占位符、一致性、范围、歧义）
  6. 产出: proposal.md

architect:
  1. Read proposal.md
  2. 探索相关代码架构
  3. 设计模块分解（单一职责、清晰接口）
  4. 设计自查
  5. 产出: design.md + 关键设计决策
```

**产出**: `proposal.md` + `design.md`

**Gate 1 通过标准**:
- proposal.md + design.md 无占位符（TBD/TODO）
- 内部一致（各部分无矛盾）
- 受影响模块明确标识

---

### Phase 2: 任务规划

**参与者**: planner

**流程**:
```
planner:
  1. Read design.md
  2. 拆分为小任务（每步 2-5 分钟）
  3. 每个任务包含 TDD 步骤:
     RED(写失败测试) → Verify RED → GREEN(最小实现) → Verify GREEN → REFACTOR
  4. 创建 tasks.md + TaskCreate 跟踪条目
  5. 标记 blockedBy 依赖
```

**产出**: `tasks.md`

**Gate 2 通过标准**:
- tasks.md 无占位符
- 每步有文件路径和命令
- blockedBy 依赖正确

---

### Phase 3: TDD 开发

**参与者**: backend-developer

**核心原则——TDD 纪律**:
> 绝不在没有失败测试的情况下写生产代码。先写测试——永远！

**流程**:
```
对每个任务:
  1. RED:    写最小测试描述预期行为
  2. Verify: 运行并确认失败（缺失功能，非语法错误）
  3. GREEN:  写最少代码让测试通过
  4. Verify: 运行并确认通过，无其他测试回归
  5. REFACTOR: 清理（去重、改善命名、提取辅助函数）
```

**产出**: 实现代码 + 测试代码

**Gate 3 通过标准**:
- 所有任务状态为 completed
- 测试通过

---

### Phase 4: 代码评审

**参与者**: code-reviewer

**流程**:
```
code-reviewer:
  1. git diff 结构化评审（不依赖记忆）
  2. 严重性分级:
     CRITICAL: 安全漏洞 / 数据丢失风险 → 阻断合并
     HIGH: Bug 或重大质量问题 → 修复后合并
     MEDIUM: 可维护性问题 → 建议修复
     LOW: 风格或小建议 → 可选
  3. 每个问题: 文件路径:行号 + 问题描述 + 修复建议
```

**产出**: 评审报告（按 C/H/M/L 分级）

**Gate 4 通过标准**:
- 无 CRITICAL 问题
- 无未解决 HIGH 问题
- 如有 → 开发修复，code-reviewer 重评

---

### Phase 5: 测试验证

**参与者**: tester

**核心原则——证据纪律**:
> 任何完成声明必须有即时可验证的证据。不要说"应该能用了"！

**流程**:
```
tester:
  1. Read proposal.md + tasks.md
  2. 运行测试套件（单元 + 集成）
  3. 数据库验证（通过 MCP 查询）
  4. 每项验证提供: 命令 + 输出摘要 + 退出码
  5. Bug 报告: 复现步骤 + 预期 + 实际 + 证据
```

**Bug 修复循环**（全经 Leader 路由）:
```
tester 发现 Bug → Leader → Leader 判断归属 → 开发修复 → Leader → tester 复验
→ 未通过 → 再来一轮（≤3 次）→ 仍失败 → Leader 询问用户
```

**产出**: 测试报告

**Gate 5 通过标准**:
- 所有测试通过
- 无未修复 Bug

---

### Phase 6: 收尾

**参与者**: requirements-analyst

**流程**:
```
1. 确认所有任务完成
2. 代码变更已在工作目录（未 commit）
3. 生成开发总结报告
4. 清理团队
```

**产出**: 清理完成 + 总结报告

**Gate 6 通过标准**:
- 工作流完成
- 状态已清理

---

## 4. 配置系统

### 两层配置架构

```
Layer 1: 流程配置
  ~/.agents/skills/develop-flow/project-config.md
  → develop-flow 工作流设置（root_path、产出路径）

Layer 2: 项目配置
  {root_path}/.develop-flow/project-config.md
  → 完整项目信息（技术栈、数据库、测试环境、构建命令）
```

### 查找链

```
develop-flow/project-config.md → root_path
  → {root_path}/.develop-flow/project-config.md → 完整配置
```

### 关键配置字段

```yaml
# develop-flow/project-config.md
root_path: ""                    # 项目根路径
openspec:
  changes_path: "openspec/changes"   # 工作产出目录
  baseline_path: "openspec/specs"    # 系统基线（可选）

# project-config.md
tech_stack:
  backend: "laravel"             # 后端技术栈
  database: "mysql"              # 数据库
databases:                       # 数据库连接
  main: { mcp: "mcp__xxx__mysql_query" }
test_environments:               # 测试环境
  default: { url: "https://..." }
build_commands:                  # 构建命令
  backend: "php artisan"
migration:                       # 迁移命令
  steps: ["php artisan migrate --force"]
```

---

## 5. Superpowers 集成

每个 Phase 引用一个 Superpowers 方法论技能。Agent 在运行时读取对应的 SKILL.md 获取完整方法论。

| Phase | Superpowers 技能 | 核心约束 |
|-------|-----------------|---------|
| 1 需求分析 | brainstorming | 2-3 方案 + 权衡 + 自查 |
| 2 任务规划 | writing-plans | 小粒度 + TDD 步骤 + 零占位符 |
| 3 TDD 开发 | TDD + executing-plans | RED→Verify→GREEN→Verify→REFACTOR |
| 4 代码评审 | requesting-code-review | git diff + 严重性分级 |
| 5 测试验证 | verification | 证据纪律: 命令→输出→结论 |
| 6 收尾 | finishing-a-branch | 全量测试 → 清理 |
| 异常处理 | systematic-debugging | 先复现 → 根因 → 最小修复 |

---

## 6. 异常处理

### 统一重试限制

| 异常类型 | 自修复限制 | 超限动作 |
|---------|-----------|---------|
| 构建失败 | 开发 ≤2 次 | Leader 询问用户 |
| 测试 Bug | 循环 ≤3 次 | Leader 询问用户 |
| 需求/设计问题 | 重新 Gate ≤2 次 | Leader 询问是否终止 |
| 任务冲突 | planner 重排 ≤1 次 | Leader 串行化 |
| Agent 无响应 | 重发 1 次 | Leader 询问用户 |
| Agent 上下文耗尽 | 替换 1 次 | Leader 询问用户 |

### 超时检测

- Phase 1-2: Agent 5 分钟未响应 → Leader 发送 ping
- Phase 3-5: Agent 10 分钟未响应 → Leader 发送 ping
- ping 未回复 → Leader 询问用户: 等待 / 跳过 / 终止

---

## 7. 文件结构

```
~/.agents/skills/
├── develop-flow/
│   ├── skill.md                    ← 工作流骨架
│   ├── gate.md                     ← Gate 机制
│   ├── phases/                     ← Phase 指令（按需加载）
│   │   ├── phase-1-brief.md
│   │   ├── phase-2-brief.md
│   │   ├── phase-3-brief.md
│   │   ├── phase-4-brief.md
│   │   ├── phase-5-brief.md
│   │   └── phase-6-brief.md
│   ├── project-config.md           ← 流程配置
│   ├── project-config.example.md   ← 配置模板
│   ├── team-rules.md               ← 团队通信规则
│   └── resume.md                   ← 断点恢复逻辑
├── create-team/                    ← 团队创建
├── delete-team/                    ← 团队清理
└── init-flow/                      ← 一键初始化

~/.agents/agents/                   ← 15 个 Agent 定义
├── requirements-analyst.md
├── architect.md
├── planner.md
├── backend-developer.md
├── code-reviewer.md
├── tester.md
├── build-error-resolver.md
├── code-explorer.md
├── code-simplifier.md
├── database-reviewer.md
├── performance-optimizer.md
├── security-reviewer.md
├── doc-updater.md
├── refactor-cleaner.md
└── tdd-guide.md
```

**懒加载设计**: Leader 只在进入对应 Phase 时才 Read phase-N-brief.md，最小化上下文占用。

---

## 8. 快速开始

### 1. 安装依赖

确保以下就绪:
- OpenCode CLI
- superpowers 插件 (v5.0+)
- 依赖 skills: create-team, delete-team, init-flow
- Agent 定义: 15 个 agents 在 `~/.agents/agents/`

### 2. 初始化

```
/init-flow
```

一键设置: 自动检测技术栈、生成配置、验证依赖。

### 3. 运行

```
/develop-flow 用户认证模块需要支持 JWT 和 refresh token
```

或提供飞书文档内容:
```
/develop-flow 以下是飞书文档的需求内容：...
```

### 4. 交互

半自动模式下，每个 Gate 展示摘要并等待确认:
- 确认 → 继续下一 Phase
- 修改 → Leader 转发修改指令
- 终止 → 清理团队，工作流结束

---

## 9. FAQ

**Q: 为什么 Leader 不能直接执行操作？**
A: 关注点分离。Leader 只负责协调和决策；所有执行由专业 Agent 完成。确保职责清晰和操作可审计。

**Q: Agent 间任务冲突怎么办？**
A: Leader 检测冲突并使用 worktree 隔离（为每个 Agent 创建独立工作树）避免文件冲突。

**Q: 可以中途暂停吗？**
A: 可以。develop-flow 支持断点恢复。状态保存在 `{root_path}/.develop-flow/{task_id}-state.json`。重新运行会自动恢复。

**Q: 全自动模式安全吗？**
A: 全自动模式下，CRITICAL 和 HIGH 问题仍会升级给用户。Gate 质量检查仍执行——只是跳过手动确认。超限重试也会升级给用户。

**Q: 如何为新项目配置 develop-flow？**
A: 运行 `/init-flow` 一键自动检测技术栈、生成配置。也可以手动创建 `project-config.md`（参考 `project-config.example.md`）。

**Q: Superpowers 技能如何工作？**
A: 每个 Phase 引用特定的 superpowers 技能。当 Agent 收到 `[superpowers:xxx]` 标记时，先 Read 对应 SKILL.md 获取完整方法论，然后遵循那些原则。
