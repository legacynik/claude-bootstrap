# Setup Full Stack AI Development

Configura il progetto con tutti gli strumenti AI: **Claude Bootstrap + BMAD-METHOD + Archon**.

Funziona per progetti **nuovi** e **esistenti**.

---

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    FULL STACK AI DEV                         │
├─────────────────────────────────────────────────────────────┤
│  1. CLAUDE BOOTSTRAP → Skills, TDD, Security patterns       │
│  2. BMAD-METHOD      → 21 Agents, Structured workflows      │
│  3. ARCHON           → Knowledge base, RAG, Task management │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 0: Detect Project State

```bash
# Check what already exists
ls -la .claude/skills/ 2>/dev/null
ls -la CLAUDE.md 2>/dev/null
ls -la .bmad/ 2>/dev/null
ls -la package.json pyproject.toml 2>/dev/null

# Check for existing integrations
grep -l "bmad" CLAUDE.md 2>/dev/null
grep -l "archon" .claude/settings.json 2>/dev/null
```

Inform user:
- "New project - will do full setup"
- "Existing project - will add missing integrations"
- "Already configured - will update to latest versions"

---

## Phase 1: User Questions

Ask these questions (skip if already configured):

### 1. Which integrations do you want?

```
[ ] Claude Bootstrap (skills, TDD, security) - RECOMMENDED
[ ] BMAD-METHOD (21 agents, structured workflows)
[ ] Archon (knowledge base, RAG, documentation)
[ ] ALL THREE (full AI-native development) - RECOMMENDED FOR LARGE PROJECTS
```

### 2. Project basics (if not detected)

- What language? (Python/TypeScript/Both)
- What type? (Backend/Frontend/Full Stack/Mobile)
- What framework? (FastAPI/Next.js/React Native/etc.)

### 3. Archon configuration (if selected)

