#!/bin/bash
# ============================================================================
# Claude Development System - Project Initializer
# ============================================================================
#
# Initializes a complete Claude Code development environment with:
# - Session management skills (start, end, update, weekly-report)
# - n8n debug workflow skills (debug, test-fix, archivia, cleanup-debug, sync-n8n)
# - n8n dev workflow manager script
# - Git push verification script
# - CLAUDE.md + PROJECT.md templates
# - Documentation reference files
# - Session state tracking (_project_specs/)
#
# Usage:
#   cd your-project && ~/.claude-bootstrap/scripts/setup-full-stack.sh
#   ~/.claude-bootstrap/scripts/setup-full-stack.sh /path/to/project
#
# Requirements: git, jq (for n8n features)
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Header
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Claude Development System - Project Init        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# Step 1: Collect project info
# ============================================================================

PROJECT_DIR="${1:-$(pwd)}"

# Expand ~ if used
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Directory $PROJECT_DIR does not exist. Create it? (y/N)${NC}"
    read -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$PROJECT_DIR"
    else
        echo "Aborted."
        exit 1
    fi
fi

PROJECT_NAME=$(basename "$PROJECT_DIR")

echo -e "${BLUE}Project: ${NC}$PROJECT_NAME"
echo -e "${BLUE}Path:    ${NC}$PROJECT_DIR"
echo ""

# Git email
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
if [ -z "$GIT_EMAIL" ]; then
    read -p "Git email: " GIT_EMAIL
fi
echo -e "${BLUE}Git email: ${NC}$GIT_EMAIL"

# n8n config (optional)
echo ""
echo -e "${YELLOW}n8n Integration (press Enter to skip)${NC}"
read -p "n8n instance URL (e.g., https://n8n.example.com): " N8N_URL
read -p "n8n workflow tag for sync (e.g., MyProject): " N8N_TAG

ENABLE_N8N=false
if [ -n "$N8N_URL" ]; then
    ENABLE_N8N=true
    echo -e "${GREEN}n8n enabled:${NC} $N8N_URL (tag: ${N8N_TAG:-$PROJECT_NAME})"
fi

# Default tag to project name if not specified
N8N_TAG="${N8N_TAG:-$PROJECT_NAME}"

# GitHub repo (optional)
echo ""
read -p "GitHub repo (e.g., user/repo, or Enter to skip): " GITHUB_REPO

# Database MCP name (optional)
echo ""
read -p "Database MCP server name (e.g., my-supa, or Enter to skip): " DB_MCP_NAME

echo ""
echo -e "${CYAN}Configuration:${NC}"
echo "  Project:    $PROJECT_NAME"
echo "  Path:       $PROJECT_DIR"
echo "  Git email:  $GIT_EMAIL"
echo "  n8n:        $([ "$ENABLE_N8N" = true ] && echo "$N8N_URL (tag: $N8N_TAG)" || echo "disabled")"
echo "  GitHub:     ${GITHUB_REPO:-not set}"
echo "  DB MCP:     ${DB_MCP_NAME:-not set}"
echo ""
read -p "Proceed? (Y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Aborted."
    exit 0
fi

# ============================================================================
# Step 2: Create directory structure
# ============================================================================

echo ""
echo -e "${CYAN}Creating directory structure...${NC}"

mkdir -p "$PROJECT_DIR/.claude/skills/start"
mkdir -p "$PROJECT_DIR/.claude/skills/end"
mkdir -p "$PROJECT_DIR/.claude/skills/update"
mkdir -p "$PROJECT_DIR/.claude/skills/weekly-report"
mkdir -p "$PROJECT_DIR/_project_specs/session/daily"
mkdir -p "$PROJECT_DIR/_project_specs/session/weekly"
mkdir -p "$PROJECT_DIR/_project_specs/audit"
mkdir -p "$PROJECT_DIR/_project_specs/specs"
mkdir -p "$PROJECT_DIR/docs/runbooks"
mkdir -p "$PROJECT_DIR/scripts"

if [ "$ENABLE_N8N" = true ]; then
    mkdir -p "$PROJECT_DIR/.claude/skills/debug"
    mkdir -p "$PROJECT_DIR/.claude/skills/test-fix"
    mkdir -p "$PROJECT_DIR/.claude/skills/archivia"
    mkdir -p "$PROJECT_DIR/.claude/skills/cleanup-debug"
    mkdir -p "$PROJECT_DIR/.claude/skills/sync-n8n"
    mkdir -p "$PROJECT_DIR/_project_specs/debug/archive"
    mkdir -p "$PROJECT_DIR/workflows/backups"
fi

echo -e "${GREEN}  Directories created${NC}"

# ============================================================================
# Step 3: Initialize git
# ============================================================================

if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo -e "${CYAN}Initializing git...${NC}"
    cd "$PROJECT_DIR" && git init && cd - > /dev/null
    echo -e "${GREEN}  Git initialized${NC}"
fi

# ============================================================================
# Step 4: Create .env template
# ============================================================================

if [ ! -f "$PROJECT_DIR/.env" ]; then
    cat > "$PROJECT_DIR/.env" << 'ENVEOF'
# Project Environment Variables
# Copy to .env.local for local overrides

ENVEOF

    if [ "$ENABLE_N8N" = true ]; then
        cat >> "$PROJECT_DIR/.env" << 'ENVEOF'
# n8n API
N8N_API_KEY=your_api_key_here
ENVEOF
    fi
    echo -e "${GREEN}  .env template created${NC}"
fi

# ============================================================================
# Step 5: Create .gitignore
# ============================================================================

if [ ! -f "$PROJECT_DIR/.gitignore" ]; then
    cat > "$PROJECT_DIR/.gitignore" << 'GIEOF'
# Environment
.env
.env.local
.env.*.local

# Dependencies
node_modules/
__pycache__/
.venv/
venv/

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Build
dist/
build/
.next/
out/

# Logs
*.log
npm-debug.log*

# Temporary
tmp/
temp/
GIEOF
    echo -e "${GREEN}  .gitignore created${NC}"
fi

# ============================================================================
# Step 6: Create session management skills
# ============================================================================

echo -e "${CYAN}Creating session management skills...${NC}"

# --- /start skill ---
cat > "$PROJECT_DIR/.claude/skills/start/SKILL.md" << 'STARTEOF'
---
name: start
description: Session briefing with task recommendations - reads current state, sprint status, and suggests workflows/skills for each task
---

# Start Session - Intelligent Briefing

**Purpose:** Start new session or panel with automatic context recovery and workflow recommendations.

---

## Behavior

1. **Read session context** (in order):
   - `_project_specs/session/current-state.md` (active task, next steps)
   - `_project_specs/sprint-status.yaml` (sprint tasks, priorities)
   - `_project_specs/session/daily/YYYY-MM-DD.md` (latest session log)

2. **Analyze tasks:**
   - Extract pending/in_progress tasks from sprint-status
   - Detect task type, scope, complexity
   - Apply decision matrix (auto-match workflow/skills)

3. **Output briefing:**
   - Active sprint summary
   - Task list with workflow/skill recommendations
   - Rationale for each recommendation
   - Next steps (actionable)

---

## Decision Matrix: Auto-detect Workflow

| Task Pattern | Detected When | Primary Workflow | Skills | Rationale |
|--------------|---------------|------------------|--------|-----------|
| **n8n workflow bug** | Contains: `execution_id`, `workflow error`, `debug` | `/debug <exec_id>` | Auto-select n8n skill based on error type | Debug workflow isolates error context |
| **n8n feature add** | Contains: workflow name, `new functionality`, `add tool` | `dev-workflow.sh create` + `bmad-bmm-quick-dev` | `n8n-mcp-skills:n8n-node-configuration` | Safe [DEV] workflow testing |
| **New feature (with story)** | Contains: `implement`, `story file`, structured requirements | `bmad-bmm-dev-story` | `superpowers:test-driven-development` | Story-driven implementation |
| **Quick fix/update** | Contains: `fix`, `update`, `small change`, no story | `bmad-bmm-quick-dev` | `superpowers:systematic-debugging` (if bug) | Flexible ad-hoc development |
| **UI component** | Contains: `component`, `UI`, `frontend`, `design` | `/interface-design:init` | `interface-design`, `ui-web` | Intent-first design, then build |
| **Database change** | Contains: `table`, `migration`, `SQL`, `schema` | Write SQL + test with DB MCP | - | Multi-tenancy critical |
| **Architecture decision** | Contains: `design`, `architecture`, `approach`, `decision` | `bmad-bmm-create-architecture` or `bmad-party-mode` | - | Complex decisions need design doc |
| **Code review** | Contains: `review`, `before commit`, `pre-merge` | `bmad-bmm-code-review` (adversarial) | `superpowers:verification-before-completion` | Rigor before production |
| **Integration task** | Contains: `integrate`, `connect`, `add to workflow` | `bmad-bmm-quick-spec` → `bmad-bmm-quick-dev` | `superpowers:test-driven-development` | Spec first, then implement |
| **Research/investigation** | Contains: `research`, `investigate`, `understand`, `analyze` | `bmad-bmm-research` or explore manually | `context7` MCP (for lib docs) | Gather data before deciding |
| **Prompt optimization** | Contains: `prompt`, `optimize`, `improve output` | `bmad-bmm-quick-spec` → iterate | `llm-patterns` | Spec first, iterate with testing |
| **Dashboard/analytics** | Contains: `dashboard`, `analytics`, `chart`, `metrics` | `/interface-design:init` → `bmad-bmm-quick-dev` | `interface-design`, `ui-web`, `posthog-analytics` | Intent-first, then implement |

