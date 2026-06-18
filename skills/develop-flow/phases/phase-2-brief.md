---
partOf: develop-flow
version: 1.0.0
description: Phase 2 完整指令——任务规划。Leader 进入 Phase 2 时 Read 此文件。
---

# Phase 2: 任务规划

> **注意**：develop-flow 不创建分支、不 commit。任务规划仅产出 tasks.md，开发在当前项目目录下进行。

## 步骤 2a: 任务拆分

Leader → planner: "拆分任务，写 tasks.md + TaskCreate 创建跟踪条目（标注 blockedBy）

    [superpowers:writing-plans]
    先 Read superpowers writing-plans SKILL.md 获取完整方法论。
    关键约束:
    - 咬合粒度: 每步 2-5 分钟（测试→验证→实现→验证）
    - TDD 步骤: RED → Verify RED → GREEN → Verify GREEN → REFACTOR
    - 零占位符: 禁止 TBD/TODO — 每步含完整代码和命令
    - 精确路径: 每步标注文件路径
    - 自查: spec 覆盖完整、无占位符、类型一致
    - 纯后端: 不涉及前端页面开发
    输出写入: {changes_path}/{spec_name}/tasks.md + TaskCreate 条目"

等待 → Gate 2: 展示任务列表 → 确认

## Gate 2

展示任务列表摘要（任务数量、预计步骤、关键依赖）→ 用户确认后推进到 Phase 3。
