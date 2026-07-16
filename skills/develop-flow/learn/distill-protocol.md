# Learn distill 协议

distill = 把累积信号提炼成"经验沉淀 + skill 升级提议"。由 `/develop-flow learn --upgrade` 触发，或 `lessons_captured` 每 ≥5 时 Leader 提醒（不自动跑结构改动）。

## 流程

spawn 一个临时 curator agent（general-purpose）：

1. **读**：本项目全部 `{root_path}/.develop-flow/*/lessons-*.jsonl` + 现有 `knowledge.md` + 全局 `playbook.md`
2. **聚类**：按 signal 类型 + detail 关键词聚类，识别重复 ≥2 次的模式
3. **分类落地**（按分级安全）：
   - **项目事实**（该项目专属）→ 更新 `{root_path}/.develop-flow/knowledge.md`（自动）
   - **通用经验**（跨项目）→ 追加 `skills/develop-flow/playbook.md`（自动）
   - **"skill 该强制 X"**（如某 Gate 检查项反复失败）→ 生成结构 diff → 入待审队列
4. **汇报**：自动落地摘要 + 待审结构 diff
5. **用户批准结构 diff** → commit（develop-flow 仓库）

## diff 生成与审核

- 结构 diff 范围：`SKILL.md` / `gate.md` Gate 规则 / `phases/*.md` / `team-rules.md` / `resume.md`
- diff 必须保持目标文件行数预算（SKILL.md ≤200、phase brief ≤150）；超出则 curator 改提"提炼/拆分"，不直接堆
- diff 以 unified diff 呈现，每条带理由 + 溯源 task_id
- 未批准的 diff 不落地；用户可逐条 accept / reject

## 去重 / 精简 / 归档

- `knowledge.md` / `playbook.md` 超 200 行：distill 合并重复、删过时（保留每类最近 N 条）
- `lessons` 超 30 天归档（移到 `.develop-flow/archive/` 或删，不删可查）
- 找不到新模式 → no-op，不刷屏

## 自动触发条件

- `/develop-flow learn --upgrade`：手动触发
- `lessons_captured >= 5`：Leader 在 Phase 6 收尾后提醒"建议执行 `/develop-flow learn --upgrade`"
- 首次 run（无 lessons）→ 不触发