---

## Output Template

```markdown
# Session Briefing - {DATE}

## Active Sprint: {SPRINT_NAME}
**Status:** {status} | **Phase:** {phase} | **Priority:** {priority_count} tasks

---

## High Priority ({N} tasks)

### Task {ID}: {TITLE}
**Priority:** {priority} | **Effort:** {effort} | **Status:** {status}

**Detected Pattern:** {pattern_matched}

**Recommended Workflow:**
> {primary_workflow}

**Recommended Skills:**
> {skill_1}
> {skill_2}

**Rationale:**
{why_this_workflow_and_skills}

**Next Steps:**
1. {actionable_step_1}
2. {actionable_step_2}
3. {actionable_step_3}

---

## Resume Instructions
**Last session:** {last_session_date} - {last_session_summary}

**Current context:** {active_task_from_current_state}

**Recommendation:** Start with {task_id} - {brief_rationale}
```

---

## Priority Rules

**Task priority detection:**
1. **HIGH:** Sprint task with `priority: high` OR in CRITICAL section
2. **HIGH:** Task with `status: in_progress` (resume active work)
3. **HIGH:** Task blocking other tasks (dependency detection)
4. **MEDIUM:** Sprint task with `priority: medium`
5. **LOW:** Everything else

**Recommendation order:**
1. Resume `in_progress` tasks first (context already loaded)
2. Then HIGH priority by effort (shortest first for quick wins)
3. Then blockers (unblock others)

---

## Usage

```bash
User: /start
# or
User: Cosa c'è da fare?
```

**Claude will:**
1. Read all context files
2. Parse tasks
3. Apply decision matrix
4. Output briefing with recommendations

**User then:**
- Pick a task from recommendations
- Follow suggested workflow
- Claude already knows context (no need to repeat)
STARTEOF

# --- /end skill ---
cat > "$PROJECT_DIR/.claude/skills/end/SKILL.md" << 'ENDEOF'
---
name: end
description: End session - finalize daily log, update current state, and commit
---

# End - Session Finalization

**Purpose:** Close session with complete context persisted to files. NOT to chat.

---

## MANDATORY RULES (NON-NEGOTIABLE)

### 1. ANALYZE ENTIRE CONVERSATION FIRST

Before writing anything, review THIS ENTIRE conversation and extract:

- **All tasks completed** - Every tool call with successful result, every user confirmation
- **Final state** - What's the current status of the work
- **All decisions made** - Choices, conclusions, architecture decisions
- **All files modified** - Run `git status` for real list
- **Blockers/issues** - Anything unresolved
- **Next steps** - What logically comes next based on actual work done

**DO NOT HALLUCINATE.** Only write what actually happened in this conversation.

### 2. USE TOOLS TO WRITE FILES

| Action | Tool | File |
|--------|------|------|
| Finalize daily log | **Write** or **Edit** | `_project_specs/session/daily/YYYY-MM-DD.md` |
| Update current state | **Edit** | `_project_specs/session/current-state.md` |
| Update sprint status | **Edit** | `_project_specs/sprint-status.yaml` |
| Git commit | **Bash** | `git add && git commit` |

### 3. NEVER DO THIS

- Output session summary to chat instead of files
- Say "here's what I would write"
- Use placeholder text like `[Task description]`
- Invent tasks not done in this conversation
- Hallucinate next steps unrelated to actual work

---

## Execution Steps

### Step 1: Get timestamp and date

```bash
date +%Y-%m-%d
date +%H:%M
```

### Step 2: Check git status

```bash
git status --short
git log --oneline -3
```

### Step 3: Analyze entire conversation

Review the full conversation and list:
- Every task completed (with outcomes)
- Current state of work
- Decisions made
- What should happen next (based on actual progress)

### Step 4: Read existing files

Read these files to understand current state:
- `_project_specs/session/daily/YYYY-MM-DD.md` (if exists)
- `_project_specs/session/current-state.md`
- `_project_specs/sprint-status.yaml`

### Step 5: Finalize daily log (USE Write/Edit TOOL)

**If daily log doesn't exist, create it with Write tool.**
**If exists, use Edit tool to add session summary at TOP.**

### Step 6: Update current-state.md (USE Edit TOOL)

Update: timestamp, active task, current status, next session instructions.

### Step 7: Update sprint-status.yaml (USE Edit TOOL)

Update task statuses if any tasks were completed or started.

### Step 8: Git commit (USE Bash TOOL)

```bash
git add _project_specs/session/ _project_specs/sprint-status.yaml
git commit -m "session: YYYY-MM-DD - [brief summary of actual work]"
```

### Step 9: Confirm to user

Short confirmation with files updated and next session instructions.

---

## Validation Checklist

- [ ] I analyzed the ENTIRE conversation (not hallucinated)
- [ ] I used Write/Edit/Bash tools (not output to chat)
- [ ] I filled REAL data (not placeholders)
- [ ] Daily log has session summary
- [ ] current-state.md has clear "Next Session" instructions
- [ ] sprint-status.yaml reflects actual progress
- [ ] Git commit was made
ENDEOF

# --- /update skill ---
cat > "$PROJECT_DIR/.claude/skills/update/SKILL.md" << 'UPDATEEOF'
---
name: update
description: Mid-session checkpoint - update daily log and current state
---

# Update - Mid-Session Checkpoint

**Purpose:** Persist session progress to files. NOT to chat.

---

## MANDATORY RULES (NON-NEGOTIABLE)

### 1. ANALYZE CONVERSATION FIRST

Before writing anything, extract from THIS conversation:

- **Tasks completed** - Look for tool calls with successful results, user confirmations
- **Current work** - What's actively being worked on right now
- **Decisions made** - Any choices or conclusions reached
- **Files modified** - Run `git status --short` to get real list
- **Blockers found** - Any issues discovered

**DO NOT HALLUCINATE.** If you didn't do it in this conversation, don't write it.

### 2. USE TOOLS TO WRITE FILES

| Action | Tool | File |
|--------|------|------|
| Create/update daily log | **Write** or **Edit** | `_project_specs/session/daily/YYYY-MM-DD.md` |
| Update current state | **Edit** | `_project_specs/session/current-state.md` |

### 3. NEVER DO THIS

- Output the update content in chat
- Say "here's what I would write"
- Use placeholder text
- Invent tasks not done in this conversation

---

## Execution Steps

1. Get timestamp: `date +%Y-%m-%d` and `date +%H:%M`
2. Check git status: `git status --short`
3. Analyze this conversation for completed work
4. Read or create daily log file
5. Append update section with real data
6. Update current-state.md if significant progress
7. Confirm to user (short)

---

## Daily Log Format

```markdown
## Update [HH:MM]

### Completed
- [Actual task from conversation with outcome]

### In Progress
- [Actual current work]

### Key Context
- [Actual decisions/findings from conversation]

### Files Modified
- [Actual files from git status]
```
UPDATEEOF

# --- /weekly-report skill ---
cat > "$PROJECT_DIR/.claude/skills/weekly-report/SKILL.md" << 'WEEKLYEOF'
---
name: weekly-report
description: Generate weekly progress report from all daily session logs
---

# Weekly Report - Session Aggregation

**Purpose:** Aggregate all daily session logs into a comprehensive weekly progress report.

---

## Behavior

1. **Determine week range:** Monday to Sunday, ISO week (YYYY-WW)
2. **Read daily sessions:** Scan `_project_specs/session/daily/` for current week
3. **Aggregate:** Tasks completed, decisions, files modified, blockers, metrics
4. **Generate report:** Create `_project_specs/session/weekly/YYYY-WW.md`
5. **Update index:** Add to `_project_specs/session/weekly/index.md`

