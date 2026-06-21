# Repository Agent Instructions

This repository contains an Agent Skill and safe installer scripts.

When editing:

- Keep the skill entrypoint at `skills/rtk-token-saver/SKILL.md`.
- Keep `SKILL.md` frontmatter valid YAML with `name` and `description`.
- Do not add network calls to installer scripts.
- Do not add sudo usage.
- Do not add npm dependencies.
- Preserve existing user instruction files through managed marker blocks.
- Run `make test` before finalizing changes.

Use RTK for terminal commands when available.
