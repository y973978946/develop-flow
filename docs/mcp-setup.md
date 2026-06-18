# MCP 配置指南

本指南说明如何配置 MCP（Model Context Protocol），让 AI 能直接操作数据库、Redis 等服务。

## 快速开始

### 方案 A：使用脚本自动配置（推荐）

**Windows CMD：**
```cmd
cd D:\project\A--other\develop-flow
scripts\setup-mcp.bat D:\project\178-builder.env
```

**Windows PowerShell：**
```powershell
cd D:\project\A--other\develop-flow
.\scripts\setup-mcp.bat D:\project\178-builder.env
```

**Git Bash 或 Linux/Mac：**
```bash
cd /d/project/A--other/develop-flow
./scripts/setup-mcp.sh /d/project/178-builder.env
```

执行成功后会显示：
```
=== OpenCode MCP Auto Configuration ===
Environment file: D:\project\178-builder.env

1. Reading environment variables...
Detected configuration:
  PostgreSQL: 192.168.13.178:5432
  Redis: 192.168.13.178:6379
  RabbitMQ: 192.168.13.178:5672

2. Creating environment variable file...
  OK: Environment file created: C:\Users\admin\.config\opencode\env.bat

3. Creating opencode configuration...
  OK: Config file created: C:\Users\admin\.config\opencode\opencode.json

4. Loading environment variables...
  OK: Environment variables loaded

=== Configuration Complete ===

Environment variables are ready. You can now start opencode:
  opencode
```

然后启动 opencode：
```cmd
opencode
```

脚本会自动：
1. 读取 `builder.env` 配置文件
2. 生成 opencode MCP 配置
3. 加载环境变量

### 方案 B：手动配置

#### 1. 创建环境变量文件

**Windows** (`~/.config/opencode/env.bat`)：
```bat
set POSTGRES_HOST=192.168.1.100
set POSTGRES_PORT=5432
set POSTGRES_USER=your_username
set POSTGRES_PASSWORD=your_password
set POSTGRES_DB=your_database

set REDIS_HOST=192.168.1.100
set REDIS_PORT=6379
set REDIS_PASSWORD=your_redis_password
set REDIS_DATABASE=0

set RABBITMQ_HOST=192.168.1.100
set RABBITMQ_PORT=5672
set RABBITMQ_USER=your_rabbitmq_user
set RABBITMQ_PASSWORD=your_rabbitmq_password
set RABBITMQ_VHOST=/
```

**Linux/Mac** (`~/.config/opencode/env.sh`)：
```bash
export POSTGRES_HOST=192.168.1.100
export POSTGRES_PORT=5432
export POSTGRES_USER=your_username
export POSTGRES_PASSWORD=your_password
export POSTGRES_DB=your_database

export REDIS_HOST=192.168.1.100
export REDIS_PORT=6379
export REDIS_PASSWORD=your_redis_password
export REDIS_DATABASE=0

export RABBITMQ_HOST=192.168.1.100
export RABBITMQ_PORT=5672
export RABBITMQ_USER=your_rabbitmq_user
export RABBITMQ_PASSWORD=your_rabbitmq_password
export RABBITMQ_VHOST=/
```

#### 2. 创建 opencode 配置

`~/.config/opencode/opencode.json`：
```json
{
  "$schema": "https://opencode.ai/config.json",
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
    }
  }
}
```

#### 3. 加载环境变量并启动

```bash
# Windows
call %USERPROFILE%\.config\opencode\env.bat
opencode

# Linux/Mac
source ~/.config/opencode/env.sh
opencode
```

---

## 支持的 MCP 服务器

| 服务 | MCP 包名 | 用途 |
|------|----------|------|
| PostgreSQL | `@modelcontextprotocol/server-postgres` | 数据库查询和操作 |
| Redis | `@modelcontextprotocol/server-redis` | 缓存操作 |
| RabbitMQ | `@modelcontextprotocol/server-rabbitmq` | 消息队列管理 |
| GitLab | `@modelcontextprotocol/server-gitlab` | 代码仓库操作 |
| MySQL | `@anthropic/mysql-mcp-server` | 数据库查询和操作 |
| MongoDB | `@anthropic/mongodb-mcp-server` | 文档数据库操作 |

---

## 配置文件位置

| 类型 | 路径 |
|------|------|
| 全局配置 | `~/.config/opencode/opencode.json` |
| 项目配置 | `{project}/opencode.json` |
| 环境变量 (Windows) | `~/.config/opencode/env.bat` |
| 环境变量 (Linux/Mac) | `~/.config/opencode/env.sh` |

---

## 多环境切换

```bash
# 切换到 172 环境
scripts\setup-mcp.bat D:\project\172-builder.env

# 切换到 178 环境
scripts\setup-mcp.bat D:\project\178-builder.env
```

---

## 验证配置

```bash
# 查看所有 MCP 服务器
opencode mcp list

# 测试 PostgreSQL 连接
opencode mcp debug postgresql

# 测试 Redis 连接
opencode mcp debug redis
```

---

## MCP 配置分类

| MCP 类型 | 级别 | 说明 |
|----------|------|------|
| PostgreSQL | 项目级 | 每个项目连接的数据库不同 |
| Redis | 项目级 | 每个项目连接的 Redis 实例可能不同 |
| RabbitMQ | 项目级 | 每个项目连接的 RabbitMQ 实例可能不同 |
| GitLab | 全局 | 通用 Git 操作，所有项目共享 |

---

## 常见问题

### MCP 服务器启动失败？

检查：
1. Node.js 和 npm 是否安装：`node -v`, `npm -v`
2. 网络是否能访问 npm registry
3. 环境变量是否正确设置：`echo %POSTGRES_HOST%`

### 如何禁用某个 MCP 服务器？

在 `opencode.json` 中设置 `"enabled": false`：
```json
{
  "mcp": {
    "postgresql": {
      "enabled": false
    }
  }
}
```

### 如何查看 MCP 连接日志？

```bash
opencode mcp debug postgresql
```

### 项目配置文件中的 `${}` 变量如何处理？

opencode 使用 `{env:VAR_NAME}` 语法引用环境变量。确保：
1. 环境变量文件已正确创建
2. 启动 opencode 前已加载环境变量

---

## 安全注意事项

- `.develop-flow/` 目录包含敏感信息（数据库密码、API Token 等）
- 务必将 `.develop-flow/` 添加到 `.gitignore`
- 不要在文档或代码中硬编码密码
- 定期轮换 API Token
