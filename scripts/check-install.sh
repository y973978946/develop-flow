#!/bin/bash
# 检查 develop-flow 安装状态

echo "=== Develop-Flow 安装状态检查 ==="
echo ""

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.agents}"
SKILLS_DIR="$OPENCODE_DIR/skills"
AGENTS_DIR="$OPENCODE_DIR/agents"

echo "1. 检查目录结构"
echo "   OPENCODE_DIR: $OPENCODE_DIR"
echo "   SKILLS_DIR: $SKILLS_DIR"
echo "   AGENTS_DIR: $AGENTS_DIR"
echo ""

echo "2. 检查 skills 目录内容"
if [ -d "$SKILLS_DIR" ]; then
    echo "   ✓ skills 目录存在"
    echo ""
    echo "   列出所有 skills:"
    ls -la "$SKILLS_DIR/" 2>/dev/null | grep -E "^l|^d" | while read line; do
        echo "   $line"
    done
else
    echo "   ✗ skills 目录不存在"
fi
echo ""

echo "3. 检查 develop-flow skill"
if [ -L "$SKILLS_DIR/develop-flow" ]; then
    echo "   ✓ develop-flow 符号链接存在"
    echo "   指向: $(readlink "$SKILLS_DIR/develop-flow")"
    
    # 检查目标是否存在
    if [ -d "$SKILLS_DIR/develop-flow" ]; then
        echo "   ✓ 目标目录可访问"
        echo ""
        echo "   develop-flow 内容:"
        ls -la "$SKILLS_DIR/develop-flow/" 2>/dev/null | head -20
    else
        echo "   ✗ 目标目录不可访问（符号链接可能损坏）"
    fi
elif [ -d "$SKILLS_DIR/develop-flow" ]; then
    echo "   ⚠ develop-flow 是真实目录（非符号链接）"
    echo "   内容:"
    ls -la "$SKILLS_DIR/develop-flow/" 2>/dev/null | head -20
else
    echo "   ✗ develop-flow 不存在"
fi
echo ""

echo "4. 检查其他 skills"
for skill in create-team delete-team init-flow; do
    if [ -L "$SKILLS_DIR/$skill" ]; then
        echo "   ✓ $skill 已安装（符号链接）"
    elif [ -d "$SKILLS_DIR/$skill" ]; then
        echo "   ⚠ $skill 是真实目录"
    else
        echo "   ✗ $skill 未安装"
    fi
done
echo ""

echo "5. 检查 agents"
if [ -d "$AGENTS_DIR" ]; then
    echo "   ✓ agents 目录存在"
    echo ""
    echo "   已安装的 agents:"
    ls -la "$AGENTS_DIR/" 2>/dev/null | grep -E "\.md$" | while read line; do
        echo "   $line"
    done
else
    echo "   ✗ agents 目录不存在"
fi
echo ""

echo "6. 检查源目录"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "   源目录: $SCRIPT_DIR"
echo ""
echo "   skills 源目录内容:"
ls -la "$SCRIPT_DIR/skills/" 2>/dev/null | while read line; do
    echo "   $line"
done
echo ""

echo "=== 诊断完成 ==="