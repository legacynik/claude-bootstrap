# Current State - Claude DevKit

*Last updated: 2026-02-12 16:35*

## Active Task

Repo rinominato e ristrutturato. Nessun task attivo.

## Current Status
- **Phase**: Stable - init script funzionante, testato su voice-agents project
- **Progress**: Core features complete
- **Blocking Issues**: None

## Recent Changes (2026-02-12)
- setup-full-stack.sh riscritto (2058 righe, parametrizzato)
- README.md riscritto per claude-devkit
- Repo rinominato da claude-bootstrap a claude-devkit
- Cartella locale rinominata a ~/.claude-devkit/
- CLAUDE.md + _project_specs/ aggiunti per self-management

## Backlog

### Improvements
- [ ] Aggiungere flag `--no-interactive` per CI/scripting
- [ ] Template per `.claude/settings.json` (MCP server config)
- [ ] Skill per gestire aggiornamenti upstream (pull + merge + push)
- [ ] Test automatici per setup-full-stack.sh (genera + verifica struttura)

### Upstream Sync
- Origin: `alinaqi/claude-bootstrap` (last checked: 2026-01-14)
- Check periodicamente per nuove skill o breaking changes

## Resume Instructions
Repo stabile. Aprire qui (`cd ~/.claude-devkit && claude`) solo quando serve modificare il toolkit.
