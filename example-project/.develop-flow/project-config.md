# Builder SG Security 项目配置

> **用途**: Agent 和 Skill 的共享项目级配置。消费者直接 Read 此文件。

---

## 基本信息

root_path: "D:/project/A--other/develop-flow/example-project"
tech_stack: { backend: "java/spring", database: "postgresql" }

## 仓库架构

单仓库：
backend: { main_repo: "." }

## Git 配置

git:
  main_branch: "master"

## 需求产出目录

openspec:
  changes_path: "openspec/changes"
  baseline_path: "openspec/specs"

## 数据库 MCP

映射 ~/.agents/settings.json 中 mcpServers 的 MCP 工具名：

databases:
  main: { mcp: "mcp__builder_sg_security__postgresql_query", desc: "主数据库" }

## 构建命令

build_commands:
  backend: "mvn clean package -DskipTests"

## 迁移

migration:
  steps:
    - "mvn flyway:migrate"
  note: "仅在创建/修改迁移文件时运行"

## MCP 配置

### 项目级 MCP

```yaml
mcp:
  project:
    # PostgreSQL MCP（项目级）
    postgresql:
      name: "mcp__builder_sg_security__postgresql"
      type: "postgresql"
      connection:
        host: "localhost"
        port: "5432"
        database: "builder_db"
        username: "postgres"
        password: "password123"
      description: "Builder SG Security 项目数据库"
    
    # Redis MCP（项目级）
    redis:
      name: "mcp__builder_sg_security__redis"
      type: "redis"
      connection:
        host: "localhost"
        port: "6379"
        password: ""
        database: "0"
      description: "Builder SG Security 项目 Redis"
    
    # RabbitMQ MCP（项目级）
    rabbitmq:
      name: "mcp__builder_sg_security__rabbitmq"
      type: "rabbitmq"
      connection:
        host: "localhost"
        port: "5672"
        username: "guest"
        password: "guest"
        vhost: "/"
      description: "Builder SG Security 项目 RabbitMQ"
  
  global:
    # GitLab MCP（全局）
    gitlab:
      name: "mcp__gitlab"
      type: "gitlab"
      connection:
        url: "https://gitlab.example.com"
        token: "glpat-xxxxxxxxxxxxxxxxxxxx"
        project_id: "12345"
      description: "GitLab 代码仓库"
```