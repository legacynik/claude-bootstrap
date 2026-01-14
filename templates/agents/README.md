# Custom Agents Templates

Questi template possono essere copiati in `.claude/agents/` del tuo progetto.

## Agents Universali (buoni per ogni progetto)

| File | Descrizione |
|------|-------------|
| `code-reviewer.md` | Review qualità, sicurezza, patterns |
| `tech-doc-writer.md` | Documentazione tecnica |
| `db-architect.md` | Design database e query |

## Agents per Tech Stack

Copia solo quelli rilevanti per il tuo progetto:

### Backend
| File | Stack |
|------|-------|
| `backend-python-fastapi.md` | Python + FastAPI |
| `backend-python-django.md` | Python + Django |
| `backend-node-express.md` | Node.js + Express |
| `backend-node-fastify.md` | Node.js + Fastify |

### Frontend
| File | Stack |
|------|-------|
| `frontend-react-nextjs.md` | React + Next.js |
| `frontend-react-vite.md` | React + Vite |
| `frontend-vue-nuxt.md` | Vue + Nuxt |

### Mobile
| File | Stack |
|------|-------|
| `mobile-react-native.md` | React Native |
| `mobile-flutter.md` | Flutter |
| `mobile-android-kotlin.md` | Android + Kotlin |

## Come Usare

```bash
# Copia agents universali
cp ~/.claude-bootstrap/templates/agents/universal/*.md .claude/agents/

# Copia agents per il tuo stack
cp ~/.claude-bootstrap/templates/agents/backend/python-fastapi.md .claude/agents/
cp ~/.claude-bootstrap/templates/agents/frontend/react-nextjs.md .claude/agents/
```

## Differenza tra Agents e Skills

| Aspect | Skills (.claude/skills/) | Agents (.claude/agents/) |
|--------|--------------------------|--------------------------|
| Cosa sono | Regole passive | Esperti specializzati |
| Quando usati | Sempre (Claude li legge) | Su richiesta |
| Scopo | Come scrivere codice | Cosa fare / decisioni |
| Esempio | "Usa type hints" | "Progetta l'architettura" |
