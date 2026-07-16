# Develop-Flow 培训指南

> 纯后端全链路 Agent Team 开发工作流 —— 从需求到代码提交

---

## 1. 概述

### 什么是 Develop-Flow？

Develop-Flow 是一个 OpenCode Skill，协调多 Agent AI 团队处理纯后端开发生命周期。需求来源为飞书文档或文字描述（非 Jira），通过 Hub-and-Spoke 模式协调多个 AI Agent，以 **6 个 Phase + 6 个 Gate** 完成：

```
需求输入 → Phase 0 预检 → Phase 1 需求分析 → Phase 2 任务规划 → Phase 3 TDD 开发 → Phase 4 代码评审 → Phase 5 测试验证 → Phase 6 收尾 → 代码就绪（待 commit）
```

### 核心价值

- **全链路自动化**：从需求到提交，无需手动切换工具
- **文档驱动**：结构化 proposal/design，Gate 是完整性 checklist
- **学习闭环**：自动积累经验，跨项目复用
- **人机协作**：半自动模式下 Gate 由用户确认
- **可恢复**：断点恢复，状态存 `.develop-flow/{task_id}-state.json`

### 两种运行模式

| 特性 | 半自动（默认） | 全自动 |
|------|--------------|--------|
| Gate | 展示 checklist 摘要 + 用户确认 | 自动放行，记录摘要 |
| Phase 1 检查点 | 交互式 — 检查点 A/B 需用户确认 | 自动通过所有检查点 |
| 异常 | 所有异常提示用户 | 仅重试耗尽时提示 |
| 适用场景 | 复杂需求、首次使用 | 简单需求、熟悉流程后 |

---

## 2. 架构详解

### Hub-and-Spoke 模式

```
                    ┌──────────┐
                    │   User   │
                    └────┬─────┘
                         │ /develop-flow <需求描述>
                    ┌────▼─────┐
                    │  Leader  │ ← 编排器（只协调，不执行业务）
                    └────┬─────┘
                         │ 触发子 skill（每阶段一个）
         ┌──────────┬────┴────┬──────────┐
     requirements  architect  planner  backend
     -analyst                -developer
         │            │          │          │
       (spawn)     (spawn)    (spawn)    (spawn)
         └────────────┴──────────┴──────────┘
                         │ SendMessage（hub-spoke）
                    各角色 Agent
```

**关键原则**：
- Leader **永不直接执行**业务操作，只协调/决策/路由（保持上下文干净）
- 所有 Agent 通信**必须经 Leader 路由**，严禁直连
- **角色专长内嵌在 skill** —— develop-flow 不读 `~/.agents/agents/*.md`

### 角色

| 角色 | 职责 | Phase |
|-------|------|-------|
| requirements-analyst | 读需求、核心章节、澄清、总结 | 1, 6 |
| architect | 工程章节、架构决策 | 1 |
| planner | tasks.md 拆分 | 2 |
| backend-developer | 建分支、实现、定稿 | 2, 3, 6 |
| code-reviewer | 评审、严重性分级 | 4 |
| tester | 测试验证、Bug 报告 | 5 |

### 按需 spawn

```
Phase 0: Core team (requirements-analyst + architect + planner)
Phase 1: requirements-analyst → architect
Phase 2: planner → backend-developer
Phase 3: backend-developer（TDD 开发）
Phase 4: code-reviewer（代码评审）
Phase 5: tester（测试验证）
Phase 6: requirements-analyst（总结）+ backend-developer（定稿）
```

---

## 3. Phase 详解

### Phase 0：预检 + 经验注入

**做什么**：
1. 预检：依赖 skill（create-team / delete-team / learn）、superpowers 插件
2. 解析输入（飞书文档 / 文字描述 / 图片）
3. 加载配置（流程配置 → 项目配置）
4. 断点检测（`.develop-flow/{task_id}-state.json` 存在则按 `resume.md` 恢复）
5. 选运行模式
6. **经验注入**：learn apply → 读 knowledge.md + playbook.md → 挑相关条目注入

**产出**：配置就绪 + 经验已注入

---

### Phase 1：需求分析（交互式）

**参与者**：requirements-analyst → architect

