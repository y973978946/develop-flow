---
partOf: develop-flow
version: 1.0.0
description: Phase 6 完整指令——收尾。Leader 进入 Phase 6 时 Read 此文件。
---

# Phase 6: 收尾

> **注意**：develop-flow 不执行 commit、push、分支操作或 Jira 更新。Phase 6 仅做清理和总结。

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

## 3. 清理

调用 /delete-team

## 4. 最终摘要

Leader 向用户展示最终摘要：

```
## 开发完成

**需求**: {spec_name}
**产出目录**: {changes_path}/{spec_name}/
**关键文件**: <变更文件列表>
**状态**: 代码已在工作目录，待 commit

**下一步**:
- 检查代码变更
- 手动 commit 和 push（如需要）
- 部署到测试环境验证
```

## Gate 6

最终总结（产出文件列表 + 提醒代码待 commit）
