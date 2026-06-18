#!/bin/bash
# develop-flow installer — symlinks skills and agents into OpenCode directory
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# OpenCode 工作目录（可通过环境变量覆盖）
OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.agents}"
SKILLS_DIR="$OPENCODE_DIR/skills"
AGENTS_DIR="$OPENCODE_DIR/agents"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检测是否为 Windows (Git Bash/MSYS)
IS_WINDOWS=false
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WINDIR" ]]; then
    IS_WINDOWS=true
fi

# 删除目标（兼容 Windows 符号链接）
remove_target() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target" 2>/dev/null || true
    fi
}

# --- 前置检查 ---

if [ ! -d "$OPENCODE_DIR" ]; then
    error "OpenCode 目录未找到: $OPENCODE_DIR"
    error "请先运行 OpenCode 至少一次以初始化目录。"
    exit 1
fi
info "OpenCode 目录: $OPENCODE_DIR"

# 检查 superpowers 插件
if [ ! -d "$SKILLS_DIR" ] || ! ls "$SKILLS_DIR"/superpowers* &>/dev/null 2>&1; then
    warn "未在 $SKILLS_DIR/ 检测到 superpowers 插件"
    warn "develop-flow 需要 superpowers >= 5.0.0。请在使用前安装。"
fi

# --- 安装 Skills ---

mkdir -p "$SKILLS_DIR"

SKILL_COUNT=0
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    name=$(basename "$skill_dir")
    target="$SKILLS_DIR/$name"

    # 删除已存在的目标
    remove_target "$target"

    # 创建符号链接
    if [ "$IS_WINDOWS" = true ]; then
        # Windows: 使用 cp -r 作为备选方案（符号链接在 Windows 上可能有问题）
        if ln -s "$skill_dir" "$target" 2>/dev/null; then
            info "已链接 skill: $name"
        else
            # 符号链接失败，使用复制
            cp -r "$skill_dir" "$target"
            info "已复制 skill: $name (Windows 兼容模式)"
        fi
    else
        ln -s "$skill_dir" "$target"
        info "已链接 skill: $name"
    fi
    SKILL_COUNT=$((SKILL_COUNT + 1))
done

info "已安装 $SKILL_COUNT 个 skills"

# --- 安装 Agents ---

mkdir -p "$AGENTS_DIR"

AGENT_COUNT=0
for agent_file in "$SCRIPT_DIR/agents"/*.md; do
    [ -f "$agent_file" ] || continue
    name=$(basename "$agent_file")
    target="$AGENTS_DIR/$name"

    # 删除已存在的目标
    remove_target "$target"

    # 创建符号链接
    if [ "$IS_WINDOWS" = true ]; then
        if ln -s "$agent_file" "$target" 2>/dev/null; then
            info "已链接 agent: ${name%.md}"
        else
            cp "$agent_file" "$target"
            info "已复制 agent: ${name%.md} (Windows 兼容模式)"
        fi
    else
        ln -s "$agent_file" "$target"
        info "已链接 agent: ${name%.md}"
    fi
    AGENT_COUNT=$((AGENT_COUNT + 1))
done

info "已安装 $AGENT_COUNT 个 agents"

# --- 总结 ---

echo ""
echo "========================================="
echo "  develop-flow 安装成功！"
echo "========================================="
echo ""
echo "Skills:  $SKILL_COUNT → $SKILLS_DIR/"
echo "Agents:  $AGENT_COUNT → $AGENTS_DIR/"
echo ""
echo "下一步:"
echo "  1. 确保 superpowers 插件已安装 (>= 5.0.0)"
echo "  2. 运行: /init-flow"
echo "  3. 运行: /develop-flow <需求描述>"
echo ""
