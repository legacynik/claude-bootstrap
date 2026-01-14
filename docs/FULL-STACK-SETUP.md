# AI-Native Development Workflow

Guida completa per sviluppo con Claude Code + Skills + BMAD + Context7.

---

## Quick Start

```bash
# Nuovo progetto
mkdir mio-progetto && cd mio-progetto && git init
~/.claude-bootstrap/scripts/setup-full-stack.sh
claude

# Progetto esistente
cd mio-progetto
~/.claude-bootstrap/scripts/setup-full-stack.sh
```

---

## Architettura

```
┌─────────────────────────────────────────────────────────────┐
│                      TU                                     │
│                       │                                     │
│                       ▼                                     │
│              "Aggiungi feature X"                           │
│                       │                                     │
├───────────────────────┼─────────────────────────────────────┤
│                       ▼                                     │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              CLAUDE CODE                            │   │
│   │                                                     │   │
│   │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │
│   │  │ SKILLS  │ │  BMAD   │ │CONTEXT7 │ │SEQUENTIAL│  │   │
│   │  │ (regole)│ │(agents) │ │ (docs)  │ │THINKING │   │   │
│   │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │
│   │                                                     │   │
│   │  Skills: come scrivere codice (TDD, security...)   │   │
│   │  BMAD: chi fa cosa (*pm, *dev, *qa...)             │   │
│   │  Context7: docs librerie pubbliche                 │   │
│   │  Sequential: ragionamento strutturato              │   │
│   └─────────────────────────────────────────────────────┘   │
│                       │                                     │
│                       ▼                                     │
│                 CODICE SCRITTO                              │
│                       │                                     │
│                       ▼                                     │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              VERIFICHE                              │   │
│   │                                                     │   │
│   │  1. Test manuali (avvia app, curl, verifica DB)    │   │
│   │  2. ./scripts/preflight.sh                         │   │
│   │  3. /code-review                                   │   │
│   │  4. Commit                                         │   │
│   └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Componenti

### 1. Skills (Regole di Coding)

Le skills sono regole che Claude segue automaticamente.

| Skill | Cosa fa |
|-------|---------|
| `base` | TDD, atomic commits, patterns universali |
| `security` | No secrets hardcoded, OWASP, input validation |
| `real-testing` | Verifica manuale obbligatoria (non fidarti degli unit test) |
| `code-review` | Review prima di commit, blind spots da controllare |
| `code-documentation` | Commenti, docstrings, header file |

**Location:** `.claude/skills/*/SKILL.md`

### 2. BMAD Agents

Agenti specializzati per ruoli diversi.

| Comando | Ruolo |
|---------|-------|
| `*workflow-init` | Scegli workflow guidato |
| `*pm` | Project Manager - requisiti, scope |
| `*architect` | System Architect - design, tech decisions |
| `*dev` | Developer - implementazione |
| `*qa` | QA Engineer - test plan, coverage |
| `*security` | Security Expert - threat modeling |
| `*devops` | DevOps - CI/CD, infra |

**Workflow types:**
- `*workflow-quick` → Bug fix (~5 min)
- `*workflow-standard` → Feature (~15 min)
- `*workflow-enterprise` → Feature complessa (~30 min)

### 3. MCP Servers

| Server | Uso | Comando |
|--------|-----|---------|
| **Context7** | Docs librerie pubbliche | "Query Context7 for React hooks" |
| **Sequential Thinking** | Brainstorming, analisi | Automatico (sempre attivo) |
| **shadcn** (se presente) | UI components | "Aggiungi Button con shadcn" |
| **Archon** (opzionale) | Docs private, RAG | "Search Archon for [topic]" |

---

## Workflow Completo

### 1. Nuova Feature

```
1. *workflow-standard (o *pm per requisiti)
2. Claude usa Sequential Thinking per pianificare
3. Claude query Context7 per docs librerie
4. Claude implementa seguendo skills (TDD, security...)
5. Claude testa manualmente (avvia app, curl, DB)
6. Claude esegue ./scripts/preflight.sh
7. Claude esegue /code-review
8. Commit
```

### 2. Bug Fix

```
1. *workflow-quick
2. Claude riproduce il bug
3. Claude scrive test che fallisce
4. Claude fixa
5. Test passa
6. Verifica manuale
7. /code-review
8. Commit
```

### 3. Prima di Ogni Commit

```bash
# 1. Verifica manuale
#    - Avvia l'app
#    - Testa la feature (curl, browser)
#    - Verifica dati in DB

# 2. Preflight (blocca se errori)
./scripts/preflight.sh

# 3. Code review
/code-review

# 4. Solo se tutto OK
git commit
```

---

## Preflight Script

`./scripts/preflight.sh` controlla automaticamente:

| Check | Blocca? |
|-------|---------|
| Secrets hardcoded | ✅ Sì |
| Type errors (TS) | ✅ Sì |
| Lint errors | ✅ Sì |
| TODOs eccessivi | ⚠️ Warning |
| Debug statements | ⚠️ Warning |
| .env senza .env.example | ⚠️ Warning |
| Codice duplicato | ⚠️ Warning |

**Le regole in CLAUDE.md verranno ignorate. Preflight BLOCCA.**

---

## Code Review - Blind Spots

Claude è forte su:
- SQL injection
- XSS
- N+1 queries
- Code style

Claude è debole su (la skill lo obbliga a controllare):
- **Authorization bypass** - chi può accedere? User A vede dati di B?
- **Business logic** - fa cosa DOVREBBE fare?
- **State inconsistency** - race conditions, rollback parziali
- **Edge cases auth** - token scaduti, refresh fallito

---

## CLAUDE.md Generato

Dopo setup, il CLAUDE.md contiene:

```markdown
# CLAUDE.md

## Project
- **Language:** [rilevato]
- **Framework:** [rilevato]

## Rules

### Codice
- **Commenta tutto**: header file + docstrings + inline per logica non ovvia
- **Unit test ≠ verifica**: TESTA MANUALMENTE (avvia app, curl, verifica DB)
- **Logging obbligatorio**: ogni feature deve loggare
- **Preflight prima di commit**: `./scripts/preflight.sh`

### MCP Tools
- **Brainstorming/Analisi**: USA SEMPRE `mcp__sequential-thinking__sequentialthinking`
- **Docs librerie**: Query Context7
- **UI Components**: USA shadcn MCP (se presente)

### Skills (leggi prima di scrivere codice)
- `.claude/skills/base/SKILL.md`
- `.claude/skills/security/SKILL.md`
- `.claude/skills/real-testing/SKILL.md`

### Workflow
- `*workflow-init` per iniziare
- `/code-review` prima di commit
- Agents BMAD: `.claude/agents/bmad-agents.md`

### Session
- Stato: `_project_specs/session/current-state.md`
- Todos: `_project_specs/todos/active.md`
```

---

## Struttura Progetto

```
progetto/
├── CLAUDE.md                     # Istruzioni per Claude
├── .claude/
│   ├── skills/                   # Regole coding
│   │   ├── base/
│   │   ├── security/
│   │   ├── real-testing/
│   │   ├── code-review/
│   │   └── code-documentation/
│   ├── agents/                   # Guide agenti
│   │   ├── bmad-agents.md
│   │   ├── context7-guide.md
│   │   └── shadcn-mcp.md (se presente)
│   └── settings.json             # MCP config
├── scripts/
│   └── preflight.sh              # Checks pre-commit
├── _project_specs/
│   ├── todos/
│   │   └── active.md
│   └── session/
│       └── current-state.md
└── ...
```

---

## Principi Chiave

### 1. Unit Test ≠ Verifica
L'AI scrive test che confermano cosa il codice FA, non cosa DOVREBBE fare.
Test verdi + feature rotta = succede sempre.
**Testa manualmente.**

### 2. Enforce con Script, non Regole
Le regole in CLAUDE.md verranno ignorate.
`preflight.sh` BLOCCA. Usa quello.

### 3. Commenta nel Codice
La documentazione esterna diventa obsoleta.
Nessuno la legge. Documenta nel codice.

### 4. Aspettati Refactor
Dopo che funziona e capisci lo scope, spesso serve riscrivere.
È normale. La riscrittura sarà più solida.

### 5. Contesto Mirato
Non incollare 5000 righe di docs.
Fai query Context7 per ottenere solo quello che serve (~50 righe).

---

## Setup Opzionali

### Archon (Docs Private)

Per documentazione interna, wiki, knowledge base:

```bash
git clone -b stable https://github.com/coleam00/archon.git ~/archon
cd ~/archon && cp .env.example .env
# Configura Supabase in .env
docker compose up -d
# Dashboard: http://localhost:3737
```

### shadcn MCP

Per UI components React/Next.js:

```json
// .claude/settings.json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
```

---

## Troubleshooting

| Problema | Soluzione |
|----------|-----------|
| BMAD non risponde | `node -v` (deve essere 20+), `npx bmad-method@alpha install --force` |
| Skills non caricati | `cd ~/.claude-bootstrap && git pull && ./install.sh` |
| Preflight fallisce | Leggi l'errore, fixa, riesegui |
| Context7 non trova | Sii più specifico: "Query Context7 for React useEffect cleanup" |

---

## Risorse

- [Claude Bootstrap](https://github.com/alinaqi/claude-bootstrap)
- [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)
- [Context7](https://context7.com)
- [Archon](https://github.com/coleam00/archon)
