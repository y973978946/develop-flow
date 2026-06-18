---
partOf: develop-flow
version: 1.0.0
description: Phase 5 完整指令——测试验证。Leader 进入 Phase 5 时 Read 此文件。
---

# Phase 5: 测试验证

spawn tester

Leader → tester: "读取 proposal.md + tasks.md，执行测试验证。

  [superpowers:verification-before-completion]
  先 Read superpowers verification SKILL.md 获取完整方法论。
  关键约束:
  - 证据铁律: 任何完成声明必须有即时验证证据
  - 禁止: '应该能用了'/'看起来没问题'/'应该通过了'
  - 每项验证提供: 命令 + 输出摘要 + 退出码
  - Bug 报告: 复现步骤 + 预期 + 实际 + 证据

  测试环境凭证: 参考 {root_path}/.develop-flow/project-config.md → test_environments。
  测试范围: 已有单元测试 + API/集成测试。
  项目路径: {repo_path}。
  数据库验证: 通过 MCP 查询对应数据库验证数据正确性。
  发现 Bug → SendMessage Leader: 'Bug: <描述>, 步骤: <复现>, 预期: <预期>, 实际: <实际>'
  全部通过 → SendMessage Leader: '测试全部通过，报告: ...'"

## 测试-修复循环（全过 Leader）

tester 发现 Bug → Leader → Leader 判断归属 → 开发 Agent 修复 → Leader → tester 复验
未通过再走一轮，多轮未修复(>3次) → Leader 询问用户

## Gate 5

展示测试报告 → 确认
