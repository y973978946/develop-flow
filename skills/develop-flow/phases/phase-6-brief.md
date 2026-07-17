---
partOf: develop-flow
version: 1.1.0
description: Phase 6 完整指令——收尾 + 学习沉淀。Leader 进入 Phase 6 时 Read 此文件。
---

# Phase 6: 收尾 + 学习沉淀

> **注意**：develop-flow 不执行 commit、push、分支操作或 Jira 更新。Phase 6 仅做清理、总结和学习沉淀。

## 1. 确认最终状态

- 所有任务已完成
- 代码变更已在工作目录中（未 commit）
- 测试全部通过

## 2. 生成开发总结

Leader → requirements-analyst: "生成开发总结报告：

基于 proposal.md、design.md、tasks.md 和实际代码变更，生成总结：
- 需求实现概述（≤5 句话）
- 关键变更文件列表
- 遗留问题或 TODO（如有）
- 后续建议（如有）

输出到：{changes_path}/{spec_name}/summary.md"

## 3. 学习沉淀（learn capture）

调用 learn capture，扫描本次 run 的信号：

### 3.1 信号收集

从以下数据源提取信号：
- `gate_summaries`：检查是否有 Gate 失败记录 → `gate_fail`
- 异常记录：检查是否有超重试上限 → `retry_escalation`
- 用户交互：检查是否有用户中途纠正 → `user_correction`
- 本次 run 整体：如果顺利通过 → `win`

### 3.2 写入 jsonl

Leader 直接执行（不委托 Agent）：

```bash
# 创建任务目录（如不存在）
mkdir -p {root_path}/.develop-flow/{task_id}

# 写入信号（append-only）
cat >> {root_path}/.develop-flow/{task_id}/lessons-{HHmm}.jsonl << 'EOF'
{"at":"<ISO>","task_id":"<task_id>","phase":6,"signal":"<signal>","severity":"<severity>","detail":"<≤2 句>","source":"auto"}
EOF
```

### 3.3 更新 state

```json
{
  "lessons_captured": <count + 1>
}
```

### 3.4 distill 提醒

如果 `lessons_captured >= 5`，提醒用户：
> "已累积 {count} 条学习信号。建议执行 `/develop-flow learn --upgrade` 提炼经验。"

## 4. AGENTS.md 路由更新

检查 `{root_path}/AGENTS.md` 是否需要更新：

### 4.1 扫描新文档

扫描 `{root_path}/docs/` 目录，检查是否有新文档未被 AGENTS.md 引用：

```bash
# 检查 docs/ 目录下的 md 文件
find {root_path}/docs -name "*.md" -type f
```

### 4.2 检查 AGENTS.md

如果 `{root_path}/AGENTS.md` 不存在或缺少关键部分，自动生成/更新：

**必须包含的部分**：
- 项目概述
- 技术栈
- 模块结构
- 构建命令
- 代码规范
- 测试规范
- 参考文档（docs/ 目录下的关键文档）
- 项目知识库（.develop-flow/knowledge.md）

### 4.3 自动生成/更新

如果 AGENTS.md 不存在，调用 generate-agents-md.sh 自动生成：

```bash
bash ~/.agents/skills/develop-flow/scripts/generate-agents-md.sh {root_path}
```

如果 AGENTS.md 已存在，检查是否有新文档需要添加：

```bash
# 检查 docs/ 目录下的 md 文件是否都在 AGENTS.md 中有引用
for doc in {root_path}/docs/*.md; do
    doc_name=$(basename "$doc" .md)
    if ! grep -q "$doc_name" {root_path}/AGENTS.md; then
        # 添加到 AGENTS.md
        echo "- [$doc_name](docs/$(basename "$doc"))" >> {root_path}/AGENTS.md
    fi
done
```

### 4.4 知识库引用规则

| 知识库 | 是否加到 AGENTS.md | 说明 |
|--------|-------------------|------|
| 项目级 `.develop-flow/knowledge.md` | ✅ 是 | 项目专属经验，Agent 需要知道 |
| 全局 `playbook.md` | ❌ 否 | 跨项目通用，由 learn apply 自动注入 |

**原因**：
- playbook.md 由 learn apply 自动注入到 Phase prompt，不需要 Agent 手动读取
- 避免每个项目都引用同一个全局文件造成冗余
- 保持 AGENTS.md 聚焦于项目专属内容

## 5. 清理

调用 /delete-team

## 6. 最终摘要

Leader 向用户展示最终摘要：

```
## 开发完成

**需求**: {spec_name}
**产出目录**: {changes_path}/{spec_name}/
**关键文件**: <变更文件列表>
**状态**: 代码已在工作目录，待 commit

**学习信号**: 已记录到 {root_path}/.develop-flow/{task_id}/lessons-{HHmm}.jsonl
**AGENTS.md**: 已更新（如有新文档）

**下一步**:
- 检查代码变更
- 手动 commit 和 push（如需要）
- 部署到测试环境验证
```

## Gate 6

- [ ] 所有任务已完成
- [ ] 测试全部通过
- [ ] 开发总结已生成
- [ ] 学习信号已记录
- [ ] AGENTS.md 已检查/更新
- [ ] 团队已清理

最终总结（产出文件列表 + 学习信号记录 + AGENTS.md 更新 + 提醒代码待 commit）
