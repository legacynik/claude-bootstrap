# Claude DevKit - Development Rules

**This repo IS the methodology.** Changes here affect all future projects.

---

## What This Repo Is

The Claude DevKit: a reusable development system for Claude Code projects.
- `scripts/setup-full-stack.sh` - Project initializer (the core product)
- `skills/` - 46 global skills installed to `~/.claude/skills/`
- `commands/` - Claude Code slash commands
- `templates/` - BMAD agent templates
- `hooks/` - Git hooks (pre-push)

---

## Rules

### Git
- Email: `franzin.niccolo@gmail.com`
- **NO** `Co-Authored-By: Claude` in commits
- Remote: `fork` = `legacynik/claude-devkit` (push here)
- Remote: `origin` = `alinaqi/claude-bootstrap` (upstream, pull only)

### Session Tracking
- `/update`: After any significant change
- `/end`: End of session
- State files in `_project_specs/session/`

### Testing Changes
- After modifying `setup-full-stack.sh`: test on a temp directory before committing
- After modifying skills: verify they load correctly in a project

### What NOT to do
- Don't add project-specific content (Noemi, voice agents, etc.)
- Don't add credentials or API keys
- Don't break backwards compatibility of setup-full-stack.sh without good reason
- Don't modify upstream files (skills/, commands/) without understanding impact on all projects

---

## Workflow

### Modifying the init script
```
1. Edit scripts/setup-full-stack.sh
2. Test: mkdir /tmp/test-project && cd /tmp/test-project && ~/.claude-devkit/scripts/setup-full-stack.sh
3. Verify generated files are correct
4. Commit + push fork
5. Cleanup: rm -rf /tmp/test-project
```

### Adding a new skill
```
1. Create skills/my-skill/SKILL.md
2. Run install.sh to deploy to ~/.claude/skills/
3. Test in a project: /my-skill
4. Commit + push fork
```

### Pulling upstream updates
```
git fetch origin
git log origin/main --oneline -10   # Review changes
git merge origin/main               # Merge (resolve conflicts)
git push fork main                  # Push to your fork
```

---

## File Structure

```
~/.claude-devkit/
├── CLAUDE.md                  # This file
├── README.md                  # Public documentation
├── install.sh                 # Global installer
├── scripts/
│   └── setup-full-stack.sh    # Project initializer (core)
├── skills/                    # 46 global skills
├── commands/                  # Claude Code commands
├── templates/                 # BMAD agents
├── hooks/                     # Git hooks
├── _project_specs/            # Session state for THIS repo
│   └── session/
│       ├── current-state.md
│       ├── daily/
│       └── weekly/
└── tests/                     # Test scripts
```

---

## Decision Log

Track decisions about the methodology itself here.

### [2026-02-12] Repo rename: claude-bootstrap → claude-devkit
- Not just bootstrap anymore: session management, n8n lifecycle, BMAD, decision matrix
- Fork of alinaqi/claude-bootstrap, diverged significantly

### [2026-02-12] setup-full-stack.sh rewrite
- Parametrized: n8n features conditional on URL input
- Creates 9 skills, 3 scripts, 5 docs, full _project_specs/
- Uses pwd as default directory

### [2026-02-12] Dedicated workspace for methodology
- Work on the toolkit from `~/.claude-devkit/`, not from project repos
- Prevents polluting project logs with tooling changes
