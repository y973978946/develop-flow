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

# --- ripgrep PATH 修复 ---

# ripgrep 常见安装目录
RIPGREP_DIRS=(
    "$HOME/.local/bin"
    "$HOME/.local/share/opencode/bin"
)

fix_ripgrep_path() {
    # 检查 rg 是否已在 PATH 中
    if command -v rg &>/dev/null; then
        info "ripgrep 已在 PATH 中: $(command -v rg)"
        return 0
    fi

    # 搜索 ripgrep 安装目录
    for dir in "${RIPGREP_DIRS[@]}"; do
        if [ -f "$dir/rg.exe" ] || [ -f "$dir/rg" ]; then
            # 检查是否已在 PATH 中
            if echo "$PATH" | grep -q "$dir"; then
                info "ripgrep 目录已在 PATH 中: $dir"
                return 0
            fi

            # 添加到 PATH
            export PATH="$PATH:$dir"
            info "已添加 ripgrep 目录到 PATH: $dir"

            # 永久写入 shell 配置
            local shell_config=""
            if [ -f "$HOME/.bashrc" ]; then
                shell_config="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                shell_config="$HOME/.bash_profile"
            elif [ -f "$HOME/.zshrc" ]; then
                shell_config="$HOME/.zshrc"
            fi

            if [ -n "$shell_config" ]; then
                if ! grep -q "$dir" "$shell_config" 2>/dev/null; then
                    echo "export PATH=\"\$PATH:$dir\"" >> "$shell_config"
                    info "已写入 $shell_config"
                fi
            fi

            # Windows 系统永久写入
            if [ "$IS_WINDOWS" = true ]; then
                # 使用 setx 永久写入用户 PATH
                if command -v setx &>/dev/null; then
                    local win_dir=$(cygpath -w "$dir" 2>/dev/null || echo "$dir")
                    local current_path=$(reg query "HKCU\Environment" //v Path 2>/dev/null | grep Path | awk '{print $3}')
                    if [ -n "$current_path" ] && ! echo "$current_path" | grep -qi "$win_dir"; then
                        setx PATH "$current_path$win_dir;" 2>/dev/null && info "已永久添加到 Windows 用户 PATH" || warn "setx 失败，请手动添加: $win_dir"
                    fi
                fi
            fi

            return 0
        fi
    done

    warn "未找到 ripgrep 安装目录"
    warn "请手动安装 ripgrep 或添加到 PATH"
    return 1
}

fix_ripgrep_path

# --- 前置检查 ---

if [ ! -d "$OPENCODE_DIR" ]; then
    error "OpenCode 目录未找到: $OPENCODE_DIR"
    error "请先运行 OpenCode 至少一次以初始化目录。"
    exit 1
fi
info "OpenCode 目录: $OPENCODE_DIR"

# 检查 superpowers 插件（检查具体技能是否存在）
SUPERPOWERS_SKILLS="brainstorming writing-plans test-driven-development executing-plans requesting-code-review verification-before-completion finishing-a-development-branch systematic-debugging"
MISSING_SKILLS=""
for skill in $SUPERPOWERS_SKILLS; do
    if [ ! -d "$SKILLS_DIR/$skill" ]; then
        MISSING_SKILLS="$MISSING_SKILLS $skill"
    fi
done

if [ -n "$MISSING_SKILLS" ]; then
    warn "未检测到以下 superpowers 技能:$MISSING_SKILLS"
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

# --- 同步 Obsidian 集成脚本 ---

OBSIDIAN_DIR="$SKILLS_DIR/develop-flow/obsidian"
if [ -d "$SCRIPT_DIR/skills/develop-flow/obsidian" ]; then
    mkdir -p "$OBSIDIAN_DIR"
    for script in "$SCRIPT_DIR/skills/develop-flow/obsidian"/*; do
        [ -f "$script" ] || continue
        name=$(basename "$script")
        target="$OBSIDIAN_DIR/$name"
        cp "$script" "$target"
        chmod +x "$target" 2>/dev/null || true
    done
    info "已同步 Obsidian 集成脚本到 $OBSIDIAN_DIR/"
fi

# --- 同步 scripts 目录 ---

SCRIPTS_DIR="$SKILLS_DIR/develop-flow/scripts"
if [ -d "$SCRIPT_DIR/scripts" ]; then
    mkdir -p "$SCRIPTS_DIR"
    for script in "$SCRIPT_DIR/scripts"/*; do
        [ -f "$script" ] || continue
        name=$(basename "$script")
        target="$SCRIPTS_DIR/$name"
        cp "$script" "$target"
        chmod +x "$target" 2>/dev/null || true
    done
    info "已同步 scripts 到 $SCRIPTS_DIR/"
fi

# --- 同步 templates 目录 ---

TEMPLATES_DIR="$SKILLS_DIR/develop-flow/templates"
if [ -d "$SCRIPT_DIR/templates" ]; then
    mkdir -p "$TEMPLATES_DIR"
    for template in "$SCRIPT_DIR/templates"/*; do
        [ -f "$template" ] || continue
        name=$(basename "$template")
        target="$TEMPLATES_DIR/$name"
        cp "$template" "$target"
    done
    info "已同步 templates 到 $TEMPLATES_DIR/"
fi

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
