#!/bin/bash
#
# Full Stack AI Development Setup
# Installs: Claude Bootstrap + BMAD-METHOD + Context7 (+ Archon opzionale)
#
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}           FULL STACK AI DEVELOPMENT SETUP${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "This will configure your project with:"
echo "  1. Claude Bootstrap (skills, TDD, security)"
echo "  2. BMAD-METHOD (21 agents, workflows)"
echo "  3. Context7 (public docs - already active!)"
echo "  4. Archon (optional - private docs, RAG)"
echo ""

# Check if we're in a project directory
if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "pyproject.toml" ]; then
    echo -e "${YELLOW}Warning: Not in a project directory.${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Ask about Archon
echo ""
echo -e "${BLUE}Do you want to setup Archon for private documentation?${NC}"
echo "  - Requires: Supabase account + Docker"
echo "  - Use for: Your own docs, wiki, codebase indexing"
echo "  - Skip if: You only need public library docs (Context7)"
echo ""
read -p "Setup Archon? (y/N) " -n 1 -r
echo
SETUP_ARCHON=false
if [[ $REPLY =~ ^[Yy]$ ]]; then
    SETUP_ARCHON=true
fi

# ─────────────────────────────────────────────────────────────
# PHASE 1: Claude Bootstrap
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━ Phase 1: Claude Bootstrap ━━━${NC}"

if [ -d ~/.claude-bootstrap ]; then
    echo -e "${GREEN}✓${NC} Claude Bootstrap already installed"

    # Update to latest
    echo "  Updating to latest version..."
    cd ~/.claude-bootstrap
    git pull --quiet 2>/dev/null || true
    ./install.sh --quiet 2>/dev/null || ./install.sh
    cd - > /dev/null
else
    echo "Installing Claude Bootstrap..."
    git clone https://github.com/alinaqi/claude-bootstrap.git ~/.claude-bootstrap
    cd ~/.claude-bootstrap && ./install.sh
    cd - > /dev/null
fi

# Create project structure
echo "  Creating project structure..."
mkdir -p .claude/skills
mkdir -p .claude/agents
mkdir -p _project_specs/features
mkdir -p _project_specs/todos
mkdir -p _project_specs/session/archive
mkdir -p docs
mkdir -p scripts

# Copy core skills
echo "  Copying core skills..."
for skill in base security session-management code-review code-deduplication project-tooling code-documentation real-testing; do
    if [ -d ~/.claude/skills/$skill ]; then
        cp -r ~/.claude/skills/$skill .claude/skills/
    fi
done

# Copy preflight script
echo "  Copying preflight script..."
if [ -f ~/.claude-bootstrap/templates/scripts/preflight.sh ]; then
    cp ~/.claude-bootstrap/templates/scripts/preflight.sh scripts/
    chmod +x scripts/preflight.sh
fi

echo -e "${GREEN}✓${NC} Claude Bootstrap configured"

# ─────────────────────────────────────────────────────────────
# PHASE 2: BMAD-METHOD
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━ Phase 2: BMAD-METHOD ━━━${NC}"

# Check Node.js
if command -v node &> /dev/null; then
    node_ver=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$node_ver" -ge 20 ]; then
        echo -e "${GREEN}✓${NC} Node.js v$node_ver detected"

        echo "  Installing BMAD-METHOD..."
        npx bmad-method@alpha install 2>/dev/null || {
            echo -e "${YELLOW}⚠${NC} BMAD install had warnings (may still work)"
        }

        echo -e "${GREEN}✓${NC} BMAD-METHOD installed"
    else
        echo -e "${YELLOW}⚠${NC} Node.js 20+ required (current: v$node_ver)"
        echo "  To upgrade: nvm install 20 && nvm use 20"
        echo "  Skipping BMAD-METHOD..."
    fi
else
    echo -e "${YELLOW}⚠${NC} Node.js not found"
    echo "  Install from: https://nodejs.org/"
    echo "  Skipping BMAD-METHOD..."
fi

# Create BMAD agents reference
cat > .claude/agents/bmad-agents.md << 'BMAD_EOF'
# BMAD-METHOD Agents Reference

This project uses BMAD-METHOD for structured workflows.

## Quick Start

```bash
*workflow-init    # Start guided workflow selection
```

## Available Agents

