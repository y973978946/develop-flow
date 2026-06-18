---
name: init-flow
description: 当用户说 "初始化"、"/init-flow" 时使用。一键初始化 develop-flow 工作流——自动检测技术栈、生成配置文件、验证依赖。每个项目运行一次。
version: 1.0.0
tags: [develop-flow, setup, initialization]
dependencies:
  skills: []
  mcp_servers: []
---

# Init Flow

一键初始化 develop-flow 工作流。自动检测技术栈、生成配置、验证依赖。

**触发**: 用户说 "初始化" / "init flow" / `/init-flow`

**输入**: `$ARGUMENTS`（可选，项目路径。默认当前工作目录）

## 工作流

```
1. 检测:   扫描项目目录，识别技术栈、仓库结构、数据库
2. 生成:   创建配置文件
3. 依赖:   验证 skills / agents / superpowers
4. 验证:   确认所有文件存在且引用正确
```

---

## 1. 检测

确定项目根路径：

```
ARGUMENTS 非空 → 使用指定路径
ARGUMENTS 为空 → 使用当前工作目录
```

在项目根目录运行扫描：

```bash
# 技术栈检测
ls composer.json package.json pom.xml build.gradle go.mod Cargo.toml 2>/dev/null

# 仓库结构（多仓库检测）
find . -name .git -maxdepth 3 -type d 2>/dev/null

# 数据库检测
grep -r "DB_" .env 2>/dev/null
grep -r "database" config/ 2>/dev/null

# Docker 检测
ls docker-compose.yml Dockerfile 2>/dev/null

# Git 主分支
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null
```

推断结果：

| 检测到 | 推断 |
|--------|------|
| `composer.json` + `"laravel"` | backend: laravel |
| `package.json` + `"express"` | backend: express |
| `pom.xml` / `build.gradle` | backend: java/spring |
| `go.mod` | backend: go |
| `.env` with `DB_CONNECTION=mysql` | database: mysql |
| `docker-compose.yml` | docker: yes |
| 子目录有 `.git` | 多仓库架构 |

---

## 2. 生成

### 2a. 流程配置 `~/.agents/skills/develop-flow/project-config.md`

此文件是 develop-flow 流程级配置。

> 如已存在：读取当前内容，**保留用户自定义的 openspec 设置**，仅更新 root_path。

生成内容：

```markdown
---
name: develop-flow-project-config
description: Develop-Flow 流程配置。项目专属信息在 {root_path}/.develop-flow/project-config.md。
---

# Develop-Flow 流程配置

> 此文件仅包含 develop-flow 工作流本身的配置。
> 项目专属信息（仓库、数据库、测试环境等）在 `{root_path}/.develop-flow/project-config.md`。

---

## 项目路径

root_path: "{检测到的项目路径}"

## 需求产出目录

openspec:
  changes_path: "openspec/changes"
  baseline_path: "openspec/specs"
```

### 2b. 项目配置 `{root_path}/.develop-flow/project-config.md`

此文件是项目级配置，包含完整的仓库、数据库、测试环境等信息。

> 如已存在：**不覆盖**；提示用户手动合并缺失字段。

基于检测结果生成。使用 `project-config.example.md` 格式填充检测到的值。最小模板：

```markdown
# {项目名} 项目配置

> **用途**: Agent 和 Skill 的共享项目级配置。消费者直接 Read 此文件。

---

## 基本信息

root_path: "{项目路径}"
tech_stack: { backend: "{backend}", database: "{database}" }

## 仓库架构

{基于检测结果：单仓库或模块列表}

## Git 配置

git:
  main_branch: "{master 或 main}"

## 需求产出目录

openspec:
  changes_path: "openspec/changes"
  baseline_path: "openspec/specs"

## 数据库 MCP

{基于可用 MCP 工具填充}

## 构建命令

build_commands:
  backend: "{检测到的后端构建命令}"

## 迁移

migration:
  steps:
    - "{检测到的迁移命令}"
```

关键字段：

| 字段 | 来源 | 必需 |
|------|------|------|
| `root_path` | 项目路径 | 是 |
| `tech_stack` | 检测结果 | 是 |
| `backend.main_repo` | 仓库结构检测 | 是 |
| `git.main_branch` | Git 检测 | 是 |
| `databases` | 用户确认 | 条件 |
| `build_commands` | 技术栈推断 | 条件 |
| `migration` | 技术栈推断 | 条件 |
| `test_environments` | 用户输入 | 否 |

### 2c. 确认

生成前通过 AskUserQuestion 展示检测结果供用户确认或纠正：

```
项目路径: {path}
技术栈: backend={x}, database={y}
仓库结构: {单仓库 / 多仓库}
主分支: {main/master}

额外配置:
- 需求产出路径: changes={c}, baseline={b}
- 测试环境？（可选，后续可添加）
```

---

## 3. 依赖验证

按顺序检查，汇总缺失项：

### 3a. Skills

检查 `~/.agents/skills/` 下存在：

- `create-team` — 团队创建/删除
- `delete-team` — 团队清理

### 3b. Agents

检查 `~/.agents/agents/` 下存在：

- `requirements-analyst.md` — 需求分析
- `architect.md` — 架构设计
- `planner.md` — 任务规划
- `backend-developer.md` — 后端开发
- `code-reviewer.md` — 代码评审
- `tester.md` — 测试验证

### 3c. Superpowers

检查 superpowers 插件是否已安装（≥5.0.0）：
- 检查 `~/.agents/skills/` 下是否有 superpowers 相关目录

---

## 4. 最终验证

```
检查清单:
  [ ] ~/.agents/skills/develop-flow/project-config.md — 存在且 root_path 正确
  [ ] {root_path}/.develop-flow/project-config.md — 存在且 root_path 正确
  [ ] {root_path}/.develop-flow/ — 目录存在
  [ ] {root_path}/{changes_path}/ — 目录存在
  [ ] {root_path}/{baseline_path}/ — 目录存在
  [ ] ~/.agents/agents/ — 包含所有必需 Agent 定义

缺失项汇总（如有）:
  [ ] Skill: xxx
  [ ] Agent: xxx
  [ ] Superpowers: 未安装
```

展示验证结果 + 所有生成文件路径 + 缺失依赖列表。

---

## 注意事项

- 已有项目配置文件**不覆盖**；提示用户手动合并
- `project-config.md` 可能含敏感信息（测试环境凭证等）— 提醒用户将 `.develop-flow/` 加入 `.gitignore`
- 如果用户有多个项目，每次运行会更新 `develop-flow/project-config.md` 中的 `root_path`（切换项目时重新运行）
