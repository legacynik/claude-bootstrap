# Custom Agents Templates

Copy the agents you need to `.claude/agents/` in your project.

## Orchestrated Team (TDD Pipeline)

A coordinated team of 6 agents that enforce a strict TDD pipeline: spec -> test -> implement -> review -> security -> PR.

| File | Role | Responsibility |
|------|------|----------------|
| `orchestrated/team-lead.md` | Orchestrator | Creates task chains, spawns agents, coordinates dependencies. Never writes code |
| `orchestrated/feature.md` | Implementer | Owns one feature end-to-end: spec, tests (RED), implementation (GREEN), validation |
| `orchestrated/quality.md` | TDD Enforcer | Verifies specs, confirms tests fail (RED), confirms tests pass (GREEN), checks coverage |
| `orchestrated/code-review.md` | Reviewer | Multi-engine code review, blocks on Critical/High severity |
| `orchestrated/security.md` | Security Gate | OWASP scan, secrets detection, dependency audit, blocks on Critical/High |
| `orchestrated/merger.md` | PR Creator | Creates feature branches, commits, pushes, creates PRs. Never merges |

### How to use

```bash
# Copy all orchestrated agents
cp ~/.claude-devkit/templates/agents/orchestrated/*.md .claude/agents/

# Spawn the team (in Claude Code)
# The team-lead reads feature specs and creates the full pipeline automatically
```

### Pipeline flow per feature

```
spec -> spec-review -> tests -> tests-fail-verify -> implement -> tests-pass-verify -> validate -> code-review -> security-scan -> branch-pr
```

---

## Universal Agents (any project)

| File | Description |
|------|-------------|
| `universal/code-reviewer.md` | Review: quality, security, patterns |
| `universal/tech-doc-writer.md` | Technical documentation |
| `universal/db-architect.md` | Database design and queries |

## Tech Stack Agents

Copy only the relevant ones for your project:

### Backend
| File | Stack |
|------|-------|
| `backend/python-fastapi.md` | Python + FastAPI |

### Frontend
| File | Stack |
|------|-------|
| `frontend/react-nextjs.md` | React + Next.js |
| `frontend/shadcn-mcp.md` | shadcn/ui component library (optional) |

## Difference: Agents vs Skills

| Aspect | Skills (.claude/skills/) | Agents (.claude/agents/) |
|--------|--------------------------|--------------------------|
| What | Passive rules | Specialized experts |
| When | Always loaded | On demand |
| Purpose | How to write code | What to do / decisions |
| Example | "Use type hints" | "Design the architecture" |