- Is Archon already running? (Check: `curl http://localhost:8051/health`)
- Archon API key? (Get from dashboard at http://localhost:3737)

---

## Phase 2: Install Claude Bootstrap

**Always run first - this is the foundation.**

```bash
# Validate bootstrap installation
~/.claude-bootstrap/tests/validate-structure.sh --quick

# If not installed
if [ ! -d ~/.claude-bootstrap ]; then
    git clone https://github.com/alinaqi/claude-bootstrap.git ~/.claude-bootstrap
    cd ~/.claude-bootstrap && ./install.sh
fi
```

### Create project structure

```bash
mkdir -p .claude/skills
mkdir -p .claude/agents
mkdir -p _project_specs/features
mkdir -p _project_specs/todos
mkdir -p _project_specs/session/archive
mkdir -p docs
mkdir -p scripts
```

### Copy skills based on tech stack

```bash
# Always copy core skills
cp -r ~/.claude/skills/base/ .claude/skills/
cp -r ~/.claude/skills/security/ .claude/skills/
cp -r ~/.claude/skills/session-management/ .claude/skills/
cp -r ~/.claude/skills/code-review/ .claude/skills/
cp -r ~/.claude/skills/code-deduplication/ .claude/skills/

# Language-specific (based on answers)
# Python → cp -r ~/.claude/skills/python/ .claude/skills/
# TypeScript → cp -r ~/.claude/skills/typescript/ .claude/skills/
# etc.
```

---

## Phase 3: Install BMAD-METHOD (if selected)

### Check Node.js version

```bash
node_version=$(node -v 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$node_version" -lt 20 ]; then
    echo "BMAD requires Node.js 20+. Current: $(node -v)"
    echo "Install with: nvm install 20 && nvm use 20"
    exit 1
fi
```

### Install BMAD

```bash
npx bmad-method@alpha install
```

### Create BMAD agents reference in .claude/agents/

Create `.claude/agents/bmad-agents.md`:

```markdown
# BMAD-METHOD Agents Reference

This project uses BMAD-METHOD for structured workflows.

## Available Agents (invoke with *agent-name)

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| *pm | Project Manager | Define requirements, prioritize |
| *architect | System Architect | Design systems, make tech decisions |
| *dev | Developer | Implement features, write code |
| *ux | UX Specialist | Design interfaces, user flows |
| *qa | QA Engineer | Test planning, quality assurance |
| *scrum | Scrum Master | Sprint planning, blockers |
| *security | Security Expert | Security review, threat modeling |
| *devops | DevOps Engineer | CI/CD, deployment, infrastructure |
| *data | Data Engineer | Database design, data pipelines |
| *doc | Documentation | Technical writing, API docs |

## Workflows

| Workflow | Time | Use For |
|----------|------|---------|
| *workflow-quick | ~5 min | Bug fixes, small features |
| *workflow-standard | ~15 min | New features, refactoring |
| *workflow-enterprise | ~30 min | Large features, compliance |

## Usage

```bash
# Start any workflow
*workflow-init

# Call specific agent
*architect "Design the authentication system"

# Chain agents
*pm → *architect → *dev
```

## Integration with Claude Bootstrap

BMAD agents follow Claude Bootstrap skills automatically:
- TDD-first development (base.md)
- Security patterns (security.md)
- Code review before commit (code-review.md)
```

---

## Phase 4: Configure Archon (if selected)

### Check Archon is running

```bash
archon_health=$(curl -s http://localhost:8051/health 2>/dev/null)
if [ -z "$archon_health" ]; then
    echo "Archon not running. Start with:"
    echo "  cd ~/archon && docker compose up -d"
    echo ""
    echo "Or install Archon:"
    echo "  git clone -b stable https://github.com/coleam00/archon.git ~/archon"
    echo "  cd ~/archon && cp .env.example .env"
    echo "  # Configure .env with Supabase credentials"
    echo "  docker compose up --build -d"
    exit 1
fi
```

### Get Archon API key

Ask user for API key from Archon dashboard (http://localhost:3737).

### Create MCP configuration

Create/update `.claude/settings.json`:

```json
{
  "mcpServers": {
    "archon": {
      "type": "http",
      "url": "http://localhost:8051",
      "headers": {
        "Authorization": "Bearer ${ARCHON_API_KEY}"
      }
    }
  }
}
```

### Create Archon integration guide

Create `.claude/agents/archon-integration.md`:

```markdown
# Archon Knowledge Base Integration

This project uses Archon for documentation and RAG.

## Dashboard

Access: http://localhost:3737

## MCP Tools Available

| Tool | Purpose | Example |
|------|---------|---------|
| `archon_search` | Semantic search docs | "How does auth work?" |
| `archon_get_tasks` | List project tasks | Get current sprint |
| `archon_create_task` | Add new task | Create feature ticket |
| `archon_query_docs` | RAG query | "JWT best practices" |

## Adding Documentation

1. **Web Crawl**: Dashboard → Sources → Add URL
2. **PDF Upload**: Dashboard → Documents → Upload
3. **Manual**: Dashboard → Documents → Create

## Best Practices

### Before coding, query Archon:
```
"Search Archon for existing patterns for [feature]"
"Query Archon docs for [library] usage examples"
```

### After completing features:
```
"Add this implementation to Archon knowledge base"
"Update Archon docs with new API endpoint"
```

## Reducing Context Usage

Instead of pasting long docs into chat:
```
❌ "Here's the full API documentation... [10000 lines]"
✅ "Query Archon for authentication API reference"
```

Archon returns only relevant chunks (~20-50 lines).
```

---

## Phase 5: Create Integrated CLAUDE.md

Create/update `CLAUDE.md` with all integrations:

```markdown
# CLAUDE.md

## Quick Reference

| Need | Tool | Command |
|------|------|---------|
| Coding rules | Bootstrap Skills | Read .claude/skills/ |
| Workflow/planning | BMAD Agents | *workflow-init |
| Documentation/RAG | Archon | Query via MCP |

---

## Skills (Claude Bootstrap)

Read and follow these skills before writing any code:

### Core (always apply)
- .claude/skills/base/SKILL.md - TDD, simplicity, patterns
- .claude/skills/security/SKILL.md - Security requirements
- .claude/skills/code-review/SKILL.md - Review before commit
- .claude/skills/session-management/SKILL.md - Context preservation

### Language-specific
- .claude/skills/[language]/SKILL.md

### Framework-specific
- .claude/skills/[framework]/SKILL.md

---

## BMAD-METHOD Agents

This project uses BMAD for structured workflows. See `.claude/agents/bmad-agents.md`.

### Quick Commands
```bash
*workflow-init          # Start guided workflow
*pm                     # Project Manager agent
*architect              # System Architect agent
*dev                    # Developer agent
```

### Workflow Selection
| Scope | Command | Time |
|-------|---------|------|
| Bug fix / small | *workflow-quick | ~5 min |
| Feature | *workflow-standard | ~15 min |
| Large / compliance | *workflow-enterprise | ~30 min |

---

## Archon Knowledge Base

This project uses Archon for documentation and RAG. See `.claude/agents/archon-integration.md`.

### Dashboard
http://localhost:3737

### Query Patterns
```
"Search Archon for [topic]"
"Query Archon docs about [feature]"
"Find examples in Archon for [pattern]"
```

### Adding Knowledge
- Web crawl: Add URLs in dashboard
- Upload: PDFs, markdown, code
- Auto-index: Archon watches configured repos

---

## Project Overview

[Description]

## Tech Stack

- Language: [X]
- Framework: [X]
- Database: [X]
- Deployment: [X]

---

## Development Workflow

### 1. Starting a Feature

```
1. *workflow-init → Choose workflow type
2. *pm → Define requirements
3. *architect → Design solution
4. Query Archon → Find existing patterns
5. *dev → Implement with TDD
```

### 2. During Development

```
- Follow Bootstrap skills (TDD, security)
- Query Archon for docs instead of pasting
- Use BMAD agents for decisions
```

### 3. Before Commit

```
1. /code-review → Check quality
2. *qa → Verify test coverage
3. Update Archon → Add new knowledge
```

---

## Key Commands

```bash
# Bootstrap
./scripts/verify-tooling.sh      # Check CLI tools

# BMAD
*workflow-init                   # Start workflow
*architect "design X"            # Call agent

# Testing
npm test                         # Run tests
npm run lint                     # Lint code

# Deploy
npm run deploy:preview           # Preview deploy
```

---

## Context Management

### To REDUCE context usage:

| Instead of... | Do this... |
|---------------|------------|
| Pasting full docs | Query Archon |
| Explaining requirements | Use *pm agent |
| Designing in chat | Use *architect agent |
| Long todo lists | Use Archon tasks |

### Session State

Keep updated: `_project_specs/session/current-state.md`

---

## Documentation

- `docs/` - Technical documentation
- `_project_specs/` - Project specs and todos
- Archon Dashboard - Indexed knowledge base
```

---

## Phase 6: Create Helper Scripts

### scripts/setup-integrations.sh

```bash
#!/bin/bash
set -e

echo "🚀 Setting up Full Stack AI Development..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Claude Bootstrap
echo "📦 Checking Claude Bootstrap..."
if [ -d ~/.claude-bootstrap ]; then
    echo -e "${GREEN}✓ Claude Bootstrap installed${NC}"
else
    echo -e "${YELLOW}Installing Claude Bootstrap...${NC}"
    git clone https://github.com/alinaqi/claude-bootstrap.git ~/.claude-bootstrap
    cd ~/.claude-bootstrap && ./install.sh
fi

# 2. BMAD-METHOD
echo ""
echo "📦 Checking BMAD-METHOD..."
if command -v npx &> /dev/null; then
    node_ver=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$node_ver" -ge 20 ]; then
        echo -e "${GREEN}✓ Node.js $node_ver ready${NC}"
        echo "Installing BMAD-METHOD..."
        npx bmad-method@alpha install
        echo -e "${GREEN}✓ BMAD-METHOD installed${NC}"
    else
        echo -e "${YELLOW}⚠ Node.js 20+ required (current: $node_ver)${NC}"
        echo "  Run: nvm install 20 && nvm use 20"
    fi
else
    echo -e "${YELLOW}⚠ Node.js not found${NC}"
fi

# 3. Archon
echo ""
echo "📦 Checking Archon..."
if curl -s http://localhost:8051/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Archon running${NC}"
else
    echo -e "${YELLOW}⚠ Archon not running${NC}"
    echo "  To install:"
    echo "    git clone -b stable https://github.com/coleam00/archon.git ~/archon"
    echo "    cd ~/archon && docker compose up -d"
fi

echo ""
echo "═══════════════════════════════════════════"
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Run: claude"
echo "  2. Run: /initialize-project"
echo "  3. Start: *workflow-init"
echo "═══════════════════════════════════════════"
```

---

## Phase 7: Summary

Show what was configured:

```
═══════════════════════════════════════════════════════════════
                    FULL STACK AI DEV READY
═══════════════════════════════════════════════════════════════

✓ Claude Bootstrap
  - Skills: 44 loaded in .claude/skills/
  - Commands: /initialize-project, /code-review
  - TDD + Security + Patterns enforced

✓ BMAD-METHOD
  - Agents: 21 available (*pm, *architect, *dev, etc.)
  - Workflows: quick, standard, enterprise
  - Run: *workflow-init to start

✓ Archon
  - Dashboard: http://localhost:3737
  - MCP: Connected on port 8051
  - Query: "Search Archon for [topic]"

═══════════════════════════════════════════════════════════════

HOW THEY WORK TOGETHER:

  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
  │   ARCHON    │     │    BMAD     │     │  BOOTSTRAP  │
  │  (Memory)   │     │  (Agents)   │     │  (Rules)    │
  └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
         │                   │                   │
         └───────────────────┼───────────────────┘
                             ▼
                    ┌─────────────────┐
                    │   CLAUDE CODE   │
                    │                 │
                    │  Low context    │
                    │  High capability│
                    └─────────────────┘

WORKFLOW:
  1. *workflow-init → BMAD guides planning
  2. Query Archon → Get relevant docs only
  3. Code with Bootstrap skills → TDD, security
  4. /code-review → Before commit

═══════════════════════════════════════════════════════════════
```

---

## Troubleshooting

### BMAD not working
```bash
# Check Node version
node -v  # Must be 20+

# Reinstall
npx bmad-method@alpha install --force
```

### Archon not connecting
```bash
# Check if running
curl http://localhost:8051/health

# Restart
cd ~/archon && docker compose restart

# Check logs
docker compose logs -f
```

### Skills not loading
```bash
# Validate installation
~/.claude-bootstrap/tests/validate-structure.sh --full

# Reinstall
cd ~/.claude-bootstrap && git pull && ./install.sh
```
