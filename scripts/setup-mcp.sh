#!/bin/bash
# 自动配置 opencode MCP
# 用法: ./setup-opencode-mcp.sh [env-file]

set -e

ENV_FILE="${1:-D:/project/178-builder.env}"
OPENCODE_CONFIG="$HOME/.config/opencode/opencode.jsonc"

echo "=== OpenCode MCP 自动配置 ==="
echo "环境变量文件: $ENV_FILE"

# 检查文件是否存在
if [ ! -f "$ENV_FILE" ]; then
    echo "错误: 文件不存在 $ENV_FILE"
    exit 1
fi

# 读取环境变量
echo "1. 读取环境变量..."
source "$ENV_FILE"

# 显示读取到的关键配置
echo ""
echo "检测到的配置:"
echo "  PostgreSQL: ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo "  Redis: ${REDIS_HOST}:${REDIS_PORT}"
echo "  RabbitMQ: ${RABBITMQ_HOST}:${RABBITMQ_PORT}"
echo "  GitLab: ${GITLAB_URL}"
echo ""

# 创建环境变量文件供 opencode 使用
echo "2. 创建环境变量文件..."
cat > "$HOME/.config/opencode/env.sh" << EOF
# OpenCode MCP 环境变量
# 由 setup-opencode-mcp.sh 自动生成
# 使用方法: source ~/.config/opencode/env.sh && opencode

# PostgreSQL
export POSTGRES_HOST="${POSTGRES_HOST}"
export POSTGRES_PORT="${POSTGRES_PORT}"
export POSTGRES_USER="${POSTGRES_USER}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD}"
export POSTGRES_DB="${POSTGRES_DB:-builder_db}"

# Redis
export REDIS_HOST="${REDIS_HOST}"
export REDIS_PORT="${REDIS_PORT}"
export REDIS_PASSWORD="${REDIS_PASSWORD}"
export REDIS_DATABASE="${REDIS_DATABASE:-0}"

# RabbitMQ
export RABBITMQ_HOST="${RABBITMQ_HOST}"
export RABBITMQ_PORT="${RABBITMQ_PORT}"
export RABBITMQ_USER="${RABBITMQ_USER}"
export RABBITMQ_PASSWORD="${RABBITMQ_PASSWORD}"
export RABBITMQ_VHOST="${RABBITMQ_VHOST:-/}"

# GitLab
export GITLAB_URL="${GITLAB_URL}"
export GITLAB_TOKEN="${GITLAB_TOKEN}"
export GITLAB_PROJECT_ID="${GITLAB_PROJECT_ID}"
EOF

echo "   ✓ 环境变量文件已创建: ~/.config/opencode/env.sh"

# 备份现有配置
if [ -f "$OPENCODE_CONFIG" ]; then
    echo "3. 备份现有配置..."
    cp "$OPENCODE_CONFIG" "$OPENCODE_CONFIG.bak"
    echo "   ✓ 备份完成: $OPENCODE_CONFIG.bak"
fi

