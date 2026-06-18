---
partOf: develop-flow
version: 1.0.0
description: 断点恢复逻辑。当 develop-flow 检测到 state.json 文件时，按此流程恢复中断的工作流。
---

# 断点恢复

> 当 `/develop-flow` 检测到已存在的 `{task_id}-state.json` 时，按此恢复流程执行。

## 状态文件

位置：`{root_path}/.develop-flow/{task_id}-state.json`

```json
{
  "task_id": "{task_id}",
  "team_name": "develop-flow-{task_id}",
  "mode": "semi-auto",
  "current_phase": 3,
  "phase1_substep": "gate1",
  "spawned_agents": ["requirements-analyst", "architect", "planner", "backend-developer"],
  "openspec_name": "{spec_name}",
  "gate_summaries": {
    "1": "proposal: xxx, design: xxx",
    "2": "tasks: 8 total"
  },
  "phase_decisions": {
    "1": {
      "scope": "后端 API 用户认证",
      "key_files": ["src/auth/controller.ts", "src/auth/service.ts"],
      "architecture_choice": "JWT + refresh token",
      "risks": ["新表需要 DBA 审核"]
    }
  },
  "user_answers": {
    "checkpoint_a": "<用户需求确认>",
    "checkpoint_b": "<用户选择的方案>"
  },
  "agent_context_snapshots": {
    "backend-developer": {
      "last_progress": "步骤 5/8: 实现 auth service",
      "last_files_changed": ["src/auth/service.ts", "tests/auth/service.test.ts"],
      "last_update": "2026-05-22T10:30:00Z"
    }
  },
  "updated_at": "<ISO>"
}
```

### 字段说明

| 字段 | 用途 | 更新时机 |
|------|------|---------|
| `phase_decisions` | 每阶段关键决策（≤100 字符/字段） | 每个 Gate 通过后 |
| `agent_context_snapshots` | 每个 Agent 最后已知进度 | 每次 Agent 进度报告/完成时 |
| `phase1_substep` | Phase 1 内部步骤跟踪 | Phase 1 每步完成后 |
| `user_answers` | Phase 1 检查点 A/B 用户回复 | 每次检查点交互后 |

### 持久化时机

- **Gate 通过**：Leader 写入 `gate_summaries` + `phase_decisions` + 推进 `current_phase`
- **Agent 进度报告**：Leader 更新 `agent_context_snapshots[agent_name]`
- **Agent 任务完成**：Leader 更新对应快照

## 恢复流程

```
1. Read {task_id}-state.json
2. AskUserQuestion: "发现未完成的工作流（Phase {n}/6）。是否恢复？"
   → 否：删除状态，从头开始
   → 是：
3. 重新 spawn state.spawned_agents 中列出的所有 Agent（附加 team-rules.md）
4. 为每个重新 spawn 的 Agent 注入上下文：
   - phase_decisions[current_phase] → 获取前序阶段关键决策
   - agent_context_snapshots[agent_name] → 了解上次进度
5. 确定断点 → 跳转到对应 Phase：
   current_phase == 1:
     phase1_substep 未设置或 "step1" → Step 1（初始分析）
     phase1_substep == "step2" → Step 2（方案提议）
     phase1_substep == "step3" → Step 3（生成 proposal）
     phase1_substep == "step4" → Step 4（架构设计）
     phase1_substep == "gate1" → Gate 1
   current_phase == 2: tasks.md 存在 → Phase 3，否则 → Phase 2
   current_phase == 3: TaskList 有未完成任务 → 继续 Phase 3，否则 → Phase 4
   current_phase == 4-6: 从该 Phase 开始
6. Agent 从磁盘文件（proposal/design/tasks）和 state.json phase_decisions 读取上下文
```

每个 Gate 确认后，Leader 更新 state 文件（设置 current_phase 为下一 Phase 编号）。
Phase 6 完成后，删除 state 文件。

## 异常恢复场景

### Agent Spawn 失败

```
spawn 特定 Agent 失败 → Leader 记录失败 Agent 名到 state.failed_agents
→ 重试 spawn（最多 2 次）
→ 仍失败 → AskUserQuestion: 继续（无该角色）/ 中止工作流
```

### Leader 会话崩溃

```
恢复时 Leader 读取状态：
  - current_phase < 3 → 前序产出（proposal/design/tasks）在磁盘上，可直接恢复
  - current_phase == 3 → 检查 TaskList 已完成和未完成任务
    → 重新 spawn 开发 Agent，从未完成任务继续
  - current_phase >= 4 → 检查 git log 确认代码状态，从对应 Phase 恢复
```

### 外部配置中途修改

```
{root_path}/.develop-flow/project-config.md 被修改：
  → Leader 检测到变化（对比 Read 与缓存的配置摘要）
  → AskUserQuestion: "项目配置已变更。使用新配置继续？"
  → 是：重新加载配置，通知运行中的 Agent
  → 否：继续使用之前的配置
```
