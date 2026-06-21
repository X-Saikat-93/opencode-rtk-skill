# skills.sh Notes

This repository is compatible with `npx skills`.

Required entrypoint:

```text
skills/rtk-token-saver/SKILL.md
```

The skill has YAML frontmatter:

```yaml
---
name: rtk-token-saver
description: ...
---
```

Install:

```bash
npx skills add X-Saikat-93/opencode-rtk-skill --skill rtk-token-saver
```

Remove:

```bash
npx skills remove rtk-token-saver
```

There is no separate registry publish step. Publish a public GitHub repository with a valid skill folder and share the `npx skills add` command.
