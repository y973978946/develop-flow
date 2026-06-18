---
partOf: develop-flow
version: 1.0.0
description: Gate 机制详细规则。Leader 在执行 Gate 检查点时 Read 此文件。
---

# Gate 机制

每个 Phase 结束时，Leader 执行 Gate 检查点：

1. **收集**：汇总当前 Phase 所有 Agent 报告
2. **质量检查**：评估产出是否满足 Gate 通过标准（见下表）
3. **持久化**：写入 Gate 结果到 `{root_path}/.develop-flow/{task_id}-state.json`：
   - `gate_summaries[current_phase]` = Gate 摘要文本
   - `phase_decisions[current_phase]` = 提取的关键决策：
     - `scope`：Agent 摘要，≤1 句话
     - `key_files`：变更文件列表，≤10 个
     - `architecture_choice`：design.md 或架构师报告的核心决策（仅 Phase 1-2）
     - `risks`：Gate 摘要风险部分（如有）
   - `current_phase` = 下一 Phase 编号
   - `updated_at` = ISO 时间戳
4. **展示**：向用户展示结构化摘要（见摘要格式）
5. **确认**（半自动模式）：
   - 用户确认 → 进入下一 Phase，执行 `/compact` 释放 Leader 上下文
   - 用户要求修改 → Leader 转发修改指令给相关 Agent，修改后重跑 Gate
   - 用户中止 → 执行 /delete-team 清理，工作流结束
6. **自动通过**（全自动模式）：质量检查 + 持久化后直接推进；质量不足时升级给用户

## Gate 通过标准

| Phase | 必须满足 | 质量不足时 |
|-------|---------|-----------|
| Gate 1 | proposal.md + design.md 无占位符（TBD/TODO），内部一致，受影响模块明确。检查点 A/B/C 已确保方向正确 | Leader 转发修改反馈，重跑 Gate |
| Gate 2 | tasks.md 无占位符，每步有文件路径和命令，blockedBy 正确 | Planner 修改重跑 |
| Gate 3 | 所有任务完成，测试通过 | 未完成任务继续；阻塞任务走异常 |
| Gate 4 | 无 CRITICAL 问题，无未解决 HIGH 问题 | 开发修复，code-reviewer 重评 |
| Gate 5 | 所有测试通过，无未修复 Bug | Bug 修复循环；>3 次升级用户 |
| Gate 6 | 工作流完成，状态已清理 | 补全缺失步骤 |

## Gate 摘要格式

```
Phase N: <Phase 名称>
产出: <文件路径列表>
关键决策: <1-3 项>
风险: <如有，格式：风险描述 + 影响范围 + 建议缓解措施>
质量: 通过 / 不通过（列出不通过项）
下一阶段将 spawn: <Agent 列表（如有新增）>
```

## 风险示例

- "design.md 涉及新表需要 DBA 审核 → 影响发布周期，建议提前沟通"
- "方案 B 性能更好但变更范围更大 → 影响回归测试范围，建议增加测试时间"
- "需求中字段 X 含义未确认 → 可能导致返工，建议 Gate 前与产品确认"