---

## Output Template

```markdown
# Weekly Report - Week WW, YYYY

**Period:** YYYY-MM-DD to YYYY-MM-DD
**Days active:** X/7

---

## Summary
[One paragraph overview]

## Key Achievements
- [Major milestones]

## Tasks Completed
### Monday (YYYY-MM-DD)
- [x] Task 1

## Key Decisions
| Decision | Context | Impact |
|----------|---------|--------|

## Metrics
| Metric | Count |
|--------|-------|
| Commits | XX |

## Blockers & Issues
### Resolved
- [x] Blocker 1

### Outstanding
- [ ] Blocker 2

## Next Week Priorities
1. [Priority 1]

## Daily Logs
- [Day](path)
```

---

## Usage

```bash
/weekly-report          # Current week
/weekly-report 2026-W05 # Specific week
```
WEEKLYEOF

echo -e "${GREEN}  Session management skills created (start, end, update, weekly-report)${NC}"

# ============================================================================
# Step 7: Create n8n skills (if enabled)
# ============================================================================

if [ "$ENABLE_N8N" = true ]; then
    echo -e "${CYAN}Creating n8n skills...${NC}"

    # --- /debug skill ---
    cat > "$PROJECT_DIR/.claude/skills/debug/SKILL.md" << 'DEBUGEOF'
---
name: debug
description: Start a structured n8n debug session from execution_id
---

# Debug n8n Error

## Arguments
- `execution_id` (required): The n8n execution ID from dashboard or error_log

## Instructions

When this skill is invoked with an execution_id:

### Step 1: Fetch Error Data

Use database MCP to query error details (if error_log table exists):

```sql
SELECT id, execution_id, workflow_id, workflow_name, node_name,
       error_message, error_stack, user_id, context, environment, timestamp
FROM error_log
WHERE execution_id = '<execution_id>'
ORDER BY timestamp DESC
LIMIT 1
```

### Step 2: Fetch Execution Details from n8n

Use MCP `n8n-mcp-dev` to get execution details:

```
n8n_executions(action="get", id="<execution_id>", mode="error")
```

### Step 3: Populate current-debug.md

Read template at `_project_specs/debug/current-debug.md` and populate ALL fields.

### Step 4: Suggest Appropriate n8n Skill

| Error Pattern | Suggested Skill |
|---------------|-----------------|
| `{{ }}`, expression, $json, $node | `n8n-mcp-skills:n8n-expression-syntax` |
| Code node, JavaScript, $input | `n8n-mcp-skills:n8n-code-javascript` |
| Python, _input, _json | `n8n-mcp-skills:n8n-code-python` |
| Config, parameter, required field | `n8n-mcp-skills:n8n-node-configuration` |
| Validation, structure | `n8n-mcp-skills:n8n-validation-expert` |
| Flow, connection, trigger | `n8n-mcp-skills:n8n-workflow-patterns` |

### Step 5: Report to User

```
Debug session started for execution: <id>

Workflow: <name> (<environment>)
Node: <node_name>
Error: <error_message summary>

Suggested skill: <skill>

File: _project_specs/debug/current-debug.md

Next: Investigate the error, then use /test-fix when you have a solution.
```

## Error Handling

- If execution_id not found in error_log: check n8n directly
- If n8n execution fetch fails: proceed with DB data only
- If current-debug.md has existing in_progress session: warn user and ask to /archivia first
DEBUGEOF

    # --- /test-fix skill ---
    cat > "$PROJECT_DIR/.claude/skills/test-fix/SKILL.md" << 'TESTFIXEOF'
---
name: test-fix
description: Test and validate a debug fix, then prepare for archiving
---

# Test Debug Fix

## Instructions

### Step 1: Verify Active Session

Read `_project_specs/debug/current-debug.md` - check execution_id populated and status is `in_progress`.

### Step 2: Confirm Fix Applied

Ask user:
1. "Have you applied the fix on the [DEV] workflow?"
2. "Briefly describe the fix:"

### Step 3: Test Confirmation

Ask user:
1. "Have you tested the fix?"
2. "Test result: Pass / Fail?"

If Fail: keep status as `in_progress`, suggest next investigation steps.

### Step 4: Mark Error Resolved in DB (if error_log table exists)

```sql
UPDATE error_log
SET resolved_at = NOW(), resolved_by = 'claude',
    resolution_notes = '<brief fix description>'
WHERE execution_id = '<execution_id>'
```

### Step 5: Update current-debug.md

Update Resolution section with fix description, test result, status = `resolved`.

### Step 6: Decision Worthy Check

**If dev/test environment:** Auto-skip decision tracking.

**If prod:** Ask if decision-worthy:
- Trivial fix (< 5 lines, same node) → NO
- Changes flow between nodes → YES
- New pattern/convention → YES
- Recurring error (3+ times) → YES
- Impacts other workflows → YES

### Step 7: Suggest Next Step

```
Fix validated!
Next: /archivia [DEC-XXX]
```
TESTFIXEOF

    # --- /archivia skill ---
    cat > "$PROJECT_DIR/.claude/skills/archivia/SKILL.md" << 'ARCHIVIAEOF'
---
name: archivia
description: Archive current debug session, optionally linking to a decision
---

# Archive Debug Session

## Arguments
- `decision_id` (optional): Decision ID to link (e.g., DEC-007)

## Instructions

### Step 1: Read `_project_specs/debug/current-debug.md`
Extract execution_id, workflow_name, environment, status, resolution fields.

### Step 2: Validate
- File has execution_id (not empty template)
- Status is `resolved` or user confirms archiving unresolved

### Step 3: Determine Deletability
- dev/test environment → deletable
- decision_id provided → permanent
- no decision_id → deletable

### Step 4: Generate Archive Filename
Format: `YYYY-MM-DD-NNN.md`

### Step 5: Move and Update
1. Copy current-debug.md to archive/filename
2. Update archive/index.md with new row
3. Reset current-debug.md to empty template

### Step 6: Report

```
Debug archived: archive/<filename>
Status: <deletable/permanent>
Decision link: <decision_id or none>
current-debug.md reset.
```
ARCHIVIAEOF

    # --- /cleanup-debug skill ---
    cat > "$PROJECT_DIR/.claude/skills/cleanup-debug/SKILL.md" << 'CLEANUPEOF'
---
name: cleanup-debug
description: Remove old deletable debug files from archive
---

# Cleanup Debug Archive

## Arguments
- `days` (optional, default=30): Delete files older than X days

## Instructions

1. Parse arguments (days = argument or 30)
2. Read `_project_specs/debug/archive/index.md`
3. Find eligible files: status=deletable AND date < cutoff
4. Show preview to user, ask confirmation
5. Delete eligible files
6. Update index.md stats
7. Report results

## Safety
- NEVER delete files with `permanent` status
- NEVER delete files with a decision_link
- Always show preview and ask confirmation
CLEANUPEOF

    # --- /sync-n8n skill ---
    cat > "$PROJECT_DIR/.claude/skills/sync-n8n/SKILL.md" << SYNCEOF
---
name: sync-n8n
description: Sync all n8n workflows tagged "${N8N_TAG}" and update changelog
---

# Sync n8n Workflows

## Instructions

