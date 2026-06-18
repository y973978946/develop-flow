**English** | [中文](README.zh-CN.md)

# Develop-Flow: Full-Stack Backend Agent Team Development Workflow

An [OpenCode](https://opencode.ai) skill that coordinates multi-agent teams to handle the complete backend development lifecycle: requirements analysis, architecture design, task planning, TDD development, code review, and test verification.

Requirements come from Feishu documents or text descriptions (not Jira), for pure backend development without frontend pages.

```
Requirements Input → 6 Phases + 6 Gates → Code Ready (to commit)

Phase 1: Requirements Analysis → proposal.md + design.md
Phase 2: Task Planning         → tasks.md
Phase 3: TDD Development       → Implementation Code
Phase 4: Code Review           → Structured Review Report
Phase 5: Test Verification     → Evidence-based Test Report
Phase 6: Wrap-up               → Cleanup + Summary
```

Each Phase ends with a **Gate** — Leader summarizes Phase output for confirmation before continuing. Two modes: **Semi-automatic** (default, you confirm each Gate) or **Fully automatic** (Gates auto-pass, only pause on exceptions).

## Architecture

- **Leader** (main session) coordinates, decides, routes — never executes directly
- **Hub-and-Spoke** communication: all Agent messages routed through Leader
- **6 specialized Agents** spawned on demand
- **Superpowers methodology** integrated into each Phase

## Prerequisites

| Dependency | Version | Installation |
|------------|---------|--------------|
| **OpenCode CLI** | Latest | [OpenCode Docs](https://opencode.ai) |
| **superpowers** plugin | >= 5.0.0 | Included in OpenCode skills |

## Installation

```bash
# 1. Clone
git clone <repo-url> develop-flow
cd develop-flow

# 2. Install (copy skills + agents to ~/.agents/)
chmod +x install.sh
./install.sh

# 3. Verify
ls ~/.agents/skills/develop-flow/      # Should show skill.md, phases/ etc.
ls ~/.agents/agents/requirements-analyst.md  # Should exist
```

> **Windows users**: The script auto-detects Windows environment and uses copy instead of symlinks.

### Uninstall

```bash
./uninstall.sh
```

Only removes symlinks/copies. Cloned repository is preserved.

## Quick Start

### Step 1: Initialize Project

```
/init-flow
```

One-click setup — auto-detect tech stack, generate config files, verify dependencies.

Or manually: copy `skills/develop-flow/project-config.example.md` to `<project-root>/.develop-flow/project-config.md` and fill in values.

### Step 2: Configure MCP (Optional but Recommended)

MCP (Model Context Protocol) enables AI to directly operate databases, Redis, and other services.

#### Auto Configuration (Recommended)

**Windows CMD:**
```cmd
cd D:\project\A--other\develop-flow
scripts\setup-mcp.bat D:\project\178-builder.env
```

**Windows PowerShell:**
```powershell
cd D:\project\A--other\develop-flow
.\scripts\setup-mcp.bat D:\project\178-builder.env
```

**Git Bash or Linux/Mac:**
```bash
cd /d/project/A--other/develop-flow
./scripts/setup-mcp.sh /d/project/178-builder.env
```

After successful execution, you will see:
```
=== Configuration Complete ===
Environment variables are ready. You can now start opencode:
  opencode
```

Then start opencode:
```cmd
opencode
```

> See [docs/mcp-setup.md](docs/mcp-setup.md) for detailed configuration.

### Step 3: Run develop-flow

```bash
# Execute development flow (auto git pull)
/develop-flow User authentication module needs JWT and refresh token support
```

Or provide Feishu document content:

```
/develop-flow Here is the requirement content from Feishu document:...
```

### Step 4: Review Gates and Iterate

Leader presents summary at each Gate. Semi-automatic mode (default) continues after confirmation. Fully automatic mode auto-passes — only pauses on exceptions.

## Agent Definitions

### Core Agents (Required for workflow)

| Agent | Phase | Purpose |
|-------|-------|---------|
| `requirements-analyst` | 1, 6 | Analyze requirements, generate proposal, generate summary |
| `architect` | 1 | Generate design.md and architecture decisions |
| `planner` | 2 | Break down into TDD tasks |
| `backend-developer` | 2, 3 | Implement backend code |
| `code-reviewer` | 4 | Review branch changes and grade |
| `tester` | 5 | Run tests and report bugs |

### Auxiliary Agents (Standalone or on-demand)

| Agent | Purpose |
|-------|---------|
| `build-error-resolver` | Quick fix for build errors |
| `code-explorer` | Codebase exploration and understanding |
| `code-simplifier` | Code simplification and refinement |
| `database-reviewer` | Database review (MySQL/PostgreSQL) |
| `performance-optimizer` | Performance analysis and optimization |
| `security-reviewer` | Security vulnerability detection |
| `doc-updater` | Documentation update and maintenance |
| `refactor-cleaner` | Dead code cleanup and refactoring |
| `tdd-guide` | TDD methodology guidance |

## Configuration

```
~/.agents/skills/develop-flow/project-config.md     ← Flow config (root_path, output paths)
<project-root>/.develop-flow/project-config.md      ← Project config (tech stack, database, test env)
~/.config/opencode/opencode.json                    ← OpenCode MCP config
~/.config/opencode/env.bat                          ← Environment variables (Windows)
~/.config/opencode/env.sh                           ← Environment variables (Linux/Mac)
```

> See [docs/mcp-setup.md](docs/mcp-setup.md) for detailed MCP configuration.

## Directory Structure

```
develop-flow/
├── README.md                        ← Main documentation (English)
├── README.zh-CN.md                  ← Chinese documentation
├── CLAUDE.md                        ← Architecture guide
├── AGENTS.md                        ← Agent quick reference
├── install.sh                       ← One-click installation
├── uninstall.sh                     ← Uninstall
├── docs/                            ← Documentation directory
│   └── mcp-setup.md                 ← MCP configuration guide
├── scripts/                         ← Scripts directory
│   ├── setup-mcp.bat                ← Windows MCP configuration
│   ├── setup-mcp.sh                 ← Linux/Mac MCP configuration
│   └── check-install.sh             ← Installation check
├── templates/                       ← Templates directory
│   └── opencode-mcp.json            ← MCP configuration template
├── skills/                          ← Skills directory
│   ├── develop-flow/                ← Main skill (6-phase lifecycle)
│   │   ├── skill.md                 ← Workflow skeleton + initialization
│   │   ├── gate.md                  ← Gate mechanism + pass criteria
│   │   ├── phases/                  ← Phase instructions (loaded on demand)
│   │   │   ├── phase-1-brief.md     ← Requirements analysis
│   │   │   ├── phase-2-brief.md     ← Task planning
│   │   │   ├── phase-3-brief.md     ← TDD development
│   │   │   ├── phase-4-brief.md     ← Code review
│   │   │   ├── phase-5-brief.md     ← Test verification
│   │   │   └── phase-6-brief.md     ← Wrap-up
│   │   ├── team-rules.md            ← Team communication rules
│   │   ├── resume.md                ← Checkpoint recovery logic
│   │   └── project-config.example.md ← Configuration template
│   ├── init-flow/                   ← Project initialization skill
│   ├── create-team/                 ← Team creation
│   └── delete-team/                 ← Team cleanup
└── agents/                          ← Agent definitions
    ├── requirements-analyst.md
    ├── architect.md
    ├── planner.md
    ├── backend-developer.md
    ├── code-reviewer.md
    └── tester.md
```

## Exception Handling

| Exception | Auto-fix Limit | Escalation |
|-----------|---------------|------------|
| Build failure | 2 retries | Ask user |
| Test bug fix | 3 cycles | Ask user |
| Requirement/Design issue | 2 re-Gates | Ask whether to terminate |
| Agent no response | 1 resend | Ask user |
| Agent context exhausted | 1 replacement | Ask user |

All exceptions escalate to user when limits exceeded. No infinite retries.

## Core Principles

- **Leader never executes** — Only coordinates, decides, and routes
- **Hub-and-Spoke communication** — All Agent messages go through Leader
- **Gate checkpoints** — User confirmation at end of each Phase
- **Evidence-based verification** — No claims without evidence
- **Checkpoint recovery** — State saved after each Phase, resume anytime

## FAQ

### MCP Related

**Q: MCP server fails to start?**

A: Check:
1. Node.js and npm are installed (`node -v`, `npm -v`)
2. Network can access npm registry
3. Environment variables are set correctly (`echo %POSTGRES_HOST%`)

**Q: How to disable a specific MCP server?**

A: Set `"enabled": false` in `opencode.json`:
```json
{
  "mcp": {
    "postgresql": {
      "enabled": false
    }
  }
}
```

**Q: How to view MCP connection logs?**

A: Use debug command:
```bash
opencode mcp debug postgresql
```

**Q: How to handle `${}` variables in project config files?**

A: opencode uses `{env:VAR_NAME}` syntax to reference environment variables. Ensure:
1. Environment variable file is correctly created
2. Environment variables are loaded before starting opencode

### Git Related

**Q: What if git pull fails before develop-flow execution?**

A: Check:
1. Git remote repository configuration is correct
2. SSH keys or HTTPS credentials are valid
3. No unresolved merge conflicts

### Configuration Related

**Q: How to switch between different environments (172/178)?**

A: Run the corresponding configuration script:
```bash
# Switch to 172 environment
scripts\setup-mcp.bat D:\project\172-builder.env

# Switch to 178 environment
scripts\setup-mcp.bat D:\project\178-builder.env
```

Environment variables need to be reloaded after switching.

**Q: Where are the configuration files?**

A: Key configuration file locations:
- OpenCode global config: `~/.config/opencode/opencode.json`
- Environment variables: `~/.config/opencode/env.bat` (Windows)
- Project config: `{project}/.develop-flow/project-config.md`
- Flow config: `~/.agents/skills/develop-flow/project-config.md`
- MCP configuration guide: `docs/mcp-setup.md`

## License

[MIT](LICENSE)
