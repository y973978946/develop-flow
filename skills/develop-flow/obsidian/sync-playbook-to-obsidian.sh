#!/bin/bash
# sync-playbook-to-obsidian.sh
# 将 develop-flow playbook.md 同步到 Obsidian 知识库

set -e

# 配置（按实际修改）
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Obsidian}"
PLAYBOOK_SOURCE="$HOME/.agents/skills/develop-flow/playbook.md"
KNOWLEDGE_TARGET="$OBSIDIAN_VAULT/AI知识库/develop-flow-playbook.md"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 检查源文件
if [ ! -f "$PLAYBOOK_SOURCE" ]; then
    warn "playbook.md 不存在: $PLAYBOOK_SOURCE"
    exit 1
fi

# 创建目标目录
mkdir -p "$(dirname "$KNOWLEDGE_TARGET")"

# 同步（带时间戳头部）
cat > "$KNOWLEDGE_TARGET" << EOF
---
title: Develop-Flow 全局 Playbook
tags: [ai, develop-flow, playbook, auto-sync]
last_sync: $(date -Iseconds)
source: ~/.agents/skills/develop-flow/playbook.md
---

# Develop-Flow 全局 Playbook

> 由 learn distill 自动维护，同步自 develop-flow。
> 每条带溯源，超 200 行自动去重。

$(cat "$PLAYBOOK_SOURCE")
EOF

info "已同步到: $KNOWLEDGE_TARGET"
info "Obsidian 中打开此文件即可查看"
