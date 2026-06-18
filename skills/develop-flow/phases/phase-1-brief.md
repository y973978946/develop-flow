---
partOf: develop-flow
version: 1.0.0
description: Phase 1 完整指令——交互式需求分析。Leader 进入 Phase 1 时 Read 此文件。
---

# Phase 1: 需求分析（交互式）

> **核心原则**：Phase 1 是整个工作流的基础。方向错误会向下游级联。用户必须在继续前验证关键决策。

## 概述

Phase 1 包含 4 个步骤和 3 个交互检查点（A/B/C），后接 Gate 1：

| 步骤 | Agent | 产出 | 用户交互 |
|------|-------|------|---------|
| 步骤 1: 初始分析 | requirements-analyst | 需求摘要 + 澄清问题 | **检查点 A**: 用户确认理解 |
| 步骤 2: 方案提议 | requirements-analyst | 2-3 个实现方案 | **检查点 B**: 用户选择方案 |
| 步骤 3: 生成 Proposal | requirements-analyst | proposal.md | 无 |
| 步骤 4: 架构设计 | architect | design.md + 关键设计决策 | **检查点 C**: 用户确认设计决策（条件触发） |
| Gate 1 | Leader | 最终确认 | Gate 1 |

### 状态跟踪

每步完成后，Leader 更新 `{root_path}/.develop-flow/{task_id}-state.json`：
- `phase1_substep`: "step1" | "step2" | "step3" | "step4" | "gate1"
- `user_answers`: 累积检查点 A 和 B 的用户回复

---

## 需求来源处理

develop-flow 的需求来源不是 Jira，而是以下之一：

| 来源 | 处理方式 |
|------|---------|
| 飞书文档链接 | 提示用户："请将飞书文档内容复制粘贴给我，或导出为文字后提供。当前不支持直接抓取飞书文档。" |
| 文字描述 | 直接使用用户提供的文字作为需求输入 |
| 图片 | 提示用户："当前模型不支持直接读取图片。请将图片中的需求内容以文字形式描述给我。" |
| 文字 + 图片 | 先处理文字部分，图片部分提示用户转文字 |

**重要**：Leader 在 Step 1 开始前，必须确认需求内容已以文字形式获取。如果用户提供了无法处理的来源，先引导转换，不要跳过。

---

## 步骤 1: 初始分析

Leader → requirements-analyst: "分析以下需求内容，探索相关代码，产出：

1. **需求理解摘要**（≤10 句话）：需求要什么、受影响模块、约束条件
2. **澄清问题**（1-5 个问题）：需求中模糊、缺失或矛盾的信息。如果一切清晰，输出空列表。

需求内容：
{requirement_text}

[superpowers:brainstorming]
先 Read superpowers brainstorming SKILL.md 获取完整方法论。
关键约束：
- 本步骤仅关于理解——不要提出解决方案
- 关注：目的、约束、成功标准、范围边界
- 识别与现有代码模式或基线的冲突

基线关联（如 {baseline_path} 存在且非空）：
- 扫描 {baseline_path} 下所有 spec.md，识别与当前需求相关的基线文档
- 记录可能影响实现范围的基线约束

参考 {changes_path} 下已有 spec 的格式。
通过 SendMessage 输出给 Leader（非文件）：
  - requirement_summary: ≤10 句话摘要
  - clarifying_questions: 问题列表（可为空）
  - affected_modules: 可能涉及的模块/仓库列表
  - baseline_conflicts: 发现的基线约束（可为空）"

等待完成 → 更新状态：`phase1_substep = "step1"`

### 检查点 A: 需求确认

**半自动模式**：
Leader 用 AskUserQuestion 向用户展示：
- Agent 的需求理解摘要
- 每个澄清问题（如有）作为单独问题
- "这个理解符合你的意图吗？有需要补充或纠正的吗？"

收集用户回复 → 保存到状态：`user_answers.checkpoint_a = <用户回复>`

**全自动模式**：
Leader 记录需求摘要并自动通过。如有澄清问题，记录为假设。

---

## 步骤 2: 方案提议

Leader → requirements-analyst: "基于已确认的需求理解和用户输入：
{user_answers.checkpoint_a}