| Agent | Command | Purpose |
|-------|---------|---------|
| Project Manager | `*pm` | Requirements, priorities, scope |
| Architect | `*architect` | System design, tech decisions |
| Developer | `*dev` | Implementation, coding |
| UX Specialist | `*ux` | User experience, interfaces |
| QA Engineer | `*qa` | Testing, quality assurance |
| Scrum Master | `*scrum` | Sprint planning, blockers |
| Security Expert | `*security` | Security review, threats |
| DevOps | `*devops` | CI/CD, infrastructure |
| Data Engineer | `*data` | Database, data pipelines |
| Documentation | `*doc` | Technical writing |

## Workflows

| Type | Command | Duration | Use For |
|------|---------|----------|---------|
| Quick | `*workflow-quick` | ~5 min | Bug fixes, hotfixes |
| Standard | `*workflow-standard` | ~15 min | Features, refactoring |
| Enterprise | `*workflow-enterprise` | ~30 min | Large features, compliance |

## Example Usage

### Starting a new feature:
```
*pm "Define requirements for user authentication"
*architect "Design auth system with JWT"
*dev "Implement login endpoint"
*qa "Create test plan for auth"
```

### Bug fix workflow:
```
*workflow-quick
# Follow guided steps
```

## Integration Notes

BMAD agents automatically follow Claude Bootstrap skills:
- TDD-first (write tests before code)
- Security patterns (no hardcoded secrets)
- Code review before commit
BMAD_EOF

echo -e "${GREEN}✓${NC} BMAD agents reference created"

# ─────────────────────────────────────────────────────────────
# PHASE 3: Context7 (already active!)
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━ Phase 3: Context7 (Public Docs) ━━━${NC}"

# Create Context7 usage guide
cat > .claude/agents/context7-guide.md << 'CTX7_EOF'
# Context7 - Public Documentation

Context7 is already active as an MCP server. Use it to query documentation for any public library.

## How to Use

Simply ask Claude to query Context7:

```
"Query Context7 for React hooks documentation"
"Search Context7 for FastAPI dependency injection"
"Find in Context7: Pydantic v2 model validators"
"Get from Context7: Next.js App Router patterns"
```

## Supported Libraries

Context7 has documentation for thousands of libraries including:

| Category | Examples |
|----------|----------|
| Frontend | React, Vue, Angular, Svelte, Next.js, Nuxt |
| Backend | FastAPI, Django, Express, NestJS, Flask |
| Database | PostgreSQL, MongoDB, Prisma, SQLAlchemy |
| Testing | Jest, Pytest, Playwright, Cypress |
| Mobile | React Native, Flutter, Expo |
| AI/ML | LangChain, OpenAI, Anthropic SDK |

## Tips

### Be Specific
```
❌ "How do I use React?"
✅ "Query Context7 for React useEffect cleanup patterns"
```

### Specify Version (if needed)
```
"Query Context7 for Next.js 14 App Router server actions"
"Search Context7 for Pydantic v2 (not v1) validators"
```

## Context7 vs Archon

| Need | Use |
|------|-----|
| React/FastAPI/library docs | Context7 |
| YOUR project's private docs | Archon |
| Public API references | Context7 |
| Internal wiki/knowledge | Archon |

Context7 is FREE and requires NO setup!
CTX7_EOF

echo -e "${GREEN}✓${NC} Context7 already active (MCP server)"
echo "  Usage: \"Query Context7 for [library] documentation\""

# ─────────────────────────────────────────────────────────────
# PHASE 3b: Detect existing MCP servers (shadcn, etc.)
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━ Phase 3b: Detecting MCP Servers ━━━${NC}"

# Check for shadcn MCP
if [ -f ".claude/settings.json" ] && grep -q "shadcn" .claude/settings.json 2>/dev/null; then
    echo -e "${GREEN}✓${NC} shadcn/ui MCP detected"

    # Copy shadcn guide
    if [ -f ~/.claude-bootstrap/templates/agents/frontend/shadcn-mcp.md ]; then
        cp ~/.claude-bootstrap/templates/agents/frontend/shadcn-mcp.md .claude/agents/
        echo "  Guide copied to .claude/agents/shadcn-mcp.md"
    fi

    SHADCN_DETECTED=true