**流程**：
```
requirements-analyst:
  1. 读需求内容
  2. 写需求理解摘要（≤10 句话）
  3. 仅在歧义时问澄清（检查点 A）
  4. 提出 2-3 个实现方案（检查点 B）
  5. 生成 proposal.md

architect:
  1. 读 proposal + 探索相关代码
  2. 生成 design.md
  3. 关键架构决策（检查点 C）
```

**产出**：`proposal.md` + `design.md`

**Gate 1（checklist）**：
- 核心章节存在且填写完整
- 无 TBD/TODO 占位符
- 每条验收标准有测试策略条目
- 复杂需求架构决策非空

---

### Phase 2：任务规划

**参与者**：planner

**流程**：
```
planner:
  1. 读 proposal + design
  2. 拆 tasks.md，每个单元带 TDD 步骤
  3. 标注 blockedBy 依赖
```

**产出**：`tasks.md`

**Gate 2**：任务列表完整 + 无占位符

---

### Phase 3：TDD 开发

**参与者**：backend-developer

**流程**：
```
backend-developer:
  1. 按 tasks.md 逐一执行
  2. TDD 纪律：RED → 验证 → GREEN → 验证 → REFACTOR
  3. 写新代码前搜索代码库复用
  4. 如被阻塞 → SendMessage 给 Leader
```

**产出**：实现代码 + 测试代码

**Gate 3**：所有任务完成 + 测试通过

---

### Phase 4：代码评审

**参与者**：code-reviewer

**流程**：
```
code-reviewer:
  1. git diff 结构化评审（不凭记忆）
  2. 严重性分级：CRITICAL(阻断)/HIGH(合并前必修)/MEDIUM(建议)/LOW(可选)
  3. 每条：file:line + 描述 + 修复建议
```

**产出**：评审报告

**Gate 4**：无 CRITICAL + 无未解决 HIGH

---

### Phase 5：测试验证

**参与者**：tester

**流程**：
```
tester:
  1. 跑单元/集成测试
  2. 证据优先：命令 → 输出 → 退出码（禁止"应该能用"）
  3. Bug 报告：复现 + 预期 + 实际 + 证据
```

**产出**：测试报告

**Gate 5**：所有测试通过 + 无未修复 Bug

---

### Phase 6：收尾 + 学习沉淀

**参与者**：requirements-analyst + backend-developer

**流程**：
```
requirements-analyst:
  1. 生成开发总结报告

backend-developer:
  1. 跑全量测试
  2. 清 debug 代码
  3. 一个需求一个大 commit

learn capture:
  1. 扫描本次 run 的信号
  2. 写入 lessons-*.jsonl
  3. lessons_captured++

清理:
  1. 调用 /delete-team
```

**产出**：总结报告 + 学习信号

**Gate 6**：所有任务完成 + 测试通过 + 总结已生成 + 信号已记录

---

## 4. 学习闭环（Learn）

### 三模式

| 模式 | 触发 | 做什么 |
|------|------|--------|
| capture | Phase 6 结束后自动 | 把本次 run 信号写成一条 jsonl |
| apply | Phase 0 自动 | 读 knowledge.md + playbook.md，挑相关条目注入 |
| distill | `/develop-flow learn --upgrade`（或每 5 次 capture 后提醒） | 聚类信号 → 更新知识库 |

### 信号类型

| signal | 触发 | severity |
|--------|------|----------|
| `gate_fail` | 某 Gate 未通过、返工 | high |
| `spec_delta` | 发生需求变更 | medium |
| `retry_escalation` | 异常超重试上限升级用户 | high |
| `user_correction` | 用户中途明确纠正 | medium |
| `manual_note` | `/develop-flow learn <note>` | 由用户 |
| `win` | 某事做得好 | low |

### 知识库位置

- `skills/develop-flow/playbook.md` — 全局经验（跨项目，自动成长）
- `{project}/.develop-flow/knowledge.md` — 项目级经验
- `{project}/.develop-flow/{task_id}/lessons-*.jsonl` — 原始信号

### 手动命令

```bash
# 记录手动笔记
/develop-flow learn 这个需求需要注意数据库索引性能

# 提炼经验（累积 5 条后执行）
/develop-flow learn --upgrade
```

---

## 5. 配置体系

### 两层配置

```
Layer 1: 流程配置    ~/.agents/skills/develop-flow/project-config.md
Layer 2: 项目配置    {root_path}/.develop-flow/project-config.md
```

### 关键配置项

