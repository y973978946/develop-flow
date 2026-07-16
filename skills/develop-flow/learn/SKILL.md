---
name: learn
description: develop-flow 的学习子 skill。三模式：capture（Phase 6 后自动记信号）、apply（Phase 0 自动注入相关经验）、distill（/develop-flow learn --upgrade 提炼升级）。两层知识（项目 knowledge.md / 全局 playbook.md）+ 分级安全（playbook 自动、skill 结构审核）。可独立调用。
version: 1.0.0
tags: [learning, knowledge, distill, develop-flow]
---

# Learn：develop-flow 的学习闭环

develop-flow 的学习子 skill，实现"捕获→沉淀→应用→提炼"闭环。让 develop-flow 在使用中持续成长，且不失控。

## 三模式

| 模式 | 触发 | 做什么 |
|------|------|--------|
| capture | Phase 6 结束后自动 | 把本次 run 信号写成一条 jsonl |
| apply | Phase 0 自动 | 读 knowledge.md + 相关 log，挑与当前需求相关的，返回压缩块供注入 |
| distill | `/develop-flow learn --upgrade`（或每 5 次 capture 后提醒） | 聚类信号 → 沉淀 knowledge/playbook（自动）+ 结构改动出 diff（待审） |

`learn` 不常驻——capture/apply 由 Leader 直接执行；distill 才 spawn 临时 curator agent。

## 信号分类（capture 机械、可聚类）

| signal | 触发 | severity |
|--------|------|----------|
| `gate_fail` | 某 Gate 未通过、返工 | high |
| `spec_delta` | 发生 spec-delta（含 reason） | medium |
| `retry_escalation` | 异常超重试上限升级用户 | high |
| `user_correction` | 用户中途明确纠正 | medium |
| `manual_note` | `/develop-flow learn <note>` | 由用户 |
| `win` | 某事做得好（可选正反馈） | low |

## capture

- 文件：`{root_path}/.develop-flow/{task_id}/lessons-{HHmm}.jsonl`（append-only，每行一条 JSON）
- 时机：Leader 在 Phase 6 Gate 通过后调用
- 数据源：扫描本次 run 的 `gate_summaries` + 异常记录
- state：`lessons_captured++`
- jsonl 行 schema 见 `knowledge-format.md`

## apply

- 读 `{root_path}/.develop-flow/knowledge.md`（不存在→返回空，零开销）
- 读 `skills/develop-flow/playbook.md`（不存在→跳过）
- 按当前需求文本 + 检测到的触发条件挑相关条目，压缩 **≤6 条**（封顶 ~800 token）
- 注入目标：
  - Phase 1（需求分析）← 历史 spec 坑 + 必触发章节
  - Phase 3（TDD 开发）← 开发坑 + 复用点
  - Phase 4（代码评审）← 常被忽略的审查项
- **不整本灌** knowledge.md；首次 run 返回空

## distill

`/develop-flow learn --upgrade`：spawn curator agent，聚类信号 → 自动更新 `knowledge.md` / 追加 `playbook.md`；skill 结构改动出 diff 待审。完整流程见 `distill-protocol.md`。

## 分级安全

| 改动 | 落地 |
|------|------|
| 追加 `lessons/*.jsonl` / 更新 `knowledge.md` / 追加 `playbook.md` | 自动 |
| 改 `SKILL.md` / `gate.md` / `phases/*.md` / `team-rules.md` / `resume.md` | 必须用户审 diff |

`playbook.md` 是自动成长的缓冲层——绝大部分经验沉淀于此，不动核心 skill 结构。

## 数据文件位置

- 项目层：`{root_path}/.develop-flow/{task_id}/lessons-{HHmm}.jsonl` + `{root_path}/.develop-flow/knowledge.md`
- 全局层：`skills/develop-flow/playbook.md` + skill 结构文件（distill 提议、审核后改）

每条 knowledge/playbook 条目带 `> source: <task_id> @ <ISO>, signal: <type>` 溯源；超 200 行由 distill 去重精简。

## 手动命令

- `/develop-flow learn <note>` → capture 一条 manual_note
- `/develop-flow learn --upgrade` → distill 提炼升级

## Dependencies

无外部 skill 依赖。由 develop-flow Leader 在 Phase 0 / Phase 6 触发；distill spawn 临时 curator agent。
