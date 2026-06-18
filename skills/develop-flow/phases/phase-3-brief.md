---
partOf: develop-flow
version: 1.0.0
description: Phase 3 完整指令——TDD 开发。Leader 进入 Phase 3 时 Read 此文件。
---

# Phase 3: TDD 开发

## 开发指令

1. Leader 用 TaskUpdate 将任务分配给 backend-developer
2. Leader → backend-developer:
   "完成 TaskList 中分配给你的任务。

    [superpowers:test-driven-development + executing-plans]
    先 Read 对应 SKILL.md 获取完整方法论。
    关键约束:
    - TDD 纪律: 绝不在失败测试之前写生产代码
    - RED → Verify → GREEN → Verify → REFACTOR
    - 按 tasks.md 步骤逐一执行；验证通过才进入下一步
    - 写新代码前搜索代码库中已有的类似实现以复用或扩展
    - 如被阻塞 → SendMessage 给 Leader；不要猜测

    项目根目录: {root_path}。
    后端开发: 参考 {root_path}/.develop-flow/project-config.md → databases（读写数据）+ migration（建表/改字段规范）。
    如有问题，按 team-rules.md 定义的升级路径处理。"
3. Leader 监控：
   - 收到进度更新 → 更新 state.json agent_context_snapshots[agent_name]
   - 收到完成报告 → TaskUpdate + 通知等待的 Agent
   - 收到异常 → 按异常协议处理
   - 10 分钟无消息 → ping Agent；ping 未回复 + 15 分钟静默 → 上下文耗尽恢复（见 skill.md）

## Gate 3

展示进度 → 确认
