---
partOf: develop-flow
version: 1.0.0
description: 项目配置示例模板。用户参考此文件手动创建 {root_path}/.develop-flow/project-config.md。
---

# 项目配置示例

> 本文件是项目配置的示例模板。
> 实际使用时，`/init-flow` 会在 `{root_path}/.develop-flow/project-config.md` 自动生成。
> 也可以手动复制本文件并填入实际值。

---

## 基本信息

root_path: "/path/to/your/project"
tech_stack: { backend: "laravel", database: "mysql" }

## 运行环境

# 如果使用 Docker：
docker: { container: "your-container", workdir: "/workspace/your-project/" }
artisan: 'docker exec your-container bash -c "cd /workspace/your-project && {cmd}"'

## 仓库架构

# 单仓库：
backend: { main_repo: "." }

# 多仓库（取消注释并填写）：
# backend: { main_repo: "backend/", modules_path: "backend/modules/" }
# modules:
#   - { name: "module-a", desc: "模块 A", path: "backend/modules/module-a/" }

## Git 配置

git:
  main_branch: "master"  # 或 "main"

## 需求产出目录

openspec:
  changes_path: "openspec/changes"      # develop-flow 工作产出目录（相对于 root_path）
  baseline_path: "openspec/specs"       # 系统基线文档（可选，留空跳过基线关联检查）

---

## 构建命令（Agent 参考）

build_commands:
  backend: ""               # 通常 PHP 项目不需要

## 数据库迁移（Phase 3 后端开发参考）

migration:
  steps:
    - "php artisan migrate --force"
    - "php artisan tenancy:migrate --force"  # 如果多租户
  note: "仅在创建/修改迁移文件时运行"

## 数据库 MCP

# 映射 ~/.agents/settings.json 中 mcpServers 的 MCP 工具名
databases:
  main: { mcp: "mcp__your-db-name__mysql_query", desc: "主数据库" }

## 测试环境

test_environments:
  default:
    url: "http://your-test-env.example.com"
    account: ""   # 填入测试账号
    password: ""  # 填入测试密码
    desc: "默认测试环境"

## 部署检查清单

- [ ] 确认 git 分支
- [ ] 数据库迁移（如有迁移变更）
- [ ] 路由缓存清理（如有路由变更）
