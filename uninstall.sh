#!/bin/bash
# develop-flow uninstaller — removes symlinks only
set -e

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.agents}"
SKILLS_DIR="$OPENCODE_DIR/skills"
AGENTS_DIR="$OPENCODE_DIR/agents"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo "正在卸载 develop-flow..."

# --- 清理 Skills ---

SKILL_COUNT=0
for name in develop-flow init-flow create-team delete-team; do
    target="$SKILLS_DIR/$name"
    if [ -L "$target" ]; then
        # 只删除指向本仓库的符号链接
        link_target=$(readlink "$target" 2>/dev/null || true)
        if echo "$link_target" | grep -q "develop-flow"; then
            rm "$target"
            info "已移除 skill: $name"
            ((SKILL_COUNT++))
        else
            warn "跳过 $name（非 develop-flow 安装的链接）"
        fi
    fi
done

# --- 清理 Agents ---

AGENT_COUNT=0
for agent_file in $(dirname "$0")/agents/*.md; do
    [ -f "$agent_file" ] || continue
    name=$(basename "$agent_file")
    target="$AGENTS_DIR/$name"
    if [ -L "$target" ]; then
        link_target=$(readlink "$target" 2>/dev/null || true)
        if echo "$link_target" | grep -q "develop-flow"; then
            rm "$target"
            info "已移除 agent: ${name%.md}"
            ((AGENT_COUNT++))
        fi
    fi
done

echo ""
echo "========================================="
echo "  develop-flow 已卸载"
echo "========================================="
echo ""
echo "已移除: $SKILL_COUNT 个 skills, $AGENT_COUNT 个 agents"
echo "项目目录和配置文件已保留。"
echo ""
