#!/bin/bash
# generate-agents-md.sh
# 扫描项目 docs/ 目录，自动生成/更新 AGENTS.md

set -e

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 参数检查
if [ -z "$1" ]; then
    echo "Usage: $0 <project_root_path>"
    exit 1
fi

PROJECT_ROOT="$1"
AGENTS_FILE="$PROJECT_ROOT/AGENTS.md"
DOCS_DIR="$PROJECT_ROOT/docs"

# 检查项目目录
if [ ! -d "$PROJECT_ROOT" ]; then
    warn "项目目录不存在: $PROJECT_ROOT"
    exit 1
fi

# 获取项目名称
PROJECT_NAME=$(basename "$PROJECT_ROOT")

# 检查 AGENTS.md 是否已存在
if [ -f "$AGENTS_FILE" ]; then
    warn "AGENTS.md 已存在，将更新参考文档部分（不覆盖其他内容）"
    NEED_UPDATE=true
else
    NEED_UPDATE=false
fi

info "正在为 $PROJECT_NAME 更新 AGENTS.md..."

# 如果是新文件，写入头部
if [ "$NEED_UPDATE" = false ]; then
    cat > "$AGENTS_FILE" << EOF
# AGENTS.md - $PROJECT_NAME 项目开发指南

> 由 develop-flow 自动生成。即使不使用 develop-flow skill，也能让 Agent 遵守开发规范。

---

## 项目概述

（待填写）

## 技术栈

（待填写）

## 构建命令

（待填写）

## 代码规范

（待填写）

EOF
fi

# 扫描 docs/ 目录，收集所有 md 文件
if [ -d "$DOCS_DIR" ]; then
    # 收集所有 md 文件
    ALL_DOCS=$(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null | sort)
    
    if [ -n "$ALL_DOCS" ]; then
        # 检查是否已存在"参考文档"部分
        if ! grep -q "## 参考文档" "$AGENTS_FILE"; then
            echo "" >> "$AGENTS_FILE"
            echo "## 参考文档" >> "$AGENTS_FILE"
            echo "" >> "$AGENTS_FILE"
        fi
        
        # 添加所有文档引用（去重）
        for doc in $ALL_DOCS; do
            doc_name=$(basename "$doc" .md)
            doc_rel_path="docs/$(basename "$doc")"
            
            # 检查是否已存在该文档引用
            if ! grep -q "$doc_name" "$AGENTS_FILE" 2>/dev/null; then
                echo "- [$doc_name]($doc_rel_path)" >> "$AGENTS_FILE"
            fi
        done
        
        echo "" >> "$AGENTS_FILE"
    fi
fi

# 添加项目知识库部分（如果是新文件或不存在该部分）
if ! grep -q "## 项目知识库" "$AGENTS_FILE" 2>/dev/null; then
    cat >> "$AGENTS_FILE" << EOF
## 项目知识库

> 由 develop-flow learn 自动维护。包含项目专属经验和常见坑。

EOF

    # 检查是否存在 knowledge.md
    KNOWLEDGE_FILE="$PROJECT_ROOT/.develop-flow/knowledge.md"
    if [ -f "$KNOWLEDGE_FILE" ]; then
        echo "- [项目知识库](.develop-flow/knowledge.md) - learn distill 自动维护" >> "$AGENTS_FILE"
    else
        echo "- 项目知识库尚未生成。运行 /develop-flow 后自动生成。" >> "$AGENTS_FILE"
    fi

    echo "" >> "$AGENTS_FILE"
fi

info "AGENTS.md 已更新: $AGENTS_FILE"