else
    SHADCN_DETECTED=false
    echo -e "${YELLOW}○${NC} shadcn/ui MCP not configured"
    echo "  To add: npx shadcn@latest init, then add MCP to .claude/settings.json"
fi

# ─────────────────────────────────────────────────────────────
# PHASE 4: Archon (OPTIONAL)
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━ Phase 4: Archon (Optional - Private Docs) ━━━${NC}"

if [ "$SETUP_ARCHON" = true ]; then
    archon_running=false
    if curl -s http://localhost:8051/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Archon is running"
        archon_running=true
    else
        echo -e "${YELLOW}⚠${NC} Archon not detected on localhost:8051"

        if [ -d ~/archon ]; then
            echo "  Archon found at ~/archon"
            echo "  Start with: cd ~/archon && docker compose up -d"
        else
            echo ""
            echo "  To install Archon:"
            echo "    git clone -b stable https://github.com/coleam00/archon.git ~/archon"
            echo "    cd ~/archon && cp .env.example .env"
            echo "    # Edit .env with your Supabase credentials"
            echo "    docker compose up --build -d"
        fi
    fi

    # Create Archon integration guide
    cat > .claude/agents/archon-integration.md << 'ARCHON_EOF'
# Archon Knowledge Base Integration

## Status

Check if Archon is running:
```bash
curl http://localhost:8051/health
```

## Dashboard

Access: http://localhost:3737

## How to Use with Claude Code

### Querying Your Private Documentation

```
"Search Archon for our authentication implementation"
"Query Archon for internal API documentation"
"Find in Archon: our database schema"
```

### Adding Knowledge

1. **Web Crawl**: Dashboard → Sources → Add URL
2. **PDF Upload**: Dashboard → Documents → Upload
3. **Code Index**: Dashboard → Repositories → Add repo

## When to Use Archon vs Context7

| Need | Tool |
|------|------|
| React/FastAPI docs | Context7 |
| YOUR project docs | Archon |
| Public libraries | Context7 |
| Internal wiki | Archon |
| API references | Context7 |
| Team knowledge | Archon |

## Setup MCP Connection

Add to `.claude/settings.json`:
```json
{
  "mcpServers": {
    "archon": {
      "type": "http",
      "url": "http://localhost:8051",
      "headers": {
        "Authorization": "Bearer YOUR_API_KEY"
      }
    }
  }
}
```

Get API key from: http://localhost:3737 → Settings → API Keys
ARCHON_EOF

    echo -e "${GREEN}✓${NC} Archon integration guide created"

    # Create MCP settings template if Archon is running
    if [ "$archon_running" = true ]; then
        mkdir -p .claude
        if [ ! -f .claude/settings.json ]; then
            cat > .claude/settings.json << 'SETTINGS_EOF'
{
  "mcpServers": {
    "archon": {
      "type": "http",
      "url": "http://localhost:8051",
      "headers": {
        "Authorization": "Bearer YOUR_ARCHON_API_KEY"
      }
    }
  }
}
SETTINGS_EOF
            echo -e "${GREEN}✓${NC} MCP settings template created"
            echo -e "${YELLOW}  → Edit .claude/settings.json with your Archon API key${NC}"
        fi
    fi
else
    echo -e "${YELLOW}○${NC} Archon skipped (using Context7 for docs)"
    echo "  To add Archon later: re-run this script and select 'y'"
fi

# ─────────────────────────────────────────────────────────────
# PHASE 5: Create Integrated CLAUDE.md
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━ Phase 5: Creating CLAUDE.md ━━━${NC}"

# Detect tech stack
lang="[language]"
framework="[framework]"

if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    lang="Python"
    if grep -q "fastapi" pyproject.toml 2>/dev/null || grep -q "fastapi" requirements.txt 2>/dev/null; then
        framework="FastAPI"
    elif grep -q "django" pyproject.toml 2>/dev/null || grep -q "django" requirements.txt 2>/dev/null; then
        framework="Django"
    fi
fi

if [ -f "package.json" ]; then
    if [ "$lang" = "[language]" ]; then
        lang="TypeScript"
    else
        lang="Python + TypeScript"
    fi
    if grep -q "next" package.json 2>/dev/null; then
        framework="Next.js"
    elif grep -q "react" package.json 2>/dev/null; then
        framework="React"
    elif grep -q "express" package.json 2>/dev/null; then
        framework="Express"
    fi