1. **Run the sync script:**
   \`\`\`bash
   ./scripts/sync-workflows.sh
   \`\`\`

2. **Report results:**
   - Number of workflows synced (new/modified)
   - Any errors encountered
   - Confirm changelog was updated

3. **If user passes \`--dry-run\`:**
   \`\`\`bash
   ./scripts/sync-workflows.sh --dry-run
   \`\`\`

## What Gets Synced

- All workflows with "${N8N_TAG}" tag from ${N8N_URL}
- Downloads to \`workflows/*.json\`
- Updates \`workflows/meta.json\`
- Updates \`changelog-n8n.md\`
- Auto-commits to git

## Troubleshooting

- Check \`N8N_API_KEY\` is set in \`.env\`
- Verify n8n instance is reachable
- Run with \`--dry-run\` to debug
SYNCEOF

    echo -e "${GREEN}  n8n skills created (debug, test-fix, archivia, cleanup-debug, sync-n8n)${NC}"

    # ========================================================================
    # Step 8: Create n8n scripts
    # ========================================================================

    echo -e "${CYAN}Creating n8n scripts...${NC}"

    # --- dev-workflow.sh ---
    cat > "$PROJECT_DIR/scripts/dev-workflow.sh" << DEVWFEOF
#!/bin/bash
# n8n Dev Workflow Manager
# Usage: ./dev-workflow.sh <command> [args]
#
# Manages [DEV] workflow copies for safe development:
# - create <id>    - Duplicate workflow as [DEV] copy
# - status         - List all [DEV] workflows
# - promote <id>   - Apply [DEV] changes to production (with backup)
# - delete <id>    - Delete [DEV] workflow
# - cleanup        - Remove old backups (14+ days)

set -e

# Configuration
N8N_URL="${N8N_URL}"
PROJECT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
BACKUPS_DIR="\$PROJECT_DIR/workflows/backups"

# Load .env if exists
[ -f "\$PROJECT_DIR/.env" ] && source "\$PROJECT_DIR/.env"
API_KEY="\${N8N_API_KEY:-}"

# Validate
if [ -z "\$API_KEY" ]; then
    echo "Error: N8N_API_KEY not set"
    echo "Set in .env or environment: export N8N_API_KEY=your_key"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required. Install with: brew install jq"
    exit 1
fi

# API helper
api_call() {
    local method="\$1"
    local path="\$2"
    local body="\${3:-}"
    local url="\$N8N_URL/api/v1\$path"
    local response http_code

    if [ -n "\$body" ]; then
        response=\$(curl -s -w "\n%{http_code}" -X "\$method" \
            -H "X-N8N-API-KEY: \$API_KEY" \
            -H "Content-Type: application/json" \
            -d "\$body" "\$url")
    else
        response=\$(curl -s -w "\n%{http_code}" -X "\$method" \
            -H "X-N8N-API-KEY: \$API_KEY" "\$url")
    fi

    http_code=\$(echo "\$response" | tail -n1)
    body=\$(echo "\$response" | sed '\$d')

    if [[ "\$http_code" -ge 400 ]]; then
        echo "Error: API request failed (HTTP \$http_code)" >&2
        [ "\${DEBUG:-0}" = "1" ] && echo "Response: \$body" >&2
        exit 1
    fi

    echo "\$body"
}

get_tag_id() {
    local tag_name="\$1"
    local tags_response tag_id
    tags_response=\$(api_call "GET" "/tags")
    tag_id=\$(echo "\$tags_response" | jq -r --arg name "\$tag_name" '.data[] | select(.name == \$name) | .id')
    if [ -z "\$tag_id" ] || [ "\$tag_id" = "null" ]; then
        echo "Error: Tag '\$tag_name' not found" >&2
        exit 1
    fi
    echo "\$tag_id"
}

create_dev() {
    local source_id="\$1"
    echo "Creating [DEV] copy of workflow \$source_id..."
    echo ""

    local source_workflow
    source_workflow=\$(api_call "GET" "/workflows/\$source_id")
    local source_name
    source_name=\$(echo "\$source_workflow" | jq -r '.name')

    if [ -z "\$source_name" ] || [ "\$source_name" = "null" ]; then
        echo "Error: Workflow \$source_id not found"
        exit 1
    fi

    if [[ "\$source_name" =~ ^\[DEV\]\  ]]; then
        echo "Error: Source is already a [DEV] copy"
        exit 1
    fi

    local dev_name="[DEV] \$source_name"
    local all_workflows
    all_workflows=\$(api_call "GET" "/workflows")
    local existing_dev
    existing_dev=\$(echo "\$all_workflows" | jq -r --arg name "\$dev_name" '.data[] | select(.name == \$name) | .id')

    if [ -n "\$existing_dev" ] && [ "\$existing_dev" != "null" ]; then
        echo "Error: DEV copy already exists (ID: \$existing_dev)"
        echo "Use './dev-workflow.sh delete \$existing_dev' first"
        exit 1
    fi

    local test_tag_id
    test_tag_id=\$(get_tag_id "test")

    local nodes connections settings
    nodes=\$(echo "\$source_workflow" | jq -c '.nodes')
    connections=\$(echo "\$source_workflow" | jq -c '.connections')
    settings=\$(echo "\$source_workflow" | jq -c '.settings // {} | {
        executionOrder: .executionOrder,
        timezone: .timezone,
        saveExecutionProgress: .saveExecutionProgress,
        saveManualExecutions: .saveManualExecutions,
        callerPolicy: .callerPolicy
    } | with_entries(select(.value != null))')

    local new_workflow_body
    new_workflow_body=\$(jq -n \
        --arg name "\$dev_name" \
        --argjson nodes "\$nodes" \
        --argjson connections "\$connections" \
        --argjson settings "\$settings" \
        '{name: \$name, nodes: \$nodes, connections: \$connections, settings: \$settings}')

    local new_workflow new_id
    new_workflow=\$(api_call "POST" "/workflows" "\$new_workflow_body")
    new_id=\$(echo "\$new_workflow" | jq -r '.id')

    local tag_body
    tag_body=\$(jq -n --arg tag_id "\$test_tag_id" '[{"id": \$tag_id}]')
    api_call "PUT" "/workflows/\$new_id/tags" "\$tag_body" > /dev/null

    echo "Created [DEV] workflow"
    echo "  Source:   \$source_name"
    echo "  DEV Name: \$dev_name"
    echo "  DEV ID:   \$new_id"
    echo "  View: \$N8N_URL/workflow/\$new_id"
    echo ""
    echo "Next: make changes, test, then './dev-workflow.sh promote \$new_id'"
}

status() {
    echo "=== [DEV] Workflows ==="
    echo ""
    local test_tag_id
    test_tag_id=\$(get_tag_id "test")
    local all_workflows
    all_workflows=\$(api_call "GET" "/workflows?tags=\$test_tag_id")
    local dev_workflows
    dev_workflows=\$(echo "\$all_workflows" | jq -r '.data[] | select(.name | startswith("[DEV]"))')

    if [ -z "\$dev_workflows" ]; then
        echo "No [DEV] workflows found."
        return
    fi

    printf "%-18s %-50s %-8s %-19s\n" "ID" "Name" "Active" "Updated"
    printf "%-18s %-50s %-8s %-19s\n" "--" "----" "------" "-------"

    echo "\$dev_workflows" | jq -r '@json' | while IFS= read -r line; do
        local id name active updated
        id=\$(echo "\$line" | jq -r '.id')
        name=\$(echo "\$line" | jq -r '.name')
        active=\$(echo "\$line" | jq -r '.active')
        updated=\$(echo "\$line" | jq -r '.updatedAt' | cut -d'T' -f1,2 | tr 'T' ' ')
        [ \${#name} -gt 50 ] && name="\${name:0:47}..."
        printf "%-18s %-50s %-8s %-19s\n" "\$id" "\$name" "\$active" "\$updated"
    done
}

promote() {
    local dev_id="\$1"
    echo "Promoting [DEV] workflow to production..."

    local dev_workflow
    dev_workflow=\$(api_call "GET" "/workflows/\$dev_id")
    local dev_name
    dev_name=\$(echo "\$dev_workflow" | jq -r '.name')

    if [[ ! "\$dev_name" =~ ^\[DEV\]\  ]]; then
        echo "Error: Not a [DEV] workflow"
        exit 1
    fi

    local prod_name="\${dev_name#\[DEV\] }"
    local all_workflows
    all_workflows=\$(api_call "GET" "/workflows")

    local match_count
    match_count=\$(echo "\$all_workflows" | jq -r --arg name "\$prod_name" '[.data[] | select(.name == \$name)] | length')

    if [ "\$match_count" -eq 0 ]; then
        echo "Error: Production workflow '\$prod_name' not found"
        exit 1
    fi
    if [ "\$match_count" -gt 1 ]; then
        echo "Error: Multiple workflows named '\$prod_name'"
        exit 1
    fi

    local prod_id
    prod_id=\$(echo "\$all_workflows" | jq -r --arg name "\$prod_name" '.data[] | select(.name == \$name) | .id')
    local full_prod_workflow
    full_prod_workflow=\$(api_call "GET" "/workflows/\$prod_id")
    local prod_updated_at
    prod_updated_at=\$(echo "\$full_prod_workflow" | jq -r '.updatedAt')

    mkdir -p "\$BACKUPS_DIR"
    local backup_file="\$BACKUPS_DIR/\${prod_id}-\$(date +%Y-%m-%d).json"
    echo "\$full_prod_workflow" > "\$backup_file"
    echo "Backup: workflows/backups/\$(basename "\$backup_file")"

    read -p "Apply changes to production? (y/N) " -n 1 -r
    echo ""
    if [[ ! \$REPLY =~ ^[Yy]\$ ]]; then
        rm "\$backup_file"
        echo "Cancelled."
        exit 0
    fi

    # Race condition check
    local current_prod current_updated_at
    current_prod=\$(api_call "GET" "/workflows/\$prod_id")
    current_updated_at=\$(echo "\$current_prod" | jq -r '.updatedAt')
    if [ "\$current_updated_at" != "\$prod_updated_at" ]; then
        echo "Error: Production was modified during promotion. Try again."
        rm "\$backup_file"
        exit 1
    fi

    local patch_body
    patch_body=\$(jq -n \
        --argjson nodes "\$(echo "\$dev_workflow" | jq -c '.nodes')" \
        --argjson connections "\$(echo "\$dev_workflow" | jq -c '.connections')" \
        '{nodes: \$nodes, connections: \$connections}')

    api_call "PATCH" "/workflows/\$prod_id" "\$patch_body" > /dev/null
    echo "Production updated! Next: './dev-workflow.sh delete \$dev_id'"
}

delete_dev() {
    local dev_id="\$1"
    local workflow
    workflow=\$(api_call "GET" "/workflows/\$dev_id")
    local name
    name=\$(echo "\$workflow" | jq -r '.name')

    if [[ ! "\$name" =~ ^\[DEV\]\  ]]; then
        echo "Error: Refusing to delete non-[DEV] workflow"
        exit 1
    fi

    mkdir -p "\$BACKUPS_DIR"
    echo "\$workflow" > "\$BACKUPS_DIR/\${dev_id}-deleted-\$(date +%Y-%m-%d-%H%M%S).json"
    api_call "DELETE" "/workflows/\$dev_id" > /dev/null
    echo "Deleted: \$name"
}

cleanup() {
    local old_backups count
    old_backups=\$(find "\$BACKUPS_DIR" -name "*.json" -mtime +14 2>/dev/null || true)
    count=\$(echo "\$old_backups" | grep -c "\.json\$" || true)
    if [ "\$count" -eq 0 ]; then
        echo "No old backups (14+ days)"
        return
    fi
    find "\$BACKUPS_DIR" -name "*.json" -mtime +14 -delete 2>/dev/null
    echo "Deleted \$count old backup(s)"
}

usage() {
    cat <<EOF
n8n Dev Workflow Manager

Usage:
  ./dev-workflow.sh create <workflow_id>   Create [DEV] copy
  ./dev-workflow.sh status                 List [DEV] workflows
  ./dev-workflow.sh promote <dev_id>       Promote [DEV] to production
  ./dev-workflow.sh delete <dev_id>        Delete [DEV] workflow
  ./dev-workflow.sh cleanup                Remove old backups (14+ days)

Environment:
  N8N_API_KEY    Required. Set in .env or environment.
EOF
}

case "\${1:-}" in
    create)  [ -z "\${2:-}" ] && { usage; exit 1; }; create_dev "\$2" ;;
    status)  status ;;
    promote) [ -z "\${2:-}" ] && { usage; exit 1; }; promote "\$2" ;;
    delete)  [ -z "\${2:-}" ] && { usage; exit 1; }; delete_dev "\$2" ;;
    cleanup) cleanup ;;
    -h|--help|help) usage ;;
    *) echo "Unknown: \${1:-}"; usage; exit 1 ;;
esac
DEVWFEOF
    chmod +x "$PROJECT_DIR/scripts/dev-workflow.sh"

    # --- sync-workflows.sh ---
    cat > "$PROJECT_DIR/scripts/sync-workflows.sh" << SYNCWFEOF
#!/bin/bash
# Sync n8n workflows with changelog tracking
# Usage: ./sync-workflows.sh [--dry-run] [--no-commit]

set -e

N8N_URL="${N8N_URL}"
PROJECT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOWS_DIR="\$PROJECT_DIR/workflows"
META_FILE="\$WORKFLOWS_DIR/meta.json"
CHANGELOG_FILE="\$PROJECT_DIR/changelog-n8n.md"

[ -f "\$PROJECT_DIR/.env" ] && source "\$PROJECT_DIR/.env"
API_KEY="\${N8N_API_KEY:-}"
SYNC_TAG="${N8N_TAG}"

DRY_RUN=false
NO_COMMIT=false
for arg in "\$@"; do
    case \$arg in
        --dry-run) DRY_RUN=true ;;
        --no-commit) NO_COMMIT=true ;;
    esac
done

if [ -z "\$API_KEY" ]; then
    echo "Error: N8N_API_KEY not set"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq required. Install: brew install jq"
    exit 1
fi

mkdir -p "\$WORKFLOWS_DIR"
[ ! -f "\$META_FILE" ] && echo '{"lastSync": null, "workflows": {}}' > "\$META_FILE"

echo "=== n8n Workflow Sync ==="
echo "Fetching workflows with tag '\$SYNC_TAG'..."

REMOTE_DATA=\$(curl -s -H "X-N8N-API-KEY: \$API_KEY" "\$N8N_URL/api/v1/workflows")
TRACKED_IDS=(\$(echo "\$REMOTE_DATA" | jq -r --arg tag "\$SYNC_TAG" '.data[] | select(.tags[]?.name == \$tag) | .id'))

echo "Found \${#TRACKED_IDS[@]} workflows"

declare -a NEW_WORKFLOWS MODIFIED_WORKFLOWS CHANGE_COMMENTS

for id in "\${TRACKED_IDS[@]}"; do
    remote_info=\$(echo "\$REMOTE_DATA" | jq -r --arg id "\$id" '.data[] | select(.id == \$id)')
    [ -z "\$remote_info" ] || [ "\$remote_info" = "null" ] && continue

    remote_name=\$(echo "\$remote_info" | jq -r '.name')
    remote_updated=\$(echo "\$remote_info" | jq -r '.updatedAt')
    remote_nodes=\$(echo "\$remote_info" | jq -r '.nodeCount')
    remote_active=\$(echo "\$remote_info" | jq -r '.active')

    [[ "\$remote_name" == "[DEV]"* ]] && continue

    local_updated=\$(jq -r --arg id "\$id" '.workflows[\$id].updatedAt // "never"' "\$META_FILE")
    local_nodes=\$(jq -r --arg id "\$id" '.workflows[\$id].nodeCount // 0' "\$META_FILE")

    filename=\$(echo "\$remote_name" | tr '[:upper:]' '[:lower:]' | sed 's/ - /-/g' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
    filename="\${filename}.json"

    if [ "\$local_updated" = "never" ] || [ "\$local_updated" = "null" ]; then
        NEW_WORKFLOWS+=("\$id")
        CHANGE_COMMENTS+=("NEW: \$remote_name (\$remote_nodes nodes)")
        echo "  NEW: \$remote_name"
    elif [ "\$remote_updated" != "\$local_updated" ]; then
        MODIFIED_WORKFLOWS+=("\$id")
        CHANGE_COMMENTS+=("MODIFIED: \$remote_name")
        echo "  MODIFIED: \$remote_name"
    else
        echo "  unchanged: \$remote_name"
    fi
done

TOTAL_CHANGES=\$((\${#NEW_WORKFLOWS[@]} + \${#MODIFIED_WORKFLOWS[@]}))
echo ""
echo "\$TOTAL_CHANGES change(s)"

[ \$TOTAL_CHANGES -eq 0 ] && exit 0
[ "\$DRY_RUN" = true ] && { echo "[DRY RUN]"; exit 0; }

# Download changed workflows
for id in "\${NEW_WORKFLOWS[@]}" "\${MODIFIED_WORKFLOWS[@]}"; do
    remote_info=\$(echo "\$REMOTE_DATA" | jq -r --arg id "\$id" '.data[] | select(.id == \$id)')
    remote_name=\$(echo "\$remote_info" | jq -r '.name')
    filename=\$(echo "\$remote_name" | tr '[:upper:]' '[:lower:]' | sed 's/ - /-/g' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g').json

    curl -s -o "\$WORKFLOWS_DIR/\$filename" -H "X-N8N-API-KEY: \$API_KEY" "\$N8N_URL/api/v1/workflows/\$id"

    remote_updated=\$(echo "\$remote_info" | jq -r '.updatedAt')
    remote_nodes=\$(echo "\$remote_info" | jq -r '.nodeCount')
    remote_active=\$(echo "\$remote_info" | jq -r '.active')

    jq --arg id "\$id" --arg name "\$remote_name" --arg file "\$filename" \
       --arg updated "\$remote_updated" --argjson nodes "\$remote_nodes" --argjson active "\$remote_active" \
       '.workflows[\$id] = {name: \$name, file: \$file, updatedAt: \$updated, nodeCount: \$nodes, active: \$active}' \
       "\$META_FILE" > "\$META_FILE.tmp" && mv "\$META_FILE.tmp" "\$META_FILE"
done

jq --arg time "\$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '.lastSync = \$time' "\$META_FILE" > "\$META_FILE.tmp" && mv "\$META_FILE.tmp" "\$META_FILE"

if [ "\$NO_COMMIT" = false ]; then
    cd "\$PROJECT_DIR"
    git add workflows/
    git commit -m "sync: update \$TOTAL_CHANGES workflow(s)"
    COMMIT_HASH=\$(git rev-parse --short HEAD)

    # Update changelog
    ENTRY="## \$(date +"%Y-%m-%d %H:%M") - Workflow Sync\n\n**Commit:** \\\`\$COMMIT_HASH\\\`\n"
    for c in "\${CHANGE_COMMENTS[@]}"; do ENTRY+="\n- \$c"; done
    ENTRY+="\n"

    if [ -f "\$CHANGELOG_FILE" ]; then
        { head -n 4 "\$CHANGELOG_FILE"; echo -e "\$ENTRY"; tail -n +5 "\$CHANGELOG_FILE"; } > "\$CHANGELOG_FILE.tmp" && mv "\$CHANGELOG_FILE.tmp" "\$CHANGELOG_FILE"
    else
        echo -e "# n8n Workflow Changelog\n\nAuto-generated by sync script.\n\n\$ENTRY" > "\$CHANGELOG_FILE"
    fi

    git add changelog-n8n.md
    git commit -m "docs: update changelog-n8n.md (\$COMMIT_HASH)"
fi

echo "=== Sync Complete ==="
SYNCWFEOF
    chmod +x "$PROJECT_DIR/scripts/sync-workflows.sh"

    echo -e "${GREEN}  n8n scripts created (dev-workflow.sh, sync-workflows.sh)${NC}"

    # Create n8n debug template files
    echo -e "${CYAN}Creating n8n debug templates...${NC}"

    cat > "$PROJECT_DIR/_project_specs/debug/current-debug.md" << 'DBGEOF'
# Debug Session

<!--
WORKFLOW:
1. /debug <execution_id> populates this file
2. Investigate with n8n skill
3. /test-fix to test
4. /archivia [DEC-XXX] to archive
-->

## Metadata
| Campo | Valore |
|-------|--------|
| **execution_id** | |
| **workflow_id** | |
| **workflow_name** | |
| **environment** | |
| **node_name** | |
| **user_id** | |
| **timestamp** | |
| **debug_started** | |
| **status** | pending |

## Error Details

**error_message:**

**error_stack:**

**context:**

## Execution Path

## Investigation Notes

## Resolution
| Campo | Valore |
|-------|--------|
| **fix_description** | |
| **files_modified** | |
| **tested** | [ ] |
| **test_result** | |

## Decision Tracking
| Campo | Valore |
|-------|--------|
| **decision_worthy** | |
| **decision_link** | |
| **reason** | |
DBGEOF

    cat > "$PROJECT_DIR/_project_specs/debug/archive/index.md" << 'IDXEOF'
# Debug Archive Index

Archived debug sessions. Files without `decision_link` can be deleted after 30 days.

## Legend
- **deletable**: Can be removed with `/cleanup-debug`
- **permanent**: Linked to decision, not deletable

---

## Archive

| Date | File | Workflow | Environment | Error Type | Resolution | Decision Link | Status |
|------|------|----------|-------------|------------|------------|---------------|--------|
<!-- Template row:
| 2026-01-29 | 001.md | Hot Path | prod | Expression error | Fixed $json ref | DEC-007 | permanent |
-->

---

## Stats
- **Total archived**: 0
- **Permanent (decision-linked)**: 0
- **Deletable**: 0
- **Last cleanup**: never

---

## Cleanup Policy
- Files older than 30 days without `decision_link` are eligible
- Run `/cleanup-debug 30` to remove eligible files
IDXEOF

    echo -e "${GREEN}  n8n debug templates created${NC}"
fi

# ============================================================================
# Step 9: Create git-push-verify.sh
# ============================================================================

echo -e "${CYAN}Creating utility scripts...${NC}"

GITHUB_REPO_ESCAPED="${GITHUB_REPO:-owner/repo}"

cat > "$PROJECT_DIR/scripts/git-push-verify.sh" << GPVEOF
#!/bin/bash
# Safe git push with verification
# Usage: ./scripts/git-push-verify.sh [branch]

set -e

BRANCH="\${1:-main}"
REMOTE="origin"

echo "Pushing to \$REMOTE/\$BRANCH..."

BEFORE_PUSH=\$(git rev-parse HEAD)
git push "\$REMOTE" "\$BRANCH" --verbose

echo ""
echo "Waiting 3 seconds for sync..."
sleep 3

git fetch "\$REMOTE" --quiet
REMOTE_HEAD=\$(git rev-parse "\$REMOTE/\$BRANCH")

echo ""
echo "Verification:"
echo "  Local HEAD:  \$BEFORE_PUSH"
echo "  Remote HEAD: \$REMOTE_HEAD"

if [ "\$BEFORE_PUSH" = "\$REMOTE_HEAD" ]; then
    echo "Push verified!"

    echo "Double-checking via GitHub API..."
    REPO="${GITHUB_REPO_ESCAPED}"
    API_RESPONSE=\$(curl -s "https://api.github.com/repos/\$REPO/commits/\$BEFORE_PUSH" | grep -o '"sha"' | wc -l)

    if [ "\$API_RESPONSE" -gt 0 ]; then
        echo "Commit exists on GitHub."
        exit 0
    else
        echo "Warning: Git shows commit but API doesn't (cache delay?)"
        exit 1
    fi
else
    echo "PUSH FAILED! Remote doesn't have your commits."
    exit 1
fi
GPVEOF
chmod +x "$PROJECT_DIR/scripts/git-push-verify.sh"

echo -e "${GREEN}  git-push-verify.sh created${NC}"

# --- quality-check.sh ---
DEVKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$DEVKIT_DIR/scripts/quality-check.sh" ]; then
    cp "$DEVKIT_DIR/scripts/quality-check.sh" "$PROJECT_DIR/scripts/quality-check.sh"
    chmod +x "$PROJECT_DIR/scripts/quality-check.sh"
    echo -e "${GREEN}  quality-check.sh created${NC}"
fi

# --- CODE_INDEX.md ---
cat > "$PROJECT_DIR/CODE_INDEX.md" << 'CIEOF'
# Code Index

> Auto-generated catalog of functions, hooks, types, and utilities.
> Check here before writing new code to avoid duplication.
> Update with `/update-code-index` after significant changes.

## How to Use

Before creating a new function, hook, type, or utility:
1. Search this file for similar functionality
2. If found, reuse or extend the existing implementation
3. If not found, create it and add an entry here

---

*Run `/update-code-index` to populate this file.*
CIEOF
echo -e "${GREEN}  CODE_INDEX.md created${NC}"

# ============================================================================
# Step 10: Create _project_specs template files
# ============================================================================

echo -e "${CYAN}Creating session state templates...${NC}"

cat > "$PROJECT_DIR/_project_specs/session/current-state.md" << CSEOF
# Current State

*Last updated: $(date +%Y-%m-%d)*

---

## Active Task

None - project just initialized.

## Current Status
- Phase: Setup
- Progress: Project structure created
- Blocking Issues: None

## Implementation Progress

| Task | Status | Notes |
|------|--------|-------|
| Project init | Done | Structure created |

---

## Next Session

**To Continue:**
1. Set up PROJECT.md with project-specific context
2. Configure sprint-status.yaml with first sprint
3. Start first task

**Resume Instructions:**
Run \`/start\` to get briefing with recommendations.
CSEOF

cat > "$PROJECT_DIR/_project_specs/sprint-status.yaml" << SPEOF
# Sprint Status - Single Source of Truth
# Update with /end skill or manually

sprint_s0:
  name: "S0 - Project Setup"
  status: in_progress
  started: "$(date +%Y-%m-%d)"
  tasks:
    - id: s0-01
      task: "Configure PROJECT.md with project context"
      status: pending
      priority: high
      effort: "30m"
    - id: s0-02
      task: "Set up development environment"
      status: pending
      priority: high
      effort: "1h"
    - id: s0-03
      task: "Define first sprint tasks"
      status: pending
      priority: medium
      effort: "30m"
SPEOF

cat > "$PROJECT_DIR/_project_specs/session/decisions.md" << 'DECEOF'
# Decision Log

Track key decisions for future reference. Never delete entries.

---

<!-- Template:
## [YYYY-MM-DD] Decision Title

**Decision**: What was decided

**Context**: Why this decision was needed

**Options Considered**:
1. Option A - pros/cons
2. Option B - pros/cons

**Choice**: Which option and why

**References**:
- Related files or links
-->
DECEOF

echo -e "${GREEN}  Session state templates created${NC}"

# ============================================================================
# Step 11: Create documentation templates
# ============================================================================

echo -e "${CYAN}Creating documentation...${NC}"

# --- n8n-development.md (if n8n enabled) ---
if [ "$ENABLE_N8N" = true ]; then
    cat > "$PROJECT_DIR/docs/n8n-development.md" << N8NDOCEOF
# n8n Development Reference

*Last updated: $(date +%Y-%m-%d)*

---

## Quick Reference

| Category | Tools |
|----------|-------|
| **MCP Skills** | 7 n8n-mcp-skills for workflow development |
| **Debug Workflow** | Structured debug with persistent state |
| **Dev Workflow Manager** | [DEV] workflow lifecycle automation |
| **MCP Server** | n8n-mcp-dev (CRUD, validate, execute) |

---

## CRITICAL RULES

1. **NEVER edit production workflows directly** - Always use [DEV] copies
2. **Use n8n-mcp-dev** for workflow operations (NOT n8n-mcp-prod)
3. **Use n8n MCP skills** during debug

---

## n8n MCP Skills

| Skill | When to Use |
|-------|-------------|
| \`n8n-mcp-skills:n8n-code-javascript\` | Code node JS errors |
| \`n8n-mcp-skills:n8n-code-python\` | Code node Python errors |
| \`n8n-mcp-skills:n8n-expression-syntax\` | Expression errors |
| \`n8n-mcp-skills:n8n-node-configuration\` | Node configuration |
| \`n8n-mcp-skills:n8n-validation-expert\` | Validation errors |
| \`n8n-mcp-skills:n8n-workflow-patterns\` | Workflow architecture |
| \`n8n-mcp-skills:n8n-mcp-tools-expert\` | MCP tool usage |

---

## Debug Workflow

| Command | Purpose |
|---------|---------|
| \`/debug <execution_id>\` | Start debug session |
| \`/test-fix\` | Test fix, evaluate decision-worthy |
| \`/archivia [DEC-XXX]\` | Archive debug session |
| \`/cleanup-debug [days]\` | Clean old debug files |

---

## Dev Workflow Manager

\`\`\`bash
./scripts/dev-workflow.sh create <prod-id>    # Create [DEV] copy
./scripts/dev-workflow.sh status              # List [DEV] workflows
./scripts/dev-workflow.sh promote <dev-id>    # Promote to prod
./scripts/dev-workflow.sh delete <dev-id>     # Delete [DEV] copy
\`\`\`

---

## Workflow Tags

| Tag | Meaning |
|-----|---------|
| \`${N8N_TAG}\` | Production workflows |
| \`test\` | Test/DEV workflows |
| \`old\` | Deprecated workflows |

---

## Sync Workflow Changes

\`\`\`bash
/sync-n8n                          # Sync all tagged workflows
./scripts/sync-workflows.sh        # Direct script
./scripts/sync-workflows.sh --dry-run  # Preview only
\`\`\`
N8NDOCEOF
fi

# --- frontend-development.md ---
cat > "$PROJECT_DIR/docs/frontend-development.md" << 'FEDOCEOF'
# Frontend Development Reference

*Last updated: auto-generated*

---

## Design Approach: Intent-Driven with /interface-design

**For ANY UI work, start with intent, not components.**

Use the `/interface-design` skill to ensure every interface decision is intentional:

### Workflow

1. **Define intent:** Who is the user? What must they accomplish? How should it feel?
2. **Explore domain:** Product concepts, color world, signature element
3. **Build with craft:** Apply design principles from the skill
4. **Save patterns:** Persist to `.interface-design/system.md` for consistency

### Commands

| Command | Purpose |
|---------|---------|
| `/interface-design:init` | Start a new interface with intent-first approach |
| `/interface-design:status` | Show current design system state |
| `/interface-design:audit` | Check code against design system |
| `/interface-design:critique` | Critique build for craft, rebuild defaults |
| `/interface-design:extract` | Extract patterns from existing code |

### Component Libraries (Optional)

If your project uses shadcn/ui or another component library, use it as a foundation — but always apply your design system's tokens and patterns on top. Component libraries provide structure; your design system provides identity.

---

## UI Skills

| Skill | Purpose |
|-------|---------|
| `interface-design` | Intent-driven design for dashboards, apps, tools |
| `ui-web` | Web UI patterns, Tailwind, dark mode, a11y |
| `react-web` | React hooks, React Query, Zustand |
| `ui-mobile` | Mobile patterns, touch targets |
FEDOCEOF

# --- backend-development.md ---
DB_MCP_DISPLAY="${DB_MCP_NAME:-database MCP}"
cat > "$PROJECT_DIR/docs/backend-development.md" << BEDOCEOF
# Backend Development Reference

*Last updated: $(date +%Y-%m-%d)*

---

## Quick Reference

| Category | Tools/Rules |
|----------|-------------|
| **Database Access** | ${DB_MCP_DISPLAY} MCP server |
| **Multi-Tenancy** | MANDATORY user_id filtering |

---

## CRITICAL Rule: Multi-Tenancy

**ALL database queries MUST filter by \`user_id\`.**

\`\`\`sql
-- NEVER
SELECT * FROM user_data;

-- ALWAYS
SELECT * FROM user_data WHERE user_id = 'user_123';
\`\`\`

---

## Database MCP Permission Rules

| Operation | Permission |
|-----------|------------|
| SELECT, search, analysis | Free - use without asking |
| INSERT, UPDATE, DELETE | **ASK ALWAYS** before executing |
| ALTER, DROP, CREATE | **ASK ALWAYS** before executing |

---

## Security

- Use parameterized queries (never string concatenation)
- Never hardcode credentials
- Validate all inputs
- Filter by user_id in every query
BEDOCEOF

echo -e "${GREEN}  Documentation created${NC}"

# ============================================================================
# Step 12: Create CLAUDE.md
# ============================================================================

echo -e "${CYAN}Creating CLAUDE.md...${NC}"

N8N_SECTION=""
if [ "$ENABLE_N8N" = true ]; then
    N8N_SECTION="
### n8n Workflow Development
**NEVER edit production workflows directly.**

1. Create [DEV] copy: \`./scripts/dev-workflow.sh create <prod-id>\`
2. Make changes in n8n UI
3. Test on [DEV]
4. Promote: \`./scripts/dev-workflow.sh promote <dev-id>\`
5. Delete [DEV]: \`./scripts/dev-workflow.sh delete <dev-id>\`

**Tags:**
- \`${N8N_TAG}\` - Production workflows
- \`test\` - Test/DEV workflows
- \`old\` - Deprecated/archived

**See:** \`docs/n8n-development.md\`
"
fi

N8N_COMMANDS=""
if [ "$ENABLE_N8N" = true ]; then
    N8N_COMMANDS="| \`/debug\` | \`.claude/skills/debug/\` | Start n8n debug session |
| \`/test-fix\` | \`.claude/skills/test-fix/\` | Test and validate debug fix |
| \`/archivia\` | \`.claude/skills/archivia/\` | Archive debug session |
| \`/sync-n8n\` | \`.claude/skills/sync-n8n/\` | Sync workflows to git |
| \`dev-workflow.sh\` | \`scripts/dev-workflow.sh\` | n8n [DEV] workflow manager |"
fi

N8N_MATRIX=""
if [ "$ENABLE_N8N" = true ]; then
    N8N_MATRIX="| **n8n workflow bug** | \`/debug <exec_id>\` | n8n-mcp-skills (auto-select) | Debug workflow isolates error |
| **n8n feature add** | \`dev-workflow.sh create\` + \`bmad-bmm-quick-dev\` | n8n-node-configuration | Safe [DEV] testing |"
fi

cat > "$PROJECT_DIR/CLAUDE.md" << CLAUDEEOF
# Claude Development System

**Last updated:** $(date +%Y-%m-%d)

---

## Quick Reference

| Resource | Link |
|----------|------|
| **Project Context** | [PROJECT.md](PROJECT.md) |
| **Session State** | [_project_specs/session/current-state.md](_project_specs/session/current-state.md) |
| **Sprint Status** | [_project_specs/sprint-status.yaml](_project_specs/sprint-status.yaml) |
| **Frontend Dev** | [docs/frontend-development.md](docs/frontend-development.md) |
| **Backend Dev** | [docs/backend-development.md](docs/backend-development.md) |$([ "$ENABLE_N8N" = true ] && echo "
| **n8n Development** | [docs/n8n-development.md](docs/n8n-development.md) |")

---

## Communication Principles

- **Direct and concise**: No fluff, no superlatives, no bullshit
- **Intellectually honest**: Not a yes-man -- push back when issues exist
- **Realistic and cynical**: Prefer "this will break" over "this might work"
- **Evidence before assertions**: Run verification commands before claiming success
- **Exception**: Creative brainstorming (different mode, explicit)

---

## CRITICAL Rules

### Git (NON-NEGOTIABLE)
- Email: \`${GIT_EMAIL}\` (configured globally)
- **NO** \`Co-Authored-By: Claude\` in commits
- Verify push: \`./scripts/git-push-verify.sh\`

### Multi-Tenancy (NON-NEGOTIABLE)
- **ALL** database queries MUST filter by \`user_id\`
- NEVER use hardcoded credentials for user data
- NEVER access data without \`user_id\` validation

### Session Tracking (NON-NEGOTIABLE)
- \`/update\`: After ANY significant task, before switching panels
- \`/end\`: End of session, end of day, before long break
- Always update \`current-state.md\` with next steps + resume instructions

### Subagent for Research (NON-NEGOTIABLE)
- **ALL** research/lookup operations MUST run in a subagent (Task tool)
- Includes: DB queries, n8n MCP calls, web search, context7, any external MCP
- Includes: codebase exploration when reading 3+ files
- Direct Read/Grep/Glob only for 1-2 specific known files
- Rationale: preserves main context window

---

## Session Management Protocol

### Commands

| Command | Purpose |
|---------|---------|
| \`/start\` | Session briefing with recommendations |
| \`/update\` | Mid-session checkpoint |
| \`/end\` | Session finalization + commit |
| \`/weekly-report\` | Weekly progress aggregation |
${N8N_COMMANDS}
| \`git-push-verify.sh\` | Safe push with verification |

---

## Decision Matrix: What to Use When

| Task Pattern | Primary Workflow | Skills | Rationale |
|--------------|------------------|--------|-----------|
${N8N_MATRIX}
| **New feature (story)** | \`bmad-bmm-dev-story\` | test-driven-development | Story-driven impl |
| **Quick fix/update** | \`bmad-bmm-quick-dev\` | systematic-debugging | Flexible ad-hoc dev |
| **UI component** | \`/interface-design:init\` | interface-design, ui-web | Intent-first design |
| **Database change** | Write SQL + test with DB MCP | - | Multi-tenancy critical |
| **Architecture decision** | \`bmad-bmm-create-architecture\` | - | Design doc needed |
| **Code review** | \`bmad-bmm-code-review\` | verification-before-completion | Rigor before prod |
| **Prompt optimization** | \`bmad-bmm-quick-spec\` + iterate | llm-patterns | Spec first, iterate |
| **Dashboard/analytics** | \`/interface-design:init\` + \`bmad-bmm-quick-dev\` | interface-design, ui-web, posthog-analytics | Intent-first |
| **Research** | \`bmad-bmm-research\` | context7 MCP | Gather data first |

---

## Development Rules
${N8N_SECTION}
### Frontend Development
**Use \`/interface-design\` for intent-driven UI** — start with who, what, why before building.

1. Define intent (user, task, feel)
2. Explore domain (concepts, colors, signature)
3. Build with craft (apply design principles)
4. Save patterns (\`.interface-design/system.md\`)

Component libraries (shadcn, etc.) are optional foundations — not mandatory.

**See:** \`docs/frontend-development.md\`

### Subagent for Research (NON-NEGOTIABLE)
- ALL research/lookup operations MUST run in a subagent (Task tool)
- Includes: DB queries, MCP calls, web search, context7
- Includes: codebase exploration when reading 3+ files
- Direct Read/Grep/Glob only for 1-2 specific known files

### Prompts & System Text (NON-NEGOTIABLE)
- ALL prompts, system instructions, and LLM directives MUST be in English
- User-facing output should match the user's language
- But the prompt that generates it must be English

### Backend Development
**Multi-tenancy is CRITICAL** - all queries MUST filter by \`user_id\`.

- Database access: ${DB_MCP_DISPLAY} MCP
- SELECT/search: Free (no ask)
- INSERT/UPDATE/DELETE: **ASK first**

**See:** \`docs/backend-development.md\`

---

## Mandatory Checkpoints

| Checkpoint | When | Skill |
|------------|------|-------|
| **Start conversation** | Always | \`superpowers:using-superpowers\` |
| **Creative work** | Before ANY feature/component | \`superpowers:brainstorming\` |
| **Implementation** | Before writing code | \`superpowers:test-driven-development\` |
| **Bug found** | Any bug/test failure | \`superpowers:systematic-debugging\` |
| **Before commit** | Before git commit/PR | \`superpowers:verification-before-completion\` |

---

*End of CLAUDE.md*
CLAUDEEOF

echo -e "${GREEN}  CLAUDE.md created${NC}"

# ============================================================================
# Step 13: Create PROJECT.md template
# ============================================================================

cat > "$PROJECT_DIR/PROJECT.md" << PROJEOF
# ${PROJECT_NAME} - Project Context

**Last updated:** $(date +%Y-%m-%d)

---

## Overview

<!-- Describe your project here -->

---

## Architecture

<!-- Key architectural decisions -->

---

## Key IDs & Configuration

### Environment
| Variable | Value |
|----------|-------|
$([ "$ENABLE_N8N" = true ] && echo "| N8N_URL | ${N8N_URL} |
| N8N_TAG | ${N8N_TAG} |")
$([ -n "$GITHUB_REPO" ] && echo "| GitHub Repo | ${GITHUB_REPO} |")
$([ -n "$DB_MCP_NAME" ] && echo "| DB MCP | ${DB_MCP_NAME} |")

$([ "$ENABLE_N8N" = true ] && echo "### n8n Workflows
| Workflow | ID | Purpose |
|----------|----|---------|
| <!-- Add your workflows here --> | | |")

---

## Database Schema

<!-- Document key tables here -->

---

## External Services

<!-- List integrations, APIs, etc. -->

---

## Team & Contacts

<!-- Who's working on this -->
PROJEOF

echo -e "${GREEN}  PROJECT.md created${NC}"

# ============================================================================
# Step 14: Create docs index
# ============================================================================

cat > "$PROJECT_DIR/docs/index.md" << DOCSEOF
# Documentation Index

## Development References
- [Frontend Development](frontend-development.md) - shadcn MCP, UI patterns
- [Backend Development](backend-development.md) - Database, multi-tenancy$([ "$ENABLE_N8N" = true ] && echo "
- [n8n Development](n8n-development.md) - Workflow debug, dev manager")

## Runbooks
<!-- Add operational runbooks here -->
DOCSEOF

echo -e "${GREEN}  docs/index.md created${NC}"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Project initialized successfully!               ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Created:${NC}"
echo "  CLAUDE.md              - Development system rules"
echo "  PROJECT.md             - Project context (fill this in!)"
echo "  .env                   - Environment variables"
echo "  .gitignore             - Git ignore rules"
echo ""
echo -e "${GREEN}Skills:${NC}"
echo "  /start                 - Session briefing"
echo "  /end                   - Session finalization"
echo "  /update                - Mid-session checkpoint"
echo "  /weekly-report         - Weekly progress report"
if [ "$ENABLE_N8N" = true ]; then
    echo "  /debug                 - n8n debug session"
    echo "  /test-fix              - Validate debug fix"
    echo "  /archivia              - Archive debug session"
    echo "  /cleanup-debug         - Clean old debug files"
    echo "  /sync-n8n              - Sync n8n workflows"
fi
echo ""
echo -e "${GREEN}Scripts:${NC}"
echo "  scripts/git-push-verify.sh   - Safe git push"
if [ "$ENABLE_N8N" = true ]; then
    echo "  scripts/dev-workflow.sh      - n8n [DEV] manager"
    echo "  scripts/sync-workflows.sh    - n8n workflow sync"
fi
echo ""
echo -e "${GREEN}State tracking:${NC}"
echo "  _project_specs/session/       - Session logs"
echo "  _project_specs/sprint-status.yaml  - Sprint tasks"
if [ "$ENABLE_N8N" = true ]; then
    echo "  _project_specs/debug/         - Debug sessions"
fi
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Fill in PROJECT.md with your project context"
echo "  2. Review CLAUDE.md and customize rules"
if [ "$ENABLE_N8N" = true ]; then
    echo "  3. Set N8N_API_KEY in .env"
fi
echo "  4. Run /start in Claude Code to begin!"
echo ""
