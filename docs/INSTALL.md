# Installation Guide

## Recommended install: skills.sh

```bash
npx skills add X-Saikat-93/opencode-rtk-skill --skill rtk-token-saver
```

Specific agents:

```bash
npx skills add X-Saikat-93/opencode-rtk-skill --skill rtk-token-saver -a opencode -a claude-code -a codex -a antigravity
```

Global:

```bash
npx skills add X-Saikat-93/opencode-rtk-skill --skill rtk-token-saver -g
```

## Deterministic local installer

```bash
./install.sh --agent all --scope project --project /path/to/project --force
```

Dry run:

```bash
./install.sh --agent all --scope project --project /path/to/project --dry-run
```

Verify:

```bash
./scripts/verify.sh --agent all --scope project --project /path/to/project
```