现在为当前需求提出 2-3 个实现方案。每个方案包含：
- **名称**：简短标签
- **描述**：做什么、怎么做（≤5 句话）
- **架构影响**：受影响的模块/仓库、新增 vs 修改的组件
- **实现复杂度**：相对工作量（低/中/高）
- **风险因素**：潜在问题、迁移需求、破坏性变更

给出推荐方案及理由。

[superpowers:brainstorming — 探索方案]
先 Read superpowers brainstorming SKILL.md 获取完整方法论。
关键约束：
- 每个方案必须可行——不要凑数
- 推荐方案应考虑项目现有模式和约束
- 如有基线约束，确保所有方案遵守（或明确标记违反）

通过 SendMessage 输出给 Leader：
  - options: 2-3 个方案列表（含上述字段）
  - recommendation: 推荐哪个及原因
  - trade_off_summary: 方案间关键差异（≤3 句话）"

等待完成 → 更新状态：`phase1_substep = "step2"`

### 检查点 B: 方案选择

**半自动模式**：
Leader 用 AskUserQuestion 向用户展示方案：
- 展示每个方案的名称、描述、复杂度、风险
- 展示推荐方案
- 询问："你倾向哪个方案？"（选项：各方案名称 + "其他"）

收集用户回复 → 保存到状态：`user_answers.checkpoint_b = <选择的方案或自定义输入>`

**全自动模式**：
Leader 记录方案并自动选择推荐方案。保存：`user_answers.checkpoint_b = <推荐方案>`

---

## 步骤 3: 生成 Proposal

Leader → requirements-analyst: "用户选择了：{user_answers.checkpoint_b}

基于选定方案生成 OpenSpec proposal.md。

[superpowers:brainstorming — 呈现设计]
关键约束：
- Proposal 必须反映选定方案和检查点 A/B 的所有用户输入
- Spec 自查（写完后检查）：无占位符、内部一致、范围覆盖、无歧义
- 基线约束部分：引用相关基线的关键约束（如有）
- 确保 proposal 不与基线冲突；如必须违反基线，明确说明原因和影响

参考 {changes_path} 下已有 spec 的格式。
输出到：{changes_path}/{spec_name}/proposal.md
spec_name 命名规则：<模块缩写>-<简要描述>，遵循已有目录的命名风格。
完成后发送消息包含：spec_name、proposal 摘要（仅要点）"

等待完成 → 更新状态：`phase1_substep = "step3"`，记录 `spec_name`

---

## 步骤 4: 架构设计

Leader → architect: "Read {changes_path}/{spec_name}/proposal.md，生成 design.md，探索相关代码架构。
数据库：参考 {root_path}/.develop-flow/project-config.md → databases（查询表结构辅助设计）。

[superpowers:brainstorming — 设计原则]
先 Read superpowers brainstorming SKILL.md 获取完整方法论。
关键约束：
- 模块分解：每个单元单一职责、接口清晰、可独立理解/测试
- 遵循现有代码模式；不引入无关重构
- 设计自查：确认无占位符、类型一致、文件依赖完整

输出到：{changes_path}/{spec_name}/design.md

完成后发送消息包含：
  - design_summary: 设计概述（≤5 句话）
  - key_files: 将被修改或创建的文件列表（≤15）
  - design_decisions: 需要用户关注的关键架构决策列表（可为空）
    每个决策: { decision: '...', rationale: '...', alternatives_rejected: ['...'] }"

等待完成 → 更新状态：`phase1_substep = "step4"`

### 检查点 C: 设计确认（条件触发）

触发条件：architect 报告了非空的 `design_decisions` 列表。

**半自动模式**：
Leader 用 AskUserQuestion 向用户展示关键设计决策：
- 展示每个决策及其理由
- 询问："你同意这些设计决策吗？"

收集用户回复 → 如用户不同意，Leader 转发反馈给 architect 修改。

**全自动模式**：自动通过，记录设计决策。

如 architect 报告空 `design_decisions` → 跳过检查点 C。

---

## Gate 1

展示 Agent 摘要（proposal 摘要 + design 摘要 + 关键文件）→ 确认后 spawn 开发 Agent（backend-developer）。

更新状态：`phase1_substep = "gate1"`，推进到 Phase 2。