fi

# Build CLAUDE.md content
archon_section=""
if [ "$SETUP_ARCHON" = true ]; then
    archon_section="
- **Docs private**: Query Archon. Dettagli: \`.claude/agents/archon-integration.md\`"
fi

shadcn_section=""
if [ "$SHADCN_DETECTED" = true ]; then
    shadcn_section="
- **UI Components**: USA shadcn MCP (MAI creare custom). Dettagli: \`.claude/agents/shadcn-mcp.md\`"
fi

cat > CLAUDE.md << CLAUDE_EOF
# CLAUDE.md

## Project
- **Language:** $lang
- **Framework:** $framework

## Rules

### Codice
- **Commenta tutto**: header file + docstrings + inline per logica non ovvia
- **Unit test ≠ verifica**: TESTA MANUALMENTE (avvia app, curl, verifica DB)
- **Logging obbligatorio**: ogni feature deve loggare
- **Preflight prima di commit**: \`./scripts/preflight.sh\`

### MCP Tools
- **Brainstorming/Analisi**: USA SEMPRE \`mcp__sequential-thinking__sequentialthinking\`
- **Docs librerie**: Query Context7
$shadcn_section
$archon_section

### Skills (leggi prima di scrivere codice)
- \`.claude/skills/base/SKILL.md\`
- \`.claude/skills/security/SKILL.md\`
- \`.claude/skills/real-testing/SKILL.md\`

### Workflow
- \`*workflow-init\` per iniziare
- \`/code-review\` prima di commit
- Agents BMAD: \`.claude/agents/bmad-agents.md\`

### Session
- Stato: \`_project_specs/session/current-state.md\`
- Todos: \`_project_specs/todos/active.md\`
CLAUDE_EOF

echo -e "${GREEN}✓${NC} CLAUDE.md created"

# ─────────────────────────────────────────────────────────────
# PHASE 6: Create session files
# ─────────────────────────────────────────────────────────────

if [ ! -f "_project_specs/session/current-state.md" ]; then
    cat > _project_specs/session/current-state.md << 'STATE_EOF'
# Current Session State

*Last updated: [timestamp]*

## Active Task
[What are we working on right now]

## Current Status
- **Phase**: exploring | planning | implementing | testing
- **Progress**: [X of Y steps]
- **Blockers**: None

## Context Summary
[2-3 sentences about current state]

## Next Steps
1. [ ] First action
2. [ ] Second action

## Resume Instructions
To continue this work:
1. Read this file
2. Check _project_specs/todos/active.md
3. Continue from Next Steps
STATE_EOF
fi

if [ ! -f "_project_specs/todos/active.md" ]; then
    cat > _project_specs/todos/active.md << 'TODO_EOF'
# Active Todos

Current work in progress.

---

<!-- Add todos here following atomic todo format -->
TODO_EOF
fi

# ─────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}                    SETUP COMPLETE!${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Installed:"
echo -e "  ${GREEN}✓${NC} Claude Bootstrap - Skills in .claude/skills/"
echo -e "  ${GREEN}✓${NC} BMAD-METHOD - Agents in .claude/agents/"
echo -e "  ${GREEN}✓${NC} Context7 - Public docs (already active)"
if [ "$SHADCN_DETECTED" = true ]; then
    echo -e "  ${GREEN}✓${NC} shadcn/ui MCP - Component management"
fi
if [ "$SETUP_ARCHON" = true ]; then
    echo -e "  ${GREEN}✓${NC} Archon - Private docs guide created"
else
    echo -e "  ${YELLOW}○${NC} Archon - Skipped (add later if needed)"
fi
echo ""
echo "Created files:"
echo "  - CLAUDE.md (main instructions)"
echo "  - .claude/skills/ (coding rules)"
echo "  - .claude/agents/ (BMAD + Context7 guides)"
echo "  - _project_specs/ (todos, session state)"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. Run: claude"
echo "  2. Start workflow: *workflow-init"
echo "  3. Or ask: \"Help me build [feature]\""
echo ""
echo -e "${BOLD}Query docs with:${NC}"
echo "  - \"Query Context7 for [library] docs\"  (public)"
if [ "$SETUP_ARCHON" = true ]; then
    echo "  - \"Search Archon for [topic]\"          (private)"
fi
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