```yaml
# 流程配置
root_path: ""                          # 项目根目录
openspec:
  changes_path: "openspec/changes"     # 需求产出目录
  baseline_path: "openspec/specs"      # 基线文档目录

# 项目配置
root_path: "D:\project\AA-SAAS\builder-labor"
tech_stack: { backend: "java/spring", database: "postgresql" }
modules:
  - { name: "module-a", desc: "模块 A", path: "..." }
git:
  main_branch: "master"
build_commands:
  full_build: "mvn clean install -DskipTests=true"
migration:
  type: "flyway"
databases:
  main: { mcp: "mcp__xxx__query", desc: "主数据库" }
test_environments:
  default: { url: "...", account: "...", password: "..." }
```

---

## 6. Obsidian 集成

### 架构

```
develop-flow learn
    ↓ distill
playbook.md（全局经验）
    ↓ sync-playbook-to-obsidian.sh
Obsidian Vault（长期知识库）
    ↓ RAG（Copilot 插件）
下次 run 自动注入
```

### 配置步骤

```bash
# 1. 设置 Obsidian 路径
export OBSIDIAN_VAULT="D:/your-obsidian-vault"

# 2. 创建目录
mkdir -p "$OBSIDIAN_VAULT/AI知识库"

# 3. 同步 playbook 到 Obsidian
bash ~/.agents/skills/develop-flow/obsidian/sync-playbook-to-obsidian.sh

# 4. 从 Obsidian 同步回 playbook（可选）
bash ~/.agents/skills/develop-flow/obsidian/sync-obsidian-to-playbook.sh
```

---

## 7. 异常处理

### 统一重试上限

| 异常 | 自修复上限 | 超限 |
|------|----------|------|
| 构建失败 | 2 次重试 | 问用户 |
| 测试 bug 循环 | 3 次循环 | 问用户 |
| 需求/设计修订 | 2 次重新 Gate | 问是否终止 |
| Agent 无响应 | 1 次 ping | 问用户 |
| 上下文耗尽 | 1 次替换 | 问用户 |

---

## 8. 快速开始

### 1. 前置
- OpenCode CLI + superpowers 插件 (v5.0+)
- skills：create-team、delete-team、learn
- agents：requirements-analyst、architect、planner、backend-developer、code-reviewer、tester

### 2. 安装
```bash
chmod +x install.sh && ./install.sh
```

### 3. 初始化
```
/init-flow
```

### 4. 运行
```
/develop-flow 用户认证模块需要 JWT 和 refresh token 支持
```

### 5. 交互
半自动模式下每个 Gate 展示 checklist 摘要：确认 → 下一 Phase；修改 → Leader 转发；终止 → `/delete-team`。

---

## 9. FAQ

**Q：Leader 为什么不能直接执行？**
A：保持上下文干净。Leader 只协调/决策/路由，执行交给 agent。这保证职责清晰、可审计，且复杂需求不会撑爆 Leader 上下文。

**Q：子 skill 能单独用吗？**
A：能。learn 可以独立调用：`/develop-flow learn <note>` 记录笔记，`/develop-flow learn --upgrade` 提炼经验。

**Q：开发中发现需求错了怎么办？**
A：触发需求变更——先改 proposal/design/tasks.md，再改代码。文档与代码始终同步。

**Q：可以中途暂停吗？**
A：可以。状态存 `.develop-flow/{task_id}-state.json`，下次自动恢复。

**Q：全自动模式安全吗？**
A：CRITICAL/HIGH 仍升级用户；Gate 质量检查照跑，只跳过人工确认；超重试上限也升级用户。

**Q：TDD 是强制的吗？**
A：是的。Phase 3 强制 TDD 纪律：RED → 验证 → GREEN → 验证 → REFACTOR。

**Q：develop-flow 怎么"自我学习"？**
A：learn 子 skill 闭环——每次 run 结束 capture 记信号；distill 把稳定的沉淀进 knowledge.md 和 playbook.md；下次 run apply 把相关经验注入。手动 `/develop-flow learn <note>` 随时教一条；`/develop-flow learn --upgrade` 触发提炼。

**Q：代码风格/质量怎么保证？**
A：① agent 主动调用已装工具；② Phase 4 代码评审分级；③ Phase 5 测试验证证据优先。

**Q：什么时候 commit？**
A：开发期不 commit（改动累积工作树），Phase 6 时**一个需求一个大 commit**（中文 message）。
