# Obsidian 集成配置指南

## 架构

```
develop-flow learn
    ↓ distill
playbook.md（全局经验）
    ↓ sync-playbook-to-obsidian.sh
Obsidian Vault（长期知识库）
    ↓ RAG（Copilot 插件）
下次 run 自动注入
```

## 前置条件

1. Obsidian 已安装
2. Obsidian Vault 路径已知（默认 `$HOME/Obsidian`）
3. 已安装 Copilot 插件（可选，用于 RAG）

## 配置步骤

### 步骤 1：设置环境变量

```bash
# Windows (Git Bash)
export OBSIDIAN_VAULT="D:/你的ObsidianVault路径"

# 或永久写入 .bashrc
echo 'export OBSIDIAN_VAULT="D:/你的ObsidianVault路径"' >> ~/.bashrc
```

### 步骤 2：创建目录结构

```bash
mkdir -p "$OBSIDIAN_VAULT/AI知识库"
```

### 步骤 3：同步 playbook 到 Obsidian

```bash
bash ~/.agents/skills/develop-flow/obsidian/sync-playbook-to-obsidian.sh
```

### 步骤 4：配置 Obsidian Copilot（可选）

1. Obsidian → 设置 → 第三方插件 → 安装 Copilot
2. Copilot 设置：
   - Base URL: `http://127.0.0.1:14096/v1`（如果用 OpenCode）
   - 或使用你自己的 API
3. 开启 `Relevant Notes`：自动检索库内相关笔记作为上下文

### 步骤 5：从 Obsidian 同步回 playbook（可选）

1. 在 Obsidian 中创建 `AI知识库/develop-flow-手动笔记.md`
2. 写入你想补充的经验
3. 运行：

```bash
bash ~/.agents/skills/develop-flow/obsidian/sync-obsidian-to-playbook.sh
```

## 自动同步（可选）

### 方案 1：定时任务（cron）

```bash
# 每小时同步一次
crontab -e
0 * * * * bash ~/.agents/skills/develop-flow/obsidian/sync-playbook-to-obsidian.sh
```

### 方案 2：distill 后自动同步

在 distill 完成后自动调用同步脚本：

```bash
# 在 distill 流程末尾添加
bash ~/.agents/skills/develop-flow/obsidian/sync-playbook-to-obsidian.sh
```

## 文件说明

| 文件 | 位置 | 说明 |
|------|------|------|
| `playbook.md` | `~/.agents/skills/develop-flow/` | 全局经验源文件 |
| `develop-flow-playbook.md` | `$OBSIDIAN_VAULT/AI知识库/` | Obsidian 中的副本（只读） |
| `develop-flow-手动笔记.md` | `$OBSIDIAN_VAULT/AI知识库/` | 手动补充的经验（可编辑） |

## 常见问题

### Q: Obsidian 路径怎么找？

```bash
# Windows
ls ~/Documents/Obsidian* 2>/dev/null || ls ~/Obsidian* 2>/dev/null

# 或在 Obsidian 中查看：设置 → 关于 → 库路径
```

### Q: 同步失败？

1. 检查路径是否正确
2. 检查 Obsidian 是否正在运行（可能锁定文件）
3. 检查权限：`ls -la "$OBSIDIAN_VAULT/AI知识库/"`

### Q: 如何只同步部分内容？

编辑 `sync-playbook-to-obsidian.sh`，添加过滤条件：

```bash
# 只同步"通用常见坑"部分
sed -n '/## 通用常见坑/,/## /p' "$PLAYBOOK_SOURCE" > "$KNOWLEDGE_TARGET"
```
