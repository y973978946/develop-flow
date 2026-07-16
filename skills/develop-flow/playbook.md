# Develop-Flow 全局 Playbook

> 由 learn distill 自动维护的跨项目通用经验。apply 只挑相关条目注入，不整本灌。每条带溯源。
> 初始内容来自常见开发模式；后续由 distill 自动成长。

## 通用触发提示

- 需求涉及数据库变更时，务必检查 migration 规范和现有表结构 > source: init @ 2026-07-16, signal: manual_note
- 需求涉及多模块改动时，先梳理模块间依赖关系再动手 > source: init @ 2026-07-16, signal: manual_note
- 需求涉及异步/消息队列时，明确消息格式和失败重试策略 > source: init @ 2026-07-16, signal: manual_note

## 通用常见坑

- proposal/design 中保留 TBD/TODO 占位符会导致 Gate 不通过 > source: init @ 2026-07-16, signal: manual_note
- 跳过 Phase 直接写代码会导致返工 > source: init @ 2026-07-16, signal: manual_note
- 不读 project-config.md 就开始开发，会忽略项目特定约束 > source: init @ 2026-07-16, signal: manual_note

## 通用复用点

- 审批引擎可抽为通用组件，避免每个业务重复实现 > source: init @ 2026-07-16, signal: manual_note
- Flyway 迁移脚本命名规范：V{版本}__{描述}.sql > source: init @ 2026-07-16, signal: manual_note

## 通用项目约定

- Leader 不直接写代码，只协调和决策 > source: init @ 2026-07-16, signal: manual_note
- 每个 Phase 必须产出对应文档 > source: init @ 2026-07-16, signal: manual_note
- Gate 必须展示摘要并确认后才能推进 > source: init @ 2026-07-16, signal: manual_note