# 读取现有配置或创建新配置
echo "4. 更新 opencode 配置..."
if [ -f "$OPENCODE_CONFIG" ]; then
    # 使用 jq 合并配置（如果可用）
    if command -v jq &> /dev/null; then
        echo "   使用 jq 合并配置..."
        # 读取现有配置
        EXISTING_CONFIG=$(cat "$OPENCODE_CONFIG")
        
        # 创建 MCP 配置
        MCP_CONFIG='{
          "mcp": {
            "postgresql": {
              "type": "local",
              "command": ["npx", "-y", "@modelcontextprotocol/server-postgres"],
              "environment": {
                "POSTGRES_HOST": "{env:POSTGRES_HOST}",
                "POSTGRES_PORT": "{env:POSTGRES_PORT}",
                "POSTGRES_USER": "{env:POSTGRES_USER}",
                "POSTGRES_PASSWORD": "{env:POSTGRES_PASSWORD}",
                "POSTGRES_DATABASE": "{env:POSTGRES_DB}"
              },
              "enabled": true
            },
            "redis": {
              "type": "local",
              "command": ["npx", "-y", "@modelcontextprotocol/server-redis"],
              "environment": {
                "REDIS_HOST": "{env:REDIS_HOST}",
                "REDIS_PORT": "{env:REDIS_PORT}",
                "REDIS_PASSWORD": "{env:REDIS_PASSWORD}",
                "REDIS_DB": "{env:REDIS_DATABASE}"
              },
              "enabled": true
            },
            "rabbitmq": {
              "type": "local",
              "command": ["npx", "-y", "@modelcontextprotocol/server-rabbitmq"],
              "environment": {
                "RABBITMQ_HOST": "{env:RABBITMQ_HOST}",
                "RABBITMQ_PORT": "{env:RABBITMQ_PORT}",
                "RABBITMQ_USER": "{env:RABBITMQ_USER}",
                "RABBITMQ_PASSWORD": "{env:RABBITMQ_PASSWORD}",
                "RABBITMQ_VHOST": "{env:RABBITMQ_VHOST}"
              },
              "enabled": true
            },
            "gitlab": {
              "type": "local",
              "command": ["npx", "-y", "@modelcontextprotocol/server-gitlab"],
              "environment": {
                "GITLAB_URL": "{env:GITLAB_URL}",
                "GITLAB_TOKEN": "{env:GITLAB_TOKEN}",
                "GITLAB_PROJECT_ID": "{env:GITLAB_PROJECT_ID}"
              },
              "enabled": true
            }
          }
        }'
        
        # 合并配置
        echo "$EXISTING_CONFIG" | jq -s '.[0] * .[1]' - <(echo "$MCP_CONFIG") > "$OPENCODE_CONFIG"
        echo "   ✓ 配置已合并"
    else
        echo "   ⚠ 未找到 jq，请手动合并配置"
        echo "   MCP 配置已保存到: $HOME/.config/opencode/mcp-config.json"
        # 保存单独的 MCP 配置供手动合并
        cat > "$HOME/.config/opencode/mcp-config.json" << EOF
{
  "mcp": {
    "postgresql": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-postgres"],
      "environment": {
        "POSTGRES_HOST": "{env:POSTGRES_HOST}",
        "POSTGRES_PORT": "{env:POSTGRES_PORT}",
        "POSTGRES_USER": "{env:POSTGRES_USER}",
        "POSTGRES_PASSWORD": "{env:POSTGRES_PASSWORD}",
        "POSTGRES_DATABASE": "{env:POSTGRES_DB}"
      },
      "enabled": true
    },
    "redis": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-redis"],
      "environment": {
        "REDIS_HOST": "{env:REDIS_HOST}",
        "REDIS_PORT": "{env:REDIS_PORT}",
        "REDIS_PASSWORD": "{env:REDIS_PASSWORD}",
        "REDIS_DB": "{env:REDIS_DATABASE}"
      },
      "enabled": true
    },
    "rabbitmq": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-rabbitmq"],
      "environment": {
        "RABBITMQ_HOST": "{env:RABBITMQ_HOST}",
        "RABBITMQ_PORT": "{env:RABBITMQ_PORT}",
        "RABBITMQ_USER": "{env:RABBITMQ_USER}",
        "RABBITMQ_PASSWORD": "{env:RABBITMQ_PASSWORD}",
        "RABBITMQ_VHOST": "{env:RABBITMQ_VHOST}"
      },
      "enabled": true
    },
    "gitlab": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-gitlab"],
      "environment": {
        "GITLAB_URL": "{env:GITLAB_URL}",
        "GITLAB_TOKEN": "{env:GITLAB_TOKEN}",
        "GITLAB_PROJECT_ID": "{env:GITLAB_PROJECT_ID}"
      },
      "enabled": true
    }
  }
}
EOF
    fi
else
    echo "   创建新配置文件..."
    cat > "$OPENCODE_CONFIG" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "mcp": {
    "postgresql": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-postgres"],
      "environment": {
        "POSTGRES_HOST": "{env:POSTGRES_HOST}",
        "POSTGRES_PORT": "{env:POSTGRES_PORT}",
        "POSTGRES_USER": "{env:POSTGRES_USER}",
        "POSTGRES_PASSWORD": "{env:POSTGRES_PASSWORD}",
        "POSTGRES_DATABASE": "{env:POSTGRES_DB}"
      },
      "enabled": true
    },
    "redis": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-redis"],
      "environment": {
        "REDIS_HOST": "{env:REDIS_HOST}",
        "REDIS_PORT": "{env:REDIS_PORT}",
        "REDIS_PASSWORD": "{env:REDIS_PASSWORD}",
        "REDIS_DB": "{env:REDIS_DATABASE}"
      },
      "enabled": true
    },
    "rabbitmq": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-rabbitmq"],
      "environment": {
        "RABBITMQ_HOST": "{env:RABBITMQ_HOST}",
        "RABBITMQ_PORT": "{env:RABBITMQ_PORT}",
        "RABBITMQ_USER": "{env:RABBITMQ_USER}",
        "RABBITMQ_PASSWORD": "{env:RABBITMQ_PASSWORD}",
        "RABBITMQ_VHOST": "{env:RABBITMQ_VHOST}"
      },
      "enabled": true
    },
    "gitlab": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-gitlab"],
      "environment": {
        "GITLAB_URL": "{env:GITLAB_URL}",
        "GITLAB_TOKEN": "{env:GITLAB_TOKEN}",
        "GITLAB_PROJECT_ID": "{env:GITLAB_PROJECT_ID}"
      },
      "enabled": true
    }
  }
}
EOF
fi

echo ""
echo "=== 配置完成 ==="
echo ""
echo "使用方法："
echo "  1. 加载环境变量: source ~/.config/opencode/env.sh"
echo "  2. 启动 opencode: opencode"
echo ""
echo "切换环境："
echo "  使用 172 环境: ./setup-opencode-mcp.sh D:/project/172-builder.env"
echo "  使用 178 环境: ./setup-opencode-mcp.sh D:/project/178-builder.env"