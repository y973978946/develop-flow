#!/bin/bash
# sync-obsidian-to-playbook.sh
# 将 Obsidian 知识库中的手动笔记同步回 develop-flow playbook.md

set -e

# 配置（按实际修改）
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Obsidian}"
OBSIDIAN_SOURCE="$OBSIDIAN_VAULT/AI知识库/develop-flow-手动笔记.md"
PLAYBOOK_TARGET="$HOME/.agents/skills/develop-flow/playbook.md"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 检查源文件
if [ ! -f "$OBSIDIAN_SOURCE" ]; then
    warn "手动笔记不存在: $OBSIDIAN_SOURCE"
    warn "请先在 Obsidian 中创建此文件"
    exit 1
fi

# 提取手动笔记内容（跳过 YAML frontmatter）
CONTENT=$(sed -n '/^---$/,/^---$/d; p' "$OBSIDIAN_SOURCE")

if [ -z "$CONTENT" ]; then
    warn "手动笔记为空"
    exit 0
fi

# 追加到 playbook.md
cat >> "$PLAYBOOK_TARGET" << EOF

## Obsidian 手动笔记（$(date +%Y-%m-%d)）

$CONTENT

> source: obsidian-manual @ $(date -Iseconds), signal: manual_note
EOF

info "已同步到 playbook.md"
info "下次 run 时会自动注入相关经验"
