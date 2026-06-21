#!/usr/bin/env bash
set -Eeuo pipefail

cat <<'TARGETS'
OpenCode:
  project: .agents/skills/rtk-token-saver/SKILL.md
  global:  ~/.config/opencode/skills/rtk-token-saver/SKILL.md

Claude Code:
  project: .claude/skills/rtk-token-saver/SKILL.md
  global:  ~/.claude/skills/rtk-token-saver/SKILL.md

Codex:
  project: .agents/skills/rtk-token-saver/SKILL.md
  global:  ~/.agents/skills/rtk-token-saver/SKILL.md

Antigravity:
  project: .agents/skills/rtk-token-saver/SKILL.md
  global:  ~/.gemini/antigravity/skills/rtk-token-saver/SKILL.md
TARGETS
