# Claude DevKit

> Sistema completo per lo sviluppo con Claude Code. Session tracking, n8n workflow management, BMAD methodology, 46 skill precaricate.

---

## Cos'e

Un toolkit che inizializza qualsiasi progetto con:

- **Session management** - Stato persistente tra sessioni (`/start`, `/update`, `/end`)
- **Sprint tracking** - YAML-based con decision matrix automatica
- **n8n integration** - Debug workflow strutturato, [DEV] copy manager, sync automatico
- **CLAUDE.md strutturato** - Regole, checkpoints obbligatori, decision matrix
- **46 skill globali** - TDD, code review, debugging, UI, backend, AI patterns
- **BMAD workflows** - 35 workflow per planning, architecture, testing, retrospective
- **shadcn MCP** - Frontend component-first (cerca prima di scrivere)
- **Documentazione** - Template per frontend, backend, n8n development

---

## Quick Start

```bash
# Installa (una volta)
git clone https://github.com/legacynik/claude-devkit.git ~/.claude-devkit
cd ~/.claude-devkit && ./install.sh

# Inizializza qualsiasi progetto
cd ~/Projects/my-new-project
~/.claude-devkit/scripts/setup-full-stack.sh
```

Lo script chiede:
1. **Git email** (auto-detect)
2. **n8n URL + tag** (opzionale - skip per disabilitare)
3. **GitHub repo** (opzionale)
4. **Database MCP name** (opzionale)

---

## Cosa viene creato

```
your-project/
├── CLAUDE.md                          # Regole, decision matrix, checkpoints
├── PROJECT.md                         # Context progetto (da compilare)
├── .env                               # Template variabili ambiente
│
├── .claude/skills/                    # Skill progetto-specifiche
│   ├── start/SKILL.md                 # /start - briefing con raccomandazioni
│   ├── end/SKILL.md                   # /end - finalizza sessione + commit
│   ├── update/SKILL.md                # /update - checkpoint mid-session
│   ├── weekly-report/SKILL.md         # /weekly-report - report settimanale
│   ├── debug/SKILL.md           *     # /debug <exec_id> - debug n8n
│   ├── test-fix/SKILL.md        *     # /test-fix - valida fix
│   ├── archivia/SKILL.md        *     # /archivia - archivia debug
│   ├── cleanup-debug/SKILL.md   *     # /cleanup-debug - pulizia archivio
│   └── sync-n8n/SKILL.md        *     # /sync-n8n - sync workflow
│
├── _project_specs/                    # Stato sessione e sprint
│   ├── sprint-status.yaml             # Task tracking (single source of truth)
│   ├── session/
│   │   ├── current-state.md           # Stato live per context recovery
│   │   ├── decisions.md               # Log decisioni architetturali
│   │   ├── daily/                     # Log giornalieri
│   │   └── weekly/                    # Report settimanali
│   └── debug/                    *    # Debug state persistente
│       ├── current-debug.md      *
│       └── archive/              *
│
├── scripts/
│   ├── git-push-verify.sh             # Push sicuro con verifica
│   ├── dev-workflow.sh           *    # n8n [DEV] workflow manager
│   └── sync-workflows.sh        *    # Sync n8n workflows + changelog
│
└── docs/
    ├── frontend-development.md        # shadcn MCP workflow
    ├── backend-development.md         # Multi-tenancy, DB patterns
    └── n8n-development.md        *    # MCP skills, debug workflow

* = creato solo se n8n e abilitato
```

---

## Session Management

Il sistema mantiene stato tra sessioni Claude Code tramite file.

| Comando | Quando | Cosa fa |
|---------|--------|---------|
| `/start` | Inizio sessione | Legge stato, analizza task, raccomanda workflow/skill |
| `/update` | Mid-session | Salva progresso nel daily log |
| `/end` | Fine sessione | Finalizza log, aggiorna stato, commit git |
| `/weekly-report` | Fine settimana | Aggrega daily log in report settimanale |

### Come funziona `/start`

1. Legge `current-state.md` + `sprint-status.yaml` + ultimo daily log
2. Detecta tipo di task (n8n bug, UI, database, feature...)
3. Applica decision matrix e suggerisce workflow + skill
4. Output briefing con next steps

### Decision Matrix (auto-detect)

| Pattern rilevato | Workflow suggerito | Skill |
|------------------|--------------------|-------|
| n8n workflow bug | `/debug <exec_id>` | n8n-mcp-skills (auto) |
| n8n feature | `dev-workflow.sh create` | n8n-node-configuration |
| UI component | shadcn MCP search | ui-web |
| Database change | SQL + DB MCP | multi-tenancy |
| New feature | bmad-bmm-dev-story | test-driven-development |
| Quick fix | bmad-bmm-quick-dev | systematic-debugging |
| Architecture | bmad-bmm-create-architecture | - |
| Code review | bmad-bmm-code-review | verification-before-completion |
| Prompt optimization | bmad-bmm-quick-spec + iterate | llm-patterns |
| Dashboard/analytics | shadcn MCP + quick-dev | ui-web, posthog-analytics |
| Research | bmad-bmm-research | context7 |

---

## n8n Workflow Development

> Creato solo se fornisci un URL n8n durante setup.

### Regola d'oro: MAI editare production direttamente

