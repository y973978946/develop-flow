# AGENTS.md

## 这是什么仓库

OpenCode Skill（prompt 工程框架）——**非传统源代码**。整个代码库是 Markdown：Agent 定义、Skill 指令、Phase 简报和安装脚本。没有构建系统、测试套件、linter、包管理器或运行时。

## 仓库结构

- `skills/` — 4 个 skills，每个在 `skills/<name>/` 中，`skill.md`（或 `SKILL.md`）为入口
- `agents/` — 15 个 Agent 定义（`.md` 文件），6 个核心 + 9 个辅助
- `install.sh` / `uninstall.sh` — 符号链接 skills + agents 到 `~/.agents/`

## Agent 关键约束

- **无可执行代码** — 不要尝试 `npm install`、`make`、`pytest` 等
- **无测试可运行** — 验证是手动的：用真实需求端到端测试
- **无 linter/typecheck** — 质量 = 清晰、无歧义的 Markdown 指令
- **Skill 文件需要 frontmatter** — `name`、`description`、`version`、`tags` 字段
- **Agent 必须无状态** — 所有上下文来自任务描述或 Leader 消息
- **无硬编码路径/凭证** — 使用配置模板

## 入口点

| Skill | 入口 | 触发 |
|-------|------|------|
| `develop-flow` | `skills/develop-flow/skill.md` | `/develop-flow <需求描述>` |
| `init-flow` | `skills/init-flow/skill.md` | `/init-flow` |
| `create-team` | `skills/create-team/SKILL.md` | `/create-team` |
| `delete-team` | `skills/delete-team/SKILL.md` | `/delete-team` |

## 架构

Hub-and-Spoke：Leader（主会话）协调；Agent 间不直接通信。Phase 指令按需加载自 `skills/develop-flow/phases/phase-N-brief.md`。配置 2 层：流程配置 → 项目配置。

## 编辑时

- Read `CLAUDE.md` 获取完整架构和约束文档
- Phase briefs 在 `skills/develop-flow/phases/` 中是实际执行指令
- `skills/develop-flow/team-rules.md` 管理 Agent 通信协议
- `skills/develop-flow/gate.md` 定义 Gate 通过标准
- `skills/develop-flow/resume.md` 处理断点恢复
- Agent 定义在 `agents/` 中遵循：角色描述 → 工具 → 约束 → 输出格式

## 安装/卸载

```bash
chmod +x install.sh && ./install.sh   # 符号链接到 ~/.agents/
./uninstall.sh                         # 仅移除符号链接
```

需要：OpenCode CLI、`~/.agents/` 目录、`superpowers` 插件（>= 5.0.0）。