```bash
# 1. Crea copia [DEV]
./scripts/dev-workflow.sh create <prod-workflow-id>

# 2. Edita nel UI n8n (link fornito dal comando)

# 3. Testa

# 4. Promuovi a production (con backup + conferma)
./scripts/dev-workflow.sh promote <dev-id>

# 5. Elimina copia [DEV]
./scripts/dev-workflow.sh delete <dev-id>
```

### Debug Workflow strutturato

```
Dashboard errore → /debug <execution_id>
    → Popola current-debug.md con dati da DB + n8n
    → Suggerisce skill n8n appropriata

Investigazione → fix su [DEV] → test

/test-fix
    → Conferma fix, valuta se decision-worthy
    → Aggiorna error_log nel DB

/archivia [DEC-XXX]
    → Archivia in archive/YYYY-MM-DD-NNN.md
    → Link a decision se significativo
    → Reset current-debug.md
```

### Sync Workflows

```bash
/sync-n8n                    # Sync + commit + changelog
./scripts/sync-workflows.sh --dry-run   # Preview
```

Sincronizza tutti i workflow con il tag configurato, aggiorna `changelog-n8n.md`, auto-commit.

---

## 46 Skill Globali

Installate in `~/.claude/skills/` e disponibili in tutti i progetti.

### Superpowers (metodologia)

| Skill | Uso |
|-------|-----|
| `using-superpowers` | Inizio conversazione |
| `brainstorming` | Prima di qualsiasi lavoro creativo |
| `test-driven-development` | Prima di scrivere codice |
| `systematic-debugging` | Quando trovi un bug |
| `verification-before-completion` | Prima di commit/PR |
| `writing-plans` | Pianificazione multi-step |
| `executing-plans` | Esecuzione piani |
| `dispatching-parallel-agents` | Task paralleli |
| `code-reviewer` | Code review |
| `writing-skills` | Creare nuove skill |

### Tecnologie

| Categoria | Skill |
|-----------|-------|
| **Frontend** | react-web, react-native, ui-web, ui-mobile, ui-testing, pwa-development |
| **Backend** | nodejs-backend, python, typescript |
| **Database** | supabase, supabase-nextjs, supabase-node, supabase-python, database-schema |
| **Mobile** | flutter, android-java, android-kotlin |
| **AI/LLM** | agentic-development, llm-patterns, ai-models |
| **Testing** | playwright-testing, iterative-development |
| **Commerce** | shopify-apps, woocommerce, medusa, web-payments |
| **Marketing** | klaviyo, posthog-analytics, reddit-ads, reddit-api |
| **SEO** | aeo-optimization, web-content, site-architecture |
| **Altro** | ms-teams-apps, security, credentials, code-review, commit-hygiene |

---

## BMAD Workflows

35 workflow strutturati per il ciclo di vita del progetto.

| Fase | Workflow |
|------|----------|
| **Discovery** | create-product-brief, research |
| **Planning** | create-prd, create-architecture, create-ux-design |
| **Sprint** | sprint-planning, sprint-status, create-story, create-epics-and-stories |
| **Implementation** | dev-story, quick-dev, quick-spec |
| **Testing** | test-design, test-review, automate, nfr, ci, trace |
| **Review** | code-review, check-implementation-readiness |
| **Retrospective** | retrospective, correct-course |
| **Agents** | analyst, architect, dev, pm, sm, tea, ux-designer, tech-writer |

---

## CLAUDE.md generato

Il `CLAUDE.md` creato nel progetto include:

- **Communication Principles** - Diretto, cinico, evidence-based
- **Critical Rules** - Git, multi-tenancy, session tracking, subagent per research
- **Decision Matrix** - Auto-matching task → workflow → skill
- **Development Rules** - n8n, frontend (shadcn-first), backend (multi-tenancy)
- **Mandatory Checkpoints** - 5 punti di controllo obbligatori

### Checkpoints obbligatori

| Checkpoint | Quando | Skill |
|------------|--------|-------|
| Start conversazione | Sempre | `using-superpowers` |
| Lavoro creativo | Prima di feature/component | `brainstorming` |
| Implementazione | Prima di scrivere codice | `test-driven-development` |
| Bug trovato | Qualsiasi errore | `systematic-debugging` |
| Prima di commit | Prima di git commit/PR | `verification-before-completion` |

---

## Struttura Repository

```
~/.claude-devkit/
├── install.sh                  # Installer globale
├── scripts/
│   └── setup-full-stack.sh     # Project initializer
├── skills/                     # 46 skill globali
│   ├── base/
│   ├── react-web/
│   ├── python/
│   └── ...
├── templates/                  # Template BMAD agents
│   ├── CLAUDE.md
│   └── agents/
├── commands/                   # Comandi Claude Code
│   ├── initialize-project.md
│   ├── setup-full-stack.md
│   ├── check-contributors.md
│   └── update-code-index.md
└── hooks/                      # Git hooks
    └── pre-push
```

---

## Aggiornamento

```bash
cd ~/.claude-devkit
git pull
./install.sh
```

Le skill globali vengono aggiornate. I progetti esistenti mantengono le loro skill progetto-specifiche.

---

## Origini

Fork esteso di [alinaqi/claude-bootstrap](https://github.com/alinaqi/claude-bootstrap) con:
- Session management system completo
- n8n workflow development lifecycle
- BMAD methodology integration
- Setup script parametrizzato
- Decision matrix automatica

---

## License

MIT - See [LICENSE](LICENSE)
